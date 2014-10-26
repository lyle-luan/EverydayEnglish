//
//  TxTFactory.h
//  EverydayEnglish
//
//  Created by Aaron on 10/26/14.
//  Copyright (c) 2014 ll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxTFactory : NSObject

@property (nonatomic, readonly) NSString *english;
@property (nonatomic, readonly) NSString *chinese;

+ (TxTFactory *)getInstance;

@end
