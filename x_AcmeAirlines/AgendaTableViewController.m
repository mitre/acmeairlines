//
//  SecondViewController.m
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import "AgendaTableViewController.h"

@interface AgendaTableViewController ()

@end

@implementation AgendaTableViewController


- (IBAction)addButtonClicked:(id)sender {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"Agenda.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"Agenda" ofType:@"plist"];
        NSError *err;
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:&err];
        if (err)
            NSLog(@"%@", err);
    }
    
    // Load the plist
    self.arr = [[NSMutableArray alloc] initWithContentsOfFile:destPath];
    
    // sort array according to time
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArr = [self.arr sortedArrayUsingDescriptors:sortDescriptors];
    self.arr = [sortedArr mutableCopy];
}

- (void)viewWillDisappear:(BOOL)animated {
    // write changes to file (in Documents directory)
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"Agenda.plist"];
    [self.arr writeToFile:path atomically:YES];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tableView = nil;
    [self.tableView reloadData];
    [super viewWillAppear:animated];
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
    
    static NSString *CellIdentifier = @"AgendaCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dict = [self.arr objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[dict objectForKey:@"time"]];
    [cell.detailTextLabel setText:[dict objectForKey:@"event"]];
    
    return cell;
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated { //Implement this method
    [super setEditing:editing animated:animated];
//    [self.tableView setEditing:editing animated:animated];
}


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         [self.arr removeObjectAtIndex:indexPath.row];
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }
 }

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }

- (IBAction)unwindToAgendaTableViewController:(UIStoryboardSegue *)unwindSegue
{
}

@end
