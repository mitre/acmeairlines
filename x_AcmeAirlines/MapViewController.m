//
//  FirstViewController.m
//  Demo
//
//  Created by Alice on 12/23/14.
//  Copyright (c) 2014 Alice. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

BOOL showUserDot = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.labelText setText:@""];
    if (self.currentLocation == nil)
        self.currentLocation = [[CLLocation alloc] init];
    
    if (self.locationManager == nil)
        self.locationManager = [[CLLocationManager alloc] init];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
        // Sending a message to a void compile time error
        [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                   to:self.locationManager
                                                 from:self
                                             forEvent:nil];
    }
    
    self.locationManager.delegate = self;
    
    // NOTE: these settings will give the highest accuracy but will consume more battery and CPU
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([CLLocationManager locationServicesEnabled])
        [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = showUserDot;
    
    self.mapView.delegate = self;
    MKCoordinateSpan defaultSpan = MKCoordinateSpanMake(0.5, 1.0);
    MKCoordinateRegion defaultRegion = MKCoordinateRegionMake(self.currentLocation.coordinate, defaultSpan);
    [self.mapView setRegion:defaultRegion];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)centerMapButtonClicked:(id)sender {
    // reset the visible portion of the map w/ location at the center
    MKCoordinateRegion currentRegion = [self.mapView region];
    currentRegion.center = self.currentLocation.coordinate;
    [self.mapView setRegion:currentRegion animated:YES];
//    [self.mapView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
    
    
    
    // temp: read file
    // get file path
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"MapHelper.txt"];
    
    // read the whole file as a single string
    NSString *content = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"MapHelper.txt: %@", content);
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    NSString *locString = [NSString stringWithFormat:@"%+.4f,%+.4f",
                           location.coordinate.latitude,
                           location.coordinate.longitude];
    [self.labelText setText:locString];
    self.currentLocation = location;
    MKCoordinateRegion region = [self.mapView region];
    region.center = location.coordinate;
    [self.mapView setRegion:region];
    
    
    NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filename = [filename stringByAppendingPathComponent:@"MapHelper.txt"];
    
    // create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename])
        [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    
    // get current date/time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    // append text to file
    NSString *completeString = [NSString stringWithFormat:@"%@: %@", currentTime, locString];
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    [file seekToEndOfFile];
    [file writeData:[completeString dataUsingEncoding:NSUTF8StringEncoding]];
    [file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        NSLog(@"User has denied location services");
    } else {
        NSLog(@"Location manager did fail with error: %@", error.localizedFailureReason);
    }
}

@end
