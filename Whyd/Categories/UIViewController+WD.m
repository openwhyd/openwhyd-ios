//
//  UIViewController+WD.m
//  Whyd
//
//  Created by Damien Romito on 10/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "UIViewController+WD.h"
#import "MainViewController.h"
#import "UIImage+Additions.h"
#import "WDViews.h"

@implementation UIViewController(WD)

- (void) makeAsMainViewController
{
    
    self.view.backgroundColor = UICOLOR_WHITE;
    
    
    //SearchButton
    UIBarButtonItem *searchTrackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarSearch"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:[MainViewController manager]  action:@selector(actionOpenSearch)];
    self.navigationItem.rightBarButtonItem = searchTrackButton;
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    
   [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;

    UIGestureRecognizer *titleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionScrollTop)];
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setUserInteractionEnabled:YES];
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] addGestureRecognizer:titleGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications:) name:NOTIFICATION_NOTIFICATIONS_UPDATE object:nil];
    [self displayNotifs:[MainViewController manager].hasNotifs];
}

- (void)actionScrollTop
{
    //DLog(@"taptaptaptaptaptpatpaptpap");
}

- (void)updateNotifications:(NSNotification *)notification
{
    [self displayNotifs:[[notification.userInfo valueForKey:NOTIFICATION_NOTIFICATIONS_UPDATE_COUNT_KEY] integerValue]];
}

- (void)displayNotifs:(BOOL)isDisplay
{
    UIImage *image ;
    if (isDisplay) {
        image = [[UIImage imageNamed:@"NavbarMenuNotification"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else
    {
        image = [UIImage imageNamed:@"NavbarMenu"];
    }
   
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:[MainViewController manager] action:@selector(actionOpenMenu)];
    self.navigationItem.leftBarButtonItem = menuButton;
}



@end
