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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)swipeRight:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.8f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    //    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.englishLabel.layer addAnimation:transition forKey:@"animation"];
    [self.chineseLable.layer addAnimation:transition forKey:@"animation"];
    
    self.englishLabel.text = @"new english";
    self.chineseLable.text = @"new chinese";
}

- (IBAction)swipeUp:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;
    //    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.englishLabel.layer addAnimation:transition forKey:@"animation"];
    [self.chineseLable.layer addAnimation:transition forKey:@"animation"];
    
    self.englishLabel.text = @"new english";
    self.chineseLable.text = @"new chinese";
}

- (IBAction)swipeLeft:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.8f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromRight;
    //    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.englishLabel.layer addAnimation:transition forKey:@"animation"];
    [self.chineseLable.layer addAnimation:transition forKey:@"animation"];
    
    self.englishLabel.text = @"old english";
    self.chineseLable.text = @"old chinese";
}

- (IBAction)swipeDown:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    //    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.englishLabel.layer addAnimation:transition forKey:@"animation"];
    [self.chineseLable.layer addAnimation:transition forKey:@"animation"];
    
    self.englishLabel.text = @"old english";
    self.chineseLable.text = @"old chinese";
}

- (IBAction)doubleTap:(id)sender
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
