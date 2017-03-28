//
//  AddAgendaItemViewController.h
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddAgendaItemViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property NSMutableDictionary *newdict;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UITextField *eventTextField;

@end

