//
//  NotesTableViewController.m
//  x_AcmeAirlines
//
//  Created by Hooven, Dustin L on 6/9/16.
//  Copyright © 2016 iMAS. All rights reserved.
//

#import "NotesTableViewController.h"

@interface NotesTableViewController ()

@end

@implementation NotesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable)
                  forControlEvents:UIControlEventValueChanged];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.arr = nil;
    self.dict = nil;
    self.tableView = nil;
    [self getData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // create new cell and populate it programatically
    static NSString *CellIdentifier = @"NoIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dict = [self.arr objectAtIndex:indexPath.row];
    
    // configure the title
    UILabel *cellLable = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, [UIScreen mainScreen].bounds.size.width - 16, 20)];
    cellLable.text = [dict objectForKey:@"title"];
    cellLable.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:cellLable];
    
    // configure the webview to load the text string stored in the dictionary
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(8, cellLable.bounds.size.height, [UIScreen mainScreen].bounds.size.width - 16, 60)];
    webview.scrollView.scrollEnabled = NO;
    webview.scrollView.bounces = NO;
    [cell addSubview:webview];
    // load text from the stored text file
    [webview loadHTMLString:[dict objectForKey:@"text"] baseURL:nil];
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated { //Implement this method
    [super setEditing:editing animated:animated];
    //    [self.tableView setEditing:editing animated:animated];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *key = [[self.arr objectAtIndex:indexPath.row] objectForKey:@"title"];
        [self.arr removeObjectAtIndex:indexPath.row];
        [self.dict removeObjectForKey:key];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    // write changes to file (in Documents directory)
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"flightnotes.plist"];
    [self.dict writeToFile:path atomically:YES];
}

- (void)getData {
    NSString *destPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"flightnotes.plist"];
    
    // Load the plist
    self.dict = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    
    // fill array with each key value pair
    self.arr = [[NSMutableArray alloc] init];
    for (id key in self.dict) {
        NSDictionary *itemDict = [[NSDictionary alloc] initWithObjectsAndKeys:key, @"title", [self.dict valueForKey:key], @"text",  nil];
        [self.arr addObject:itemDict];
    }
}

- (void)refreshTable {
    //TODO: refresh your data
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
