//
//  RadioTableViewController.m
//  x_AcmeAirlines
//
//  Created by Alice on 3/12/15.
//  Copyright (c) 2015 iMAS. All rights reserved.
//

#import "RadioTableViewController.h"

@interface RadioTableViewController () {
    NSMutableArray *recArr;
    AVAudioPlayer *player;
}

@end

@implementation RadioTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllRecs)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, delButton, nil];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        UIApplication *myApp = [UIApplication sharedApplication];
        NSString *theCall = [NSString stringWithFormat:@"tel://4954954954"];
        NSLog(@">>>>>>>>making call with %@",theCall);
        [myApp openURL:[NSURL URLWithString:theCall]];
    });
    
    [self.navigationController setToolbarHidden:NO];
    
    recArr = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:documentsDir error:nil];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mov'"];
    NSArray *recFiles = [allFiles filteredArrayUsingPredicate:filter];
    
    for (NSString *f in recFiles) {
        [recArr addObject:f];
    }
    
}

-(void) playFile:(NSString *)filename {
    NSURL *fileURL = [NSURL URLWithString:filename];
    NSError *error = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (error) {
        NSLog(@"Error playing file at %@: %@", filename, error);
    }
    [player setDelegate:self];
    [player play];
}

-(void) deleteAllRecs {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:documentsDir error:nil];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mov'"];
    NSArray *recFiles = [allFiles filteredArrayUsingPredicate:filter];
    
    for (NSString *f in recFiles) {
        NSError *error = nil;
        [fileManager removeItemAtPath:[documentsDir stringByAppendingPathComponent:f] error:&error];
        if (error) {
            NSLog(@"Error deleting rec file: %@", error);
        }
    }
    
    recArr = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finished playing the recording"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
    return [recArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioUICell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [recArr objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [documentsDir stringByAppendingPathComponent:[recArr objectAtIndex:indexPath.row]];
    [self playFile:filename];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
