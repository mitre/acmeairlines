//
//  SecondViewController.h
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgendaTableViewController : UITableViewController

@property NSMutableArray *arr;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end

