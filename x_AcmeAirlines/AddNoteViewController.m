//
//  AddNoteViewController.m
//  x_AcmeAirlines
//
//  Created by Hooven, Dustin L on 6/13/16.
//  Copyright © 2016 iMAS. All rights reserved.
//

#import "AddNoteViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AddNoteViewController ()

@end

@implementation AddNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self.text layer] setBorderColor:[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.0].CGColor];
    [[self.text layer] setBorderWidth:.8];
    [[self.text layer] setCornerRadius:5];
    [[self.titleField layer] setBorderColor:[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.0].CGColor];
    [[self.titleField layer] setBorderWidth:.8];
    [[self.titleField layer] setCornerRadius:5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableSaveButtom:(id)sender {
    if (![self.text.text isEqualToString:@""] &&
        ![self.titleField.text isEqualToString:@""])
    {
        [self.saveButton setEnabled:YES];
    } else {
        [self.saveButton setEnabled:NO];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![self.text.text isEqualToString:@""] &&
        ![self.titleField.text isEqualToString:@""])
    {
        [self.saveButton setEnabled:YES];
    } else {
        [self.saveButton setEnabled:NO];
    }
    return YES;
}

- (IBAction)saveButtonClicked:(id)sender {
    // set the path to the users documents directory and name the file
    NSString *destPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"flightnotes.plist"];
    // create a dictionary object and set the key value pairs
    NSString *text = [[NSString alloc] initWithString:self.text.text];
    NSString *title = [[NSString alloc] initWithString:self.titleField.text];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:text, title ,nil];
    // create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        [data writeToFile:destPath atomically:YES];
    } else {
        // get current notes
        NSMutableDictionary *notes = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
        // add new note to the existing ones
        [notes addEntriesFromDictionary:data];
        // save notes back to users documents
        [notes writeToFile:destPath atomically:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
