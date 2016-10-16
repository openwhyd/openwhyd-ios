//
//  WDActivityIndicatorView.m
//  Whyd
//
//  Created by Damien Romito on 28/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDActivityIndicatorView.h"

@implementation WDActivityIndicatorView

+ (WDActivityIndicatorView *) activityIndicatorInView:(UIView *)containerView
{
    WDActivityIndicatorView *view = [[self alloc] initInView:containerView];
    [containerView addSubview:view];
    return view;
}



- (id)initInView:(UIView *)containerView
{
    self = [self init];
    if (self) {
        self.frame = CGRectMake(containerView.frame.size.width / 2 - 40, containerView.frame.size.height/2 - 80, 80, 80);
    }
    return self;
}


- (instancetype)init
{
    self = [super initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if (self) {
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
        self.layer.cornerRadius = 5;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
