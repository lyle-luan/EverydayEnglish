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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *somethingAboutMeLable;
@property (weak, nonatomic) IBOutlet UILabel *englishLabel;
@property (weak, nonatomic) IBOutlet UILabel *chineseLable;
@property (weak, nonatomic) IBOutlet UITextField *updateMessage;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [UIView commitAnimations];
    
    self.englishLabel.text = @"old english";
}

- (void)swipeBackwardChinese:(id)sender
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.chineseLable cache:YES];
    [UIView commitAnimations];
    
    self.chineseLable.text = @"old chinese";
}

- (IBAction)doubleTap:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    
    self.updateMessage.hidden = NO;
    self.somethingAboutMeLable.hidden = YES;
    [self.somethingAboutMeLable.layer addAnimation:transition forKey:@"animation"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
