//
//  RadioTableViewController.h
//  x_AcmeAirlines
//
//  Created by Alice on 3/12/15.
//  Copyright (c) 2015 iMAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface RadioTableViewController : UITableViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@end
