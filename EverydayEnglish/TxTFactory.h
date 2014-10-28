//
//  TxTFactory.h
//  EverydayEnglish
//
//  Created by Aaron on 10/26/14.
//  Copyright (c) 2014 ll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxTFactory : NSObject

- (NSString *)englishForward;
- (NSString *)chineseForward;
- (NSString *)englishBackward;
- (NSString *)chineseBackward;
- (NSString *)englishOriginal;
- (NSString *)chineseOriginal;

+ (TxTFactory *)getInstance;

@end
