//
//  AppDelegate.m
//  EverydayEnglish
//
//  Created by ll on 14-10-1.
//  Copyright (c) 2014年 ll. All rights reserved.
//

#import "AppDelegate.h"
#import "TxTFactory.h"
#import "EDEHttpManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self redirectConsoleLogToDocumentFolder];
    [TxTFactory getInstance];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [EDEHttpManager continueDownload];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [EDEHttpManager backUpDownload];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
//    [self redirectConsoleLogToDocumentFolder];
    NSLog(@"handleEventsForBackgroundURLSession");
    [EDEHttpManager handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console_log.txt"];
    NSLog(@"%@", logPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:logPath error:nil];
    
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

@end
