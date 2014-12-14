//
//  EDEHttpManager.h
//  EverydayEnglish
//
//  Created by APP on 14/12/1.
//  Copyright (c) 2014年 ll. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EDEHttpManagerDelegate <NSObject>

- (void)receiveDownloadProgressReport: (float)downloadProgress;
- (void)downloadDidStart;
- (void)downloadDidComplete;

@end

@interface EDEHttpManager : NSObject

@property (nonatomic, readwrite, weak) id <EDEHttpManagerDelegate> edeHttpManagerDelegate;

+ (void)continueDownload;
+ (void)backUpDownload;
+ (void)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;

+ (void)startDownload;
+ (void)stopDownload;

+ (EDEHttpManager *)getInstance;

@end
