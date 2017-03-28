//
//  main.m
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

extern int ptrace(int r, pid_t p, caddr_t a, int d);

int main(int argc, char * argv[]) {
    // prevents debuggers from attatching, uncomment for release
    //ptrace(31,0,0,0);
    @autoreleasepool {
        return UIApplicationMain(argc, argv, @"AcmeUIApplication", NSStringFromClass([AppDelegate class]));
    }
}
