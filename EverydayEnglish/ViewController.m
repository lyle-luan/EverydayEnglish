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
    
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [self.somethingAboutMeLable addGestureRecognizer:doubleRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panRecognizer];

}

- (void)doubleTap:(id)sender
{
    NSLog(@"view double tap");
}

- (void)pan:(id)sender
{
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)sender;
    switch (panRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"UIGestureRecognizerStateBegan");
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        {
            NSLog(@"UIGestureRecognizerStateCancelled");
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"UIGestureRecognizerStateChanged");
            CGPoint currentPoint = [panRecognizer translationInView:self.view];
            NSLog(@"%f, %f", currentPoint.x, currentPoint.y);
            self.englishLabel.center = CGPointMake(currentPoint.x+self.englishLabel.center.x, currentPoint.y+self.englishLabel.center.y);
            [panRecognizer setTranslation:CGPointZero inView:self.view];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"UIGestureRecognizerStateEnded");
            break;
        }
        default:
        {
            NSLog(@"UIGestureRecognizerStateUnkown");
            break;
        }
    }
//    CGPoint currentPoint = [panRecognizer translationInView:self.view];
//    NSLog(@"orientation:%d", [self orientationOfSlide:currentPoint]);
}

- (SLIDE_ORIENTATION)orientationOfSlide: (CGPoint)newPoint
{
    static CGPoint originalPoint = {0, 0};
    
    if (CGPointEqualToPoint(newPoint, originalPoint) == YES)
    {
        return SLIDE_NO;
    }
    
    CGFloat xOffset = newPoint.x - originalPoint.x;
    CGFloat yOffset = newPoint.y - originalPoint.y;
    if (xOffset == 0)
    {
        if (yOffset > 0)
        {
            originalPoint = newPoint;
            return SLIDE_DOWN;
        }
        else
        {
            originalPoint = newPoint;
            return SLIDE_UP;
        }
    }
    if (yOffset == 0)
    {
        if (xOffset > 0)
        {
            originalPoint = newPoint;
            return SLIDE_RIGHT;
        }
        else
        {
            originalPoint = newPoint;
            return SLIDE_LEFT;
        }
    }
    
    CGFloat tanRadians = yOffset / xOffset; //tanRadians,yOffset,xOffset; none is 0
    tanRadians = tanRadians>0 ? tanRadians : -tanRadians;
    
    if ((tanRadians<=1) && (tanRadians>0))
    {
        if (xOffset < 0)
        {
            originalPoint = newPoint;
            return SLIDE_LEFT;
        }
        else
        {
            originalPoint = newPoint;
            return SLIDE_RIGHT;
        }
    }
    else
    {
        if (yOffset < 0)
        {
            originalPoint = newPoint;
            return SLIDE_UP;
        }
        else
        {
            originalPoint = newPoint;
            return SLIDE_DOWN;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
