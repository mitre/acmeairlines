//
//  AddAgendaItemViewController.m
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import "AddAgendaItemViewController.h"
#import "AgendaTableViewController.h"

@interface AddAgendaItemViewController ()

@end

@implementation AddAgendaItemViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.eventTextField) {
        [self setValues];
        [self.eventTextField resignFirstResponder];
    }

    return YES;
}

- (void) setValues {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    
    NSString *keyStr = [outputFormatter stringFromDate:self.timePicker.date];
    [self.newdict setObject:keyStr forKey:@"time"];
    [self.newdict setObject:self.eventTextField.text forKey:@"event"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.newdict = [[NSMutableDictionary alloc] init];
    self.eventTextField.delegate = self;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    [self.timePicker setLocale:locale];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableSaveButtom:(id)sender {
    if (![self.eventTextField.text isEqualToString:@""])
    {
        [self.saveButton setEnabled:YES];
    } else {
        [self.saveButton setEnabled:NO];
    }
}

- (IBAction)saveButtonClicked:(id)sender {
    // get path to stored Agenda.plist
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"Agenda.plist"];
    // populate the array with the contense of the stored file then add the new agenda item
    NSMutableArray *newArr = [[NSMutableArray alloc] initWithContentsOfFile:destPath];
    // Set the values for the dictionary
    [self setValues];
    [newArr addObject:self.newdict];
    // sort the array by time
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    newArr = [[newArr sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    //write the new array to the old file
    [newArr writeToFile:destPath atomically:YES];
    // pop back to the previous controller
    [self.navigationController popViewControllerAnimated:YES];
}

@end
