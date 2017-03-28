//
//  VulnerableAppDelegate.h
//  x_AcmeAirlines
//
//  Created by Hooven, Dustin L on 6/6/16.
//  Copyright © 2016 iMAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddedVulnerabilities : NSObject  <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (void)addVulnerabilities;
- (void)addToLog:(NSString *)logOutput;

@end
