//
//  ViewController.m
//  EverydayEnglish
//
//  Created by ll on 14-10-1.
//  Copyright (c) 2014年 ll. All rights reserved.
//

#import "ViewController.h"
#import "TxTFactory.h"

typedef enum ORIENTATION
{
    SLIDE_NO = 0,
    SLIDE_RIGHT,
    SLIDE_LEFT,
    SLIDE_UP,
    SLIDE_DOWN,
}SLIDE_ORIENTATION;

static const CGFloat KEYBOARD_HEIGHT_MAX      = 270.0f;
static const NSInteger TEXTFILED_LEN_MAX      = 100;

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *somethingAboutMeLable;
@property (weak, nonatomic) IBOutlet UILabel *englishLabel;
@property (weak, nonatomic) IBOutlet UILabel *chineseLable;
@property (weak, nonatomic) IBOutlet UITextField *updateMessageTextField;
@property (nonatomic) CGSize kbSizeOriginal;
@property (nonatomic, readwrite) TxTFactory *txtFactoryInstance;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.kbSizeOriginal = CGSizeZero;
    self.updateMessageTextField.delegate = self;
    
    _txtFactoryInstance = [TxTFactory getInstance];
    
    self.englishLabel.text = _txtFactoryInstance.englishOriginal;
    self.chineseLable.text = _txtFactoryInstance.chineseOriginal;

    //读取整个文件太浪费内存了，怎么分片读取勒。
    
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
    [UIView transitionWithView:self.englishLabel duration:1 options:UIViewAnimationOptionTransitionCurlUp|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.englishLabel.text = _txtFactoryInstance.englishForward;
    } completion:^(BOOL isfinished){
        if (isfinished == YES)
        {
        }
        else
        {
        }
    }];
    
    [UIView transitionWithView:self.chineseLable duration:1 options:UIViewAnimationOptionTransitionCurlUp|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.chineseLable.text = _txtFactoryInstance.chineseForward;
    } completion:^(BOOL isfinished){
        if (isfinished == YES)
        {
        }
        else
        {
        }
    }];
}

- (IBAction)swipeBackward:(id)sender
{
    [UIView transitionWithView:self.englishLabel duration:1 options:UIViewAnimationOptionTransitionCurlDown|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.englishLabel.text = _txtFactoryInstance.englishBackward;
    } completion:^(BOOL isfinished){
        if (isfinished == YES)
        {
        }
        else
        {
        }
    }];
    
    [UIView transitionWithView:self.chineseLable duration:1 options:UIViewAnimationOptionTransitionCurlDown|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.chineseLable.text = _txtFactoryInstance.chineseBackward;
    } completion:^(BOOL isfinished){
        if (isfinished == YES)
        {
        }
        else
        {
        }
    }];
}

- (IBAction)doubleTap:(id)sender
{
    [self animationUpdateMessageTextFieldWithConstant:-KEYBOARD_HEIGHT_MAX withDuration:1];
    [self.updateMessageTextField becomeFirstResponder];
}

- (IBAction)updateMessage:(id)sender
{
    [self animationUpdateMessageTextFieldWithConstant:0 withDuration:0.8];
    [self.updateMessageTextField resignFirstResponder];
}

- (void)animationUpdateMessageTextFieldWithConstant:(CGFloat)anConstant withDuration:(NSTimeInterval)anDuration
{
    //UIKeyboardAnimationDurationUserInfoKey，用来改变键盘弹出时间，使键盘和textfield同时出现？
    [self replaceUIView:self.updateMessageTextField withAttribute:NSLayoutAttributeCenterY withConstant:anConstant];
    
    [UIView animateWithDuration:anDuration delay:0 options:UIViewAnimationOptionTransitionNone|UIViewAnimationOptionCurveEaseInOut animations:^{
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0)
    {
        //可以删除
        return YES;
    }
    
    if ((textField.text.length-range.length+string.length) > TEXTFILED_LEN_MAX)
    {
        //可以选择部分输入替换
        return NO;
    }
    else
    {
        //不限制联想造成输入超长，因为不用那么严格。
        //联想超长是指：还能再输入一个字符，比如输入y，系统联想提示you，点击提示的you，you三个字符都输入到输入框内，超过最长限制。
        return YES;
    }
}

-(void)keyboardDidChangeFrame:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSizeNow = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (CGSizeEqualToSize(self.kbSizeOriginal, CGSizeZero))
    {
        NSLog(@"show");
        [self animationUpdateMessageTextFieldWithConstant:-(kbSizeNow.height) withDuration:kbSizeNow.height/KEYBOARD_HEIGHT_MAX];
        [self.updateMessageTextField becomeFirstResponder];
        
        self.kbSizeOriginal = kbSizeNow;
        
        return;
    }
    else if (CGSizeEqualToSize(self.kbSizeOriginal, kbSizeNow) == YES)
    {
        NSLog(@"hide");
        
        self.kbSizeOriginal = CGSizeZero;
    }
    else
    {
        NSLog(@"change");
        
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
