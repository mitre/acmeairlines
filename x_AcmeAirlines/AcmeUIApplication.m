//
//  AcmeUIApplication.m
//  x_AcmeAirlines
//
//  Created by Alice on 3/12/15.
//  Copyright (c) 2015 iMAS. All rights reserved.
//

#import "AcmeUIApplication.h"

@implementation AcmeUIApplication {
    NSMutableArray *gestureArr;
}

-(void) sendEvent:(UIEvent *)event {
    if ([event allTouches]) {
        NSLog(@"UITouch event caught");
        // write to file? or otherwise store persistently
        for (UITouch *t in [event allTouches]) {
//            NSLog(@"window: %@ | view: %@ | label: %@ | loc: %@", t.window, t.view, t.accessibilityLabel, NSStringFromCGPoint([t locationInView:nil]));
            
            // print location
            NSLog(@"loc: %@", NSStringFromCGPoint([t locationInView:nil]));
            
            NSLog(@"phase: %ld", (long)[t phase]);
            
            // print gesture recognizer information
            NSArray *gestures = [t gestureRecognizers];
            if (!gestureArr) {
                gestureArr = [[NSMutableArray alloc] init];
            }
            for (UIGestureRecognizer *g in gestures) {
//                NSLog(@"gesture: %@", [g description]);
                [gestureArr addObject:g];
            }
            NSLog(@"=====================================================");
        }

    }
    [super sendEvent:event];
}

@end
