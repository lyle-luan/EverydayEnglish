//
//  EDEHttpManager.m
//  EverydayEnglish
//
//  Created by APP on 14/12/1.
//  Copyright (c) 2014年 ll. All rights reserved.
//

#import "EDEHttpManager.h"

@interface EDEHttpManager()<NSURLSessionDownloadDelegate, NSXMLParserDelegate>
@property (nonatomic, readwrite) NSURLSession *sesstion;
@property (nonatomic, readwrite) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, readwrite) NSString *persistencePath;
@property (nonatomic, readwrite) NSString *tmpPath;
@property (nonatomic, readwrite) NSString *resumeDataPathPersistence;
@property (nonatomic, readwrite) NSString *resumeDataFileCreatedByCancel;
@property (nonatomic, readwrite) NSString *backgroundSessionConfigurationIdentifier;
@property (nonatomic, readwrite) NSString *backgroundDownloadQueueIdentifier;
@property (nonatomic, readwrite, assign) BOOL isPreBackedUpDownalodedFileName;
@property (nonatomic, readwrite, assign) BOOL isBackingUp;
@property (nonatomic, readwrite) dispatch_queue_t backgroundQueue;
@property (nonatomic, readwrite, copy) void (^backgroundEvent)();
@property (nonatomic, readwrite, copy) void (^storeResumeData)(NSData *resumeData);
@end

static NSString * const RESUME_DATA_FILE_NAME       = @"resumeData";
static NSString * const PERSISTENCE_PATH_EXTENSION  = @"downloadBackup";
static NSString * const APPLICATION_SUPPORT_PATH    = @"Application Support";
static NSString * const NEW_SOURCE_FILE             = @"newSourceFile";
static NSString * const DOWNLOAD_URL_STRING         = @"http://localhost/download.txt";
static const char* const SERIAL_QUEUE_LABLE         = "com.EverydayEnglish.serialQueue";

static NSString * const RESUME_DATA_KEY_NSURLSessionResumeInfoLocalPath     = @"NSURLSessionResumeInfoLocalPath";
static NSString * const backgroundSessionConfigurationIdentifier_SUFFIX     = @"231312rs123434d234";
static NSString * const backgroundDownloadQueueIdentifier_SUFFIX            = @"backgroundDownloadQueue";

@implementation EDEHttpManager

+ (void)continueDownload
{
    [[EDEHttpManager getInstance] tryContinueDownload];
//    [EDEHttpManager startDownload];
}

+ (void)backUpDownload
{
    [[EDEHttpManager getInstance] tryBackUpDownload];
}

+ (void)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    //Check if all transfers are done, and update UI
    //Then tell system background transfer over, so it can take new snapshot to show in App Switcher
    
    //You can also pop up a local notification to remind the user
    //...
    
    if (NO == [identifier isEqualToString:[EDEHttpManager getInstance].backgroundSessionConfigurationIdentifier])
    {
    }
    else
    {
        [EDEHttpManager getInstance].backgroundEvent = completionHandler;
    }
}

+ (void)startDownload
{
    [[EDEHttpManager getInstance] startInstance];
}

+ (void)stopDownload
{
    [[EDEHttpManager getInstance] stopInstance];
}

+ (EDEHttpManager *)getInstance
{
    static EDEHttpManager *instanceEDEHttpManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceEDEHttpManager = [[super allocWithZone:nil] init];
    });
    return instanceEDEHttpManager;
}

- (void)tryContinueDownload
{
    [self logDownloadTaskError:_downloadTask.error.code];
    if ([self isDownloadTaskDidCancel] || (_downloadTask.state == NSURLSessionTaskStateSuspended))
    {
        if ([self readyTmpPath])
        {
            [self startContinueDownload];
        }
        else
        {
        }
    }
}

- (void)tryBackUpDownload
{
    [self logDownloadTaskError:_downloadTask.error.code];
    if ([self isDownloadTaskDidCancel])
    {
        if ([self readyPersistencePath])
        {
            [self startBackupDownload];
        }
        else
        {
        }
    }
}

- (void)startInstance
{
    //TODO: reachability APIs
    __weak EDEHttpManager* weakSelf = self;
    dispatch_async(_backgroundQueue, ^{
        if (NO == [[NSFileManager defaultManager] fileExistsAtPath:weakSelf.resumeDataFileCreatedByCancel])
        {
            [weakSelf.sesstion getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                NSURLSessionDownloadTask *downloadTaskBefore = downloadTasks.firstObject;
                if ((downloadTaskBefore == nil) || (downloadTaskBefore.countOfBytesExpectedToReceive == 0))
                {
                    weakSelf.downloadTask = weakSelf.downloadTask = [weakSelf.sesstion downloadTaskWithURL:[NSURL URLWithString:DOWNLOAD_URL_STRING]];
                    [weakSelf.downloadTask resume];
                }
            }];
        }
        else
        {
            //TODO: 这部分也可以放到init中，这样startInstance就只用调用resume就可以了。
            //TODO: dispatch_sync read data, necessary? already in background
            NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:weakSelf.resumeDataFileCreatedByCancel];
            
            weakSelf.downloadTask = [weakSelf.sesstion downloadTaskWithResumeData:[fileHandler availableData]];
            [fileHandler closeFile];
            
            [weakSelf.downloadTask resume];
            
            //TODO: 清除resumeData文件。
        }
    });
}

- (void)stopInstance
{
    if ([self isNeedCancel])
    {
        [_downloadTask cancelByProducingResumeData:_storeResumeData];
        //TODO: maybe [判断tmp目录下有没有从download目录下拷贝过来的download.tmp文件](可以使用filemanager，或者使用KVO更好点)，如果没有，去download目录内拷贝到tmp中。但是感觉不是很必要。
    }
}

- (BOOL)isDownloadTaskDidCancel
{
    //TODO: downloadTask state and error code 这里是最简单的做法。
    return (_downloadTask.error != nil)&&(_downloadTask.error.code == NSURLErrorCancelled);
}

- (BOOL)isNeedCancel
{
    if ([[[EDEHttpManager getInstance] downloadTask] state] == NSURLSessionTaskStateRunning)
    {
        if ([[[EDEHttpManager getInstance] downloadTask] error] == nil)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)readyTmpPath
{
    BOOL isDerectory = NO;
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if ([filemanager fileExistsAtPath:_tmpPath isDirectory:&isDerectory])
    {
        if(isDerectory == YES)
        {
            return YES;
        }
        else
        {
            [filemanager removeItemAtPath:_tmpPath error:nil];
        }
    }
    
    //TODO: specific attributes blew
    if (NO == [filemanager createDirectoryAtPath:_tmpPath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return NO;
    }
    return YES;
}

- (BOOL)readyPersistencePath
{
    BOOL isDerectory = NO;
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if ([filemanager fileExistsAtPath:_persistencePath isDirectory:&isDerectory])
    {
        if(isDerectory == YES)
        {
            [self cleanupPersistence];
            return YES;
        }
        else
        {
            [filemanager removeItemAtPath:_persistencePath error:nil];
        }
    }
    
    //TODO: specific attributes blew
    if (NO == [filemanager createDirectoryAtPath:_persistencePath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return NO;
    }
    return YES;
}

- (void)startContinueDownload
{
    _isBackingUp = NO;
    [self firstCopyDownloadTempFile];
}

- (void)startBackupDownload
{
    _isBackingUp = YES;
    [self firstCopyDownloadTempFile];
}

- (void)firstCopyDownloadTempFile
{
    NSString *resumeDataPath = nil;
    if (_isBackingUp == YES)
    {
        resumeDataPath = _resumeDataFileCreatedByCancel;
    }
    else
    {
        resumeDataPath = _resumeDataPathPersistence;
    }
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:resumeDataPath])
    {
        NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataPath];
        NSXMLParser *xml = [[NSXMLParser alloc] initWithData:resumeData];
        xml.delegate = self;
        [xml parse];
    }
    else
    {
        if (_isBackingUp == YES)
        {
            [self cleanupTmp];
        }
        else
        {
            [self cleanupPersistence];
        }
    }
}

- (void)secondCopyResumeDataFile
{
    NSString *sourceFilePath = nil;
    NSString *destinationFilePath = nil;
    
    if (_isBackingUp == YES)
    {
        sourceFilePath = _resumeDataFileCreatedByCancel;
        destinationFilePath = _resumeDataPathPersistence;
    }
    else
    {
        sourceFilePath = _resumeDataPathPersistence;
        destinationFilePath = _resumeDataFileCreatedByCancel;
    }
    dispatch_async(_backgroundQueue, ^{
        NSError *error = nil;
        NSFileManager *filemanager = [NSFileManager defaultManager];
        if (NO == [filemanager moveItemAtPath:sourceFilePath toPath:destinationFilePath error:&error])
        {
            if (_isBackingUp == YES)
            {
                [self cleanupTmp];
            }
            else
            {
                [self cleanupPersistence];
            }
        }
        else
        {
            [self cleanupDownload];
        }
    });
}

- (void)cleanup
{
    [self cleanupTmp];
    [self cleanupPersistence];
    [self cleanupDownload];
}

- (void)cleanupTmp
{
    NSString *tempPath = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNameList = [fileManager contentsOfDirectoryAtPath:tempPath error:nil];
    for (NSString *fileName in fileNameList)
    {
        //TODO: 忽略.DS_Store
        NSString *fullFileName = [tempPath stringByAppendingPathComponent:fileName];
        [fileManager removeItemAtPath:fullFileName error:nil];
    }
}

- (void)cleanupPersistence
{
}

- (void)cleanupDownload
{
}

- (void)logErrorDetail: (NSError *)error
{
    NSLog(@"error: %@", [error debugDescription]);
}

- (void)logDownloadTaskError: (NSInteger)errorNum
{
    switch (errorNum)
    {
        case NSURLErrorUnknown:
        {
            NSLog(@"NSURLErrorUnknown");
            break;
        }
        case NSURLErrorCancelled:
        {
            NSLog(@"NSURLErrorCancelled");
            break;
        }
        case NSURLErrorBadURL:
        {
            NSLog(@"NSURLErrorBadURL");
            break;
        }
        case NSURLErrorTimedOut:
        {
            NSLog(@"NSURLErrorTimedOut");
            break;
        }
        case NSURLErrorUnsupportedURL:
        {
            NSLog(@"NSURLErrorUnsupportedURL");
            break;
        }
        case NSURLErrorCannotFindHost:
        {
            NSLog(@"NSURLErrorCannotFindHost");
            break;
        }
        case NSURLErrorCannotConnectToHost:
        {
            NSLog(@"NSURLErrorCannotConnectToHost");
            break;
        }
        case NSURLErrorDataLengthExceedsMaximum:
        {
            NSLog(@"NSURLErrorDataLengthExceedsMaximum");
            break;
        }
        case NSURLErrorNetworkConnectionLost:
        {
            NSLog(@"NSURLErrorNetworkConnectionLost");
            break;
        }
        case NSURLErrorDNSLookupFailed:
        {
            NSLog(@"NSURLErrorDNSLookupFailed");
            break;
        }
        case NSURLErrorHTTPTooManyRedirects:
        {
            NSLog(@"NSURLErrorHTTPTooManyRedirects");
            break;
        }
        case NSURLErrorResourceUnavailable:
        {
            NSLog(@"NSURLErrorResourceUnavailable");
            break;
        }
        case NSURLErrorNotConnectedToInternet:
        {
            NSLog(@"NSURLErrorNotConnectedToInternet");
            break;
        }
        case NSURLErrorRedirectToNonExistentLocation:
        {
            NSLog(@"NSURLErrorRedirectToNonExistentLocation");
            break;
        }
        case NSURLErrorBadServerResponse:
        {
            NSLog(@"NSURLErrorBadServerResponse");
            break;
        }
        case NSURLErrorUserCancelledAuthentication:
        {
            NSLog(@"NSURLErrorUserCancelledAuthentication");
            break;
        }
        case NSURLErrorUserAuthenticationRequired:
        {
            NSLog(@"NSURLErrorUserAuthenticationRequired");
            break;
        }
        case NSURLErrorZeroByteResource:
        {
            NSLog(@"NSURLErrorZeroByteResource");
            break;
        }
        case NSURLErrorCannotDecodeRawData:
        {
            NSLog(@"NSURLErrorCannotDecodeRawData");
            break;
        }
        case NSURLErrorCannotDecodeContentData:
        {
            NSLog(@"NSURLErrorCannotDecodeContentData");
            break;
        }
        case NSURLErrorCannotParseResponse:
        {
            NSLog(@"NSURLErrorCannotParseResponse");
            break;
        }
        case NSURLErrorInternationalRoamingOff:
        {
            NSLog(@"NSURLErrorInternationalRoamingOff");
            break;
        }
        case NSURLErrorCallIsActive:
        {
            NSLog(@"NSURLErrorCallIsActive");
            break;
        }
        case NSURLErrorDataNotAllowed:
        {
            NSLog(@"NSURLErrorDataNotAllowed");
            break;
        }
        case NSURLErrorRequestBodyStreamExhausted:
        {
            NSLog(@"NSURLErrorRequestBodyStreamExhausted");
            break;
        }
        case NSURLErrorFileDoesNotExist:
        {
            NSLog(@"NSURLErrorFileDoesNotExist");
            break;
        }
        case NSURLErrorFileIsDirectory:
        {
            NSLog(@"NSURLErrorFileIsDirectory");
            break;
        }
        case NSURLErrorNoPermissionsToReadFile:
        {
            NSLog(@"NSURLErrorNoPermissionsToReadFile");
            break;
        }
        case NSURLErrorSecureConnectionFailed:
        {
            NSLog(@"NSURLErrorSecureConnectionFailed");
            break;
        }
        case NSURLErrorServerCertificateHasBadDate:
        {
            NSLog(@"NSURLErrorServerCertificateHasBadDate");
            break;
        }
        case NSURLErrorServerCertificateUntrusted:
        {
            NSLog(@"NSURLErrorServerCertificateUntrusted");
            break;
        }
        case NSURLErrorServerCertificateHasUnknownRoot:
        {
            NSLog(@"NSURLErrorServerCertificateHasUnknownRoot");
            break;
        }
        case NSURLErrorServerCertificateNotYetValid:
        {
            NSLog(@"NSURLErrorServerCertificateNotYetValid");
            break;
        }
        case NSURLErrorClientCertificateRejected:
        {
            NSLog(@"NSURLErrorClientCertificateRejected");
            break;
        }
        case NSURLErrorClientCertificateRequired:
        {
            NSLog(@"NSURLErrorClientCertificateRequired");
            break;
        }
        case NSURLErrorCannotLoadFromNetwork:
        {
            NSLog(@"NSURLErrorCannotLoadFromNetwork");
            break;
        }
        case NSURLErrorCannotCreateFile:
        {
            NSLog(@"NSURLErrorCannotCreateFile");
            break;
        }
        case NSURLErrorCannotOpenFile:
        {
            NSLog(@"NSURLErrorCannotOpenFile");
            break;
        }
        case NSURLErrorCannotCloseFile:
        {
            NSLog(@"NSURLErrorCannotCloseFile");
            break;
        }
        case NSURLErrorCannotWriteToFile:
        {
            NSLog(@"NSURLErrorCannotWriteToFile");
            break;
        }
        case NSURLErrorCannotRemoveFile:
        {
            NSLog(@"NSURLErrorCannotRemoveFile");
            break;
        }
        case NSURLErrorCannotMoveFile:
        {
            NSLog(@"NSURLErrorCannotMoveFile");
            break;
        }
        case NSURLErrorDownloadDecodingFailedMidStream:
        {
            NSLog(@"NSURLErrorDownloadDecodingFailedMidStream");
            break;
        }
        case NSURLErrorDownloadDecodingFailedToComplete:
        {
            NSLog(@"NSURLErrorDownloadDecodingFailedToComplete");
            break;
        }
        default:
        {
            switch (_downloadTask.state)
            {
                case NSURLSessionTaskStateRunning:
                {
                    NSLog(@"NSURLSessionTaskStateRunning");
                    break;
                }
                case NSURLSessionTaskStateSuspended:
                {
                    NSLog(@"NSURLSessionTaskStateSuspended");
                    break;
                }
                case NSURLSessionTaskStateCanceling:
                {
                    NSLog(@"NSURLSessionTaskStateCanceling");
                    break;
                }
                case NSURLSessionTaskStateCompleted:
                {
                    NSLog(@"NSURLSessionTaskStateCompleted");
                    break;
                }
                default:
                {
                    NSLog(@"unknow task error and state");
                    break;
                }
            }
            break;
        }
    }
}

- (id)init
{
    if (self = [super init])
    {
        NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        NSString *appSupportPath = [libraryPath stringByAppendingPathComponent:APPLICATION_SUPPORT_PATH];
        _persistencePath = [appSupportPath stringByAppendingPathComponent:[[NSBundle mainBundle].bundleIdentifier stringByAppendingPathExtension:PERSISTENCE_PATH_EXTENSION]];
        _resumeDataPathPersistence = [_persistencePath stringByAppendingPathComponent:RESUME_DATA_FILE_NAME];
        
        _tmpPath = NSTemporaryDirectory();
        _resumeDataFileCreatedByCancel = [_tmpPath stringByAppendingPathComponent:RESUME_DATA_FILE_NAME];
        
        _backgroundQueue = dispatch_queue_create(SERIAL_QUEUE_LABLE, DISPATCH_QUEUE_SERIAL);
        
        _backgroundEvent = nil;
        
        _isPreBackedUpDownalodedFileName = NO;
        
        __weak EDEHttpManager *weakSelf = self;
        _storeResumeData = ^(NSData *resumeData) {
            //TODO: 工作在哪个线程上，operation queue和下面的dispatch queue。
            
            dispatch_async(weakSelf.backgroundQueue, ^{
                //TODO: 这里未执行完，App可以start，放到serial queue中。该函数阻塞其他所有操作。
                //TODO: 文件操作需要异步。
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:weakSelf.resumeDataFileCreatedByCancel error:nil];
                
                //TODO: specific attributes blew
                if (NO == [fileManager createFileAtPath:weakSelf.resumeDataFileCreatedByCancel contents:nil attributes:nil])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //TODO: view stop done
                    });
                }
                else
                {
                    //TODO: need optimisation
                    //TODO: it allways excutes right?
                    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.resumeDataFileCreatedByCancel];
                    [fileHandle writeData:resumeData];
                    [fileHandle closeFile];
                    
                    //TODO:
                    // 1. 下载一半的文件拷贝到tmp目录中后，该block才执行。那这里就update view。
                    // 2. 需要探测下载一半的文件是否拷贝到tmp目录，探测到或超时再更新view。
                }
            });
        };
        
        _edeHttpManagerDelegate = nil;
        
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        _backgroundDownloadQueueIdentifier = [bundleId stringByAppendingString:backgroundDownloadQueueIdentifier_SUFFIX];
        _backgroundSessionConfigurationIdentifier = [bundleId stringByAppendingString:backgroundSessionConfigurationIdentifier_SUFFIX];
        
        _sesstion = [self backgroundSesstion];
    }
    return self;
}

- (NSURLSession *)backgroundSesstion
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_backgroundSessionConfigurationIdentifier];
    configuration.allowsCellularAccess = NO;
    
    NSOperationQueue *backgroundDownloadQueue = [[NSOperationQueue alloc] init];
    backgroundDownloadQueue.name = _backgroundDownloadQueueIdentifier;
    
    return [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:backgroundDownloadQueue];
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [EDEHttpManager getInstance];
}

#pragma delegate
#pragma NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"#%lld#%lld#", fileOffset, expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"!%lld!%lld!%lld!", bytesWritten, totalBytesWritten, totalBytesWritten - bytesWritten);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.edeHttpManagerDelegate respondsToSelector:@selector(receiveDownloadProgressReport:)])
        {
            [self.edeHttpManagerDelegate receiveDownloadProgressReport:totalBytesWritten/totalBytesExpectedToWrite];
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    //TODO: erase console txt
    //TODO: delete RESUME_DATA_FILE_NAME
    //TODO: copy cache to source.json.
    //TODO: delete other CFNetworkDownload_tihHVP.tmp file。terminate程序后在启动可以继续下载，但是会创建一个CFNetworkDownload_tihHVP.tmp，该文件应该能被删除。
    //TODO: maybe need more
    NSString *downloadedFilePath = location.path;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:downloadedFilePath])
    {
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *fileDidDownloadFile = [documentPath stringByAppendingPathComponent:NEW_SOURCE_FILE];
        [fileManager moveItemAtPath:downloadedFilePath toPath:fileDidDownloadFile error:nil];
        [self cleanup];
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if (_backgroundEvent != nil)
    {
        _backgroundEvent();
        _backgroundEvent = nil;
    }
}

#pragma HTTPRedirection
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    
}

#pragma downloadComplete
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil)
    {
        [session finishTasksAndInvalidate];
    }
    else
    {
        [self logErrorDetail:error];
        
        //TODO: downloadTask state and error code 这里是最简单的做法。
        if (error.code == NSURLErrorCancelled)
        {
            if (error.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] == nil)
            {
                //cause by - (void)stopInstance
            }
            else if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData] != nil)
            {
                _storeResumeData([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]);
                [self startInstance];
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
}

#pragma NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidStartDocument");
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""] || string == nil)
    {
        return;
    }
    
    if (_isPreBackedUpDownalodedFileName)
    {
        _isPreBackedUpDownalodedFileName = NO;
        NSLog(@"xml get download temp path: %@", string);
        [parser abortParsing];
        
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSString *sourceFilePath = nil;
        NSString *destinationFilePath = nil;
        
        if (_isBackingUp == YES)
        {
            sourceFilePath = string;
            destinationFilePath = [_persistencePath stringByAppendingPathComponent:string.lastPathComponent];
        }
        else
        {
            sourceFilePath = [_persistencePath stringByAppendingPathComponent:string.lastPathComponent];
            destinationFilePath = [_tmpPath stringByAppendingPathComponent:string.lastPathComponent];
        }
        
        if ([filemanager fileExistsAtPath:sourceFilePath])
        {
            __weak EDEHttpManager* weakSelf = self;
            dispatch_sync(_backgroundQueue, ^{
                NSError *error;
                if (NO == [filemanager moveItemAtPath:sourceFilePath toPath:destinationFilePath error:&error])
                {
                    NSLog(@"copy downloadTmpFile error: %@", error);
                    if (_isBackingUp == YES)
                    {
                        [self cleanupTmp];
                    }
                    else
                    {
                        [self cleanupPersistence];
                    }
                }
                else
                {
                    [weakSelf secondCopyResumeDataFile];
                }
            });
        }
        else
        {
            if (_isBackingUp == YES)
            {
                [self cleanupTmp];
            }
            else
            {
                [self cleanupPersistence];
            }
        }
    }
    else if ([string isEqualToString:RESUME_DATA_KEY_NSURLSessionResumeInfoLocalPath])
    {
        _isPreBackedUpDownalodedFileName = YES;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    //TODO: error, cann't find
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (parseError.code == NSXMLParserDelegateAbortedParseError)
    {
        //TODO: normal, currect
    }
    else
    {
        //TODO: error
    }
}

@end
