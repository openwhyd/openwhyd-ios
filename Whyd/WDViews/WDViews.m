//
//  WDViews.m
//  Whyd
//
//  Created by Damien Romito on 08/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDViews.h"

@implementation WDViews

+ (UIBarButtonItem *)barButtonItemBack
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setBackButtonBackgroundImage:[[UIImage imageNamed:@"NavBarPrevious"]  stretchableImageWithLeftCapWidth:12 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return backButton;
}
@end
