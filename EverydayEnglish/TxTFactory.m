//
//  TxTFactory.m
//  EverydayEnglish
//
//  Created by Aaron on 10/26/14.
//  Copyright (c) 2014 ll. All rights reserved.
//

#import "TxTFactory.h"

@interface TxTFactory()

@property (nonatomic, readonly) NSInteger txtCount;
@property (nonatomic, readwrite) NSArray *allKeyOfJSON;
@property (nonatomic, readwrite) id sourceTxtContentJSON;
@property (nonatomic, readwrite) NSString *currentEnglish;

@end

@implementation TxTFactory

@synthesize english;
@synthesize chinese;
@synthesize txtCount;

static TxTFactory *txtFactoryInstance = nil;

+ (TxTFactory *)getInstance
{
    if (txtFactoryInstance == nil)
    {
        txtFactoryInstance = [[super allocWithZone:nil] init];
        [txtFactoryInstance initTxTFacory];
    }
    return txtFactoryInstance;
}

- (void)initTxTFacory
{
    NSString *sourceTxtPath = [NSString stringWithFormat:@"%@/source.json", [[NSBundle mainBundle] resourcePath]];
    
    NSString *sourceTxtContent = [NSString stringWithContentsOfFile:sourceTxtPath encoding:NSUTF8StringEncoding error:nil];
    
    NSData *sourceTxtContentData = [sourceTxtContent dataUsingEncoding:NSUTF8StringEncoding];
    _sourceTxtContentJSON = [NSJSONSerialization JSONObjectWithData:sourceTxtContentData options:0 error:nil];
    
    _allKeyOfJSON = [_sourceTxtContentJSON allKeys];
    
    NSString *EnglishContent = nil;
    for (EnglishContent in _allKeyOfJSON)
    {
        NSLog(@"English: %@", EnglishContent);
        NSLog(@"Chinese: %@", [_sourceTxtContentJSON objectForKey:EnglishContent]);
    }
}

- (NSString *)english
{
    _currentEnglish = [_allKeyOfJSON objectAtIndex:[txtFactoryInstance txtCount]];
    return _currentEnglish;
}

- (NSString *)chinese
{
    return [_sourceTxtContentJSON objectForKey:txtFactoryInstance.currentEnglish];
}

- (NSInteger)txtCount
{
    // 从JSON生成数组的时候已经乱序了，所以不需要随机。
    // 而且本来也没啥顺序。
    static NSInteger count = 0;
    return (count++)%[_allKeyOfJSON count];
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [TxTFactory getInstance];
}

@end
