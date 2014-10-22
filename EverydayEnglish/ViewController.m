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

CGFloat KEYBOARD_HEIGHT_MAX      = 270.0f;

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *somethingAboutMeLable;
@property (weak, nonatomic) IBOutlet UILabel *englishLabel;
@property (weak, nonatomic) IBOutlet UILabel *chineseLable;
@property (weak, nonatomic) IBOutlet UITextField *updateMessageTextField;
@property (nonatomic) CGSize kbSizeOriginal;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.kbSizeOriginal = CGSizeZero;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    NSLog(@"doubleTap");
    [self animationUpdateMessageTextFieldWithConstant:-KEYBOARD_HEIGHT_MAX withDuration:1];
    [self.updateMessageTextField becomeFirstResponder];
}

- (IBAction)updateMessage:(id)sender
{
    [self.updateMessageTextField resignFirstResponder];
}

- (void)animationUpdateMessageTextFieldWithConstant:(CGFloat)anConstant withDuration:(NSTimeInterval)anDuration
{
    [self replaceUIView:self.updateMessageTextField withAttribute:NSLayoutAttributeCenterY withConstant:anConstant];
    
    [UIView animateWithDuration:anDuration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL isfinished){
        if (isfinished == YES)
        {
        }
        else
        {
            NSLog(@"TODO://");
        }
    }];
    
}

- (void)replaceUIView: (UIView *)aUIView withAttribute: (int)anAttribute withConstant: (CGFloat)anConstant
{
    for (NSLayoutConstraint *constraint in aUIView.superview.constraints)
    {
        if (constraint.firstItem == aUIView && constraint.firstAttribute == anAttribute)
        {
            constraint.constant = anConstant;
            NSLog(@"move view");
        }
    }
}

- (void)makeAboveAnimationActiveWithDuration: (NSTimeInterval)anDuration
{
    [UIView animateWithDuration:anDuration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL isfinished){
        if (isfinished == YES)
        {
//            [self.updateMessageTextField becomeFirstResponder];
        }
        else
        {
            NSLog(@"TODO://");
        }
    }];
}

- (IBAction)editMessage:(id)sender
{
    //被键盘推上去。
    NSLog(@"editMessage");
}

- (IBAction)updateMessageTextFieldEditingChanged:(id)sender
{
    NSLog(@"updateMessageTextFieldEditingChanged");
}

-(void)keyboardDidChangeFrame:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSizeNow = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (CGSizeEqualToSize(self.kbSizeOriginal, CGSizeZero))
    {
        NSLog(@"show");
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSizeNow = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        [self animationUpdateMessageTextFieldWithConstant:-(kbSizeNow.height) withDuration:kbSizeNow.height/KEYBOARD_HEIGHT_MAX];
        [self.updateMessageTextField becomeFirstResponder];
        
        self.kbSizeOriginal = kbSizeNow;
        
        return;
    }
    else if (CGSizeEqualToSize(self.kbSizeOriginal, kbSizeNow) == YES)
    {
        NSLog(@"hide");
        
        [self animationUpdateMessageTextFieldWithConstant:0 withDuration:0.5];
        
        self.kbSizeOriginal = CGSizeZero;
    }
    else
    {
        NSLog(@"change");
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSizeNow = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        if (self.kbSizeOriginal.height > kbSizeNow.height)
        {
            [self animationUpdateMessageTextFieldWithConstant:-(kbSizeNow.height) withDuration:kbSizeNow.height/KEYBOARD_HEIGHT_MAX];
        }
        else
        {
            [self animationUpdateMessageTextFieldWithConstant:-(kbSizeNow.height+1) withDuration:kbSizeNow.height/KEYBOARD_HEIGHT_MAX];
        }
        [self.updateMessageTextField becomeFirstResponder];
        
        self.kbSizeOriginal = kbSizeNow;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
