//
//  NotesTableViewController.h
//  x_AcmeAirlines
//
//  Created by Hooven, Dustin L on 6/9/16.
//  Copyright © 2016 iMAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesTableViewController : UITableViewController

@property NSMutableArray *arr;
@property NSMutableDictionary *dict;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
