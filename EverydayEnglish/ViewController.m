//
//  ViewController.m
//  EverydayEnglish
//
//  Created by ll on 14-10-1.
//  Copyright (c) 2014年 ll. All rights reserved.
//

#import "ViewController.h"

typedef enum ORIENTATION
{
    SLIDE_NO = 0,
    SLIDE_RIGHT,
    SLIDE_LEFT,
    SLIDE_UP,
    SLIDE_DOWN,
}SLIDE_ORIENTATION;

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *somethingAboutMeLable;
@property (weak, nonatomic) IBOutlet UILabel *englishLabel;
@property (weak, nonatomic) IBOutlet UILabel *chineseLable;
@property (weak, nonatomic) IBOutlet UITextField *updateMessageTextField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSArray *ducumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = ducumentPaths.firstObject;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *englishChineseTextPath = [documentDirectory stringByAppendingPathComponent:@"englishChinese.txt"];
//    if ([fileManager fileExistsAtPath:englishChineseTextPath] == NO)
//    {
//        if ([fileManager createDirectoryAtPath:englishChineseTextPath withIntermediateDirectories:NO attributes:nil error:nil] == YES)
//        {
//            NSLog(@"success");
//        }
//        else
//        {
//            NSLog(@"failed");
//        }
//    }
//    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cacheDirectory = cachePaths.firstObject;
}

- (IBAction)swipeForward:(id)sender
{
    [self swipeForwardEnglish:sender];
    [self swipeForwardChinese:sender];
}

- (IBAction)swipeBackward:(id)sender
{
    [self swipeBackwardEnglish:sender];
    [self swipeBackwardChinese:sender];
}

- (void)swipeForwardEnglish:(id)sender
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.englishLabel cache:YES];
    [UIView commitAnimations];
    
    self.englishLabel.text = @"new english";
}

- (void)swipeForwardChinese:(id)sender
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.chineseLable cache:YES];
    [UIView commitAnimations];
    
    self.chineseLable.text = @"new chinese";
}

- (void)swipeBackwardEnglish:(id)sender
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.englishLabel cache:YES];
    self.englishLabel.text = @"old english";
    [UIView commitAnimations];
}

- (void)swipeBackwardChinese:(id)sender
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.chineseLable cache:YES];
    self.chineseLable.text = @"old chinese";
    [UIView commitAnimations];
}

- (IBAction)doubleTap:(id)sender
{
    [self.updateMessageTextField becomeFirstResponder];
}

- (IBAction)updateMessage:(id)sender
{
    [self.updateMessageTextField resignFirstResponder];
}

- (IBAction)editMessage:(id)sender
{
    //被键盘推上去。
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:5.0f];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.updateMessageTextField.frame = CGRectMake(0.0f, 0.0f, 100.0f, 100.0f);
    [UIView commitAnimations];
}

- (IBAction)updateMessageTextFieldEditingChanged:(id)sender
{
    CGRect frame = self.updateMessageTextField.frame;
    
    NSLog(@"%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
