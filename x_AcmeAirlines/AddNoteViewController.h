//
//  AddNoteViewController.h
//  x_AcmeAirlines
//
//  Created by Hooven, Dustin L on 6/13/16.
//  Copyright © 2016 iMAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNoteViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)enableSaveButtom:(id)sender;


@end
