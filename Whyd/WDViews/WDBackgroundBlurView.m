//
//  WDBackgroundBlurView.m
//  Whyd
//
//  Created by Damien Romito on 05/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDBackgroundBlurView.h"
#import "MainViewController.h"

@implementation WDBackgroundBlurView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dynamic = NO;
        self.blurRadius = 21;
    }
    return self;
}

- (void)showInView:(UIView*)container
{
    [container addSubview:self];
}

- (void)show
{
    [[MainViewController manager].viewsContainer addSubview:self];
}


- (void) hide
{
    [self removeFromSuperview];
}



@end
