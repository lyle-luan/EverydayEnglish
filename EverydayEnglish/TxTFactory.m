//
//  TxTFactory.m
//  EverydayEnglish
//
//  Created by Aaron on 10/26/14.
//  Copyright (c) 2014 ll. All rights reserved.
//

#import "TxTFactory.h"

@interface TxTFactory()

@property (nonatomic, readwrite) NSInteger indexTxt;
@property (nonatomic, readwrite) NSArray *allKeyOfJSON;
@property (nonatomic, readwrite) id sourceTxtContentJSON;
@property (nonatomic, readwrite) NSString *currentEnglish;

@end

@implementation TxTFactory

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
    
    _indexTxt = 0;
    _currentEnglish = nil;
}

- (NSString *)englishOriginal
{
    _currentEnglish = [_allKeyOfJSON firstObject];
    return _currentEnglish;
}

- (NSString *)chineseOriginal
{
    return [self chinese];
}

- (NSString *)englishForward
{
    _indexTxt = (_indexTxt+1)%[_allKeyOfJSON count];
    _currentEnglish = [_allKeyOfJSON objectAtIndex:_indexTxt];
    return _currentEnglish;
}

- (NSString *)englishBackward
{
    _indexTxt = _indexTxt -1;
    if (_indexTxt < 0)
    {
        _indexTxt = [_allKeyOfJSON count] - 1;
    }
    _currentEnglish = [_allKeyOfJSON objectAtIndex:_indexTxt];
    return _currentEnglish;
}

- (NSString *)chineseForward
{
    return [self chinese];
}

- (NSString *)chineseBackward
{
    return [self chinese];
}

- (NSString *)chinese
{
    return [_sourceTxtContentJSON objectForKey:_currentEnglish];
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [TxTFactory getInstance];
}

@end
