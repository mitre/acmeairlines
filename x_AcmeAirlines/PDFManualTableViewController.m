//
//  PDFManualTableViewController.m
//  AcmeAirlines
//
//  Created by Alice on 1/5/15.
//  Copyright (c) 2015 iMAS. All rights reserved.
//

#import "PDFManualTableViewController.h"
#import "dlfcn.h"
#import <sys/sysctl.h>
#import <sys/syscall.h>


@interface PDFManualTableViewController () {
    AVAudioRecorder *recorder;
    NSMutableArray *recArr;
    AVAudioPlayer *player;
}

@end

@implementation PDFManualTableViewController

static const int webViewTag = 101;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!recArr) {
        recArr = [[NSMutableArray alloc] init];
    }
    
    if (self.arr == nil) { // array of PDF filenames
        self.arr = [[NSMutableArray alloc] init];
        NSString *sourcePath = [[NSBundle mainBundle] bundlePath];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:sourcePath];
        NSString *filePath;
        
        while ((filePath = [enumerator nextObject]) != nil) {
            if ([[filePath pathExtension] isEqualToString:@"pdf"]) {
                [self.arr addObject:[sourcePath stringByAppendingPathComponent:filePath]];
            }
        }
    }
    
    void *handle = dlopen("/usr/lib/libSystem.B.dylib", RTLD_GLOBAL | RTLD_LAZY);
    void (*zero)() = dlsym(handle, "bzero");
    
    int mib[] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid() };
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    zero(&info, size);
    sysctl(mib, 4, &info, &size, nil, 0);
    
   // detects if a debugger is attatched and then exits if it is, uncomment for release
    /*if (info.kp_proc.p_flag & 0x800) {
        NSLog(@"I'm being traced, BAIL");
    }
    syscall(SYS_exit);*/
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [recorder pause];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"PDFCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])"
                                                                            options:0
                                                                              error:NULL];
    NSString *filename = [[[self.arr objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    // PDFs are titled using camelcase; separate them using spaces
    NSString *formattedFilename = [regexp stringByReplacingMatchesInString:filename
                                                                   options:0
                                                                     range:NSMakeRange(0, filename.length)
                                                              withTemplate:@"$1 $2"];
    [cell.textLabel setText:formattedFilename];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = rect.size;
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,screenSize.width,screenSize.height)];
    myWebView.tag = webViewTag;
    myWebView.autoresizesSubviews = YES;
    myWebView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    NSString *filePath = [self.arr objectAtIndex:indexPath.row];
    NSURL *targetURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [myWebView loadRequest:request];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closePDF:)];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    [self.view addSubview:myWebView];
    myWebView = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // sneaky code makes a call to Dropbox when the last row is tapped
    if (indexPath.row == [self.arr count]-1) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dropbox.ru"]];
        NSLog(@"sneakily calling dropbox");
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [conn start];
    }
}

- (IBAction)closePDF:(id)sender {
    [[self.view viewWithTag:webViewTag] removeFromSuperview];
    self.navigationItem.rightBarButtonItem = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
