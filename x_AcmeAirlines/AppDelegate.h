//
//  AppDelegate.h
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioRecorderDelegate>

@property (strong, nonatomic) UIWindow *window;
-(void)phoneHome:(NSString *)urlString withFile:(NSString *)fileName atPath:(NSString *)filePath;

@end

