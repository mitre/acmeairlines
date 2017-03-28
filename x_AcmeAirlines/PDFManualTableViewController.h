//
//  PDFManualTableViewController.h
//  AcmeAirlines
//
//  Created by Alice on 1/5/15.
//  Copyright (c) 2015 iMAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface PDFManualTableViewController : UITableViewController<NSURLConnectionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property NSMutableArray *arr;
@property NSMutableData *responseData;

- (IBAction)closePDF:(id)sender;

@end
