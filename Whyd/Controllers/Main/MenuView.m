//
//  MenuView.m
//  Whyd
//
//  Created by Damien Romito on 19/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "MenuView.h"
#import "MainViewController.h"
#import "SettingsViewController.h"
#import "WDHelper.h"
#import "WDBackgroundBlurView.h"
#import "WDNavigationController.h"

@interface MenuView()
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, strong) UIButton *notificationsCount;
@property (nonatomic, strong) WDBackgroundBlurView *backgroundView;
@end
@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
        self.backgroundColor = WDCOLOR_BLACK_TRANSPARENT;

        UIButton* closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 25, 50, 35)];
        [closeButton setImage:[UIImage imageNamed:@"MenuButtonClose"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuWhydLogo"]];
        CGRect frame = logoImage.frame;
        frame.origin.x = self.frame.size.width / 2 - frame.size.width /2;
        frame.origin.y = 55;
        logoImage.frame = frame;
        [self addSubview:logoImage];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionClose)];
        self.userInteractionEnabled = YES;
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        
        [[MainViewController manager].viewControllers enumerateObjectsUsingBlock:^(UIViewController *item, NSUInteger index, BOOL *stop)
        {

            UIButton* button = [[UIButton alloc] init];
            [button setTitle:item.title forState:UIControlStateNormal];
            
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
            button.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:27];
            [button sizeToFit];
            button.frame = CGRectMake(0, 130 + index*62, self.frame.size.width, 62);
            [button setTitleColor:WDCOLOR_BLACK_LIGHT forState:UIControlStateNormal];
            [button setTitleColor:UICOLOR_WHITE forState:UIControlStateHighlighted];
            [button setTitleColor:UICOLOR_WHITE forState:UIControlStateSelected];


            [button setBackgroundImage:[UIImage imageNamed:@"MenuIconActive"] forState:UIControlStateSelected ];
            [button setBackgroundImage:[UIImage imageNamed:@"MenuIconActive"] forState:UIControlStateHighlighted ];
            [button addTarget:self action:@selector(actionTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(actionTouchDown) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(actionTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
            [button addTarget:self action:@selector(actionTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];


            button.tag = index+1;
            
            if ([item.title isEqualToString:  NSLocalizedString(@"Notifications", nil)]) {
                self.notificationsCount = [[UIButton alloc] initWithFrame:CGRectMake(190, 16, 0, 0)];
                self.notificationsCount.userInteractionEnabled = NO;
                self.notificationsCount.titleEdgeInsets = UIEdgeInsetsMake(3, 5, 0, 5);
                [self.notificationsCount setBackgroundImage:[[UIImage imageNamed:@"MenuButtonNotification"] stretchableImageWithLeftCapWidth:15 topCapHeight:0] forState:UIControlStateNormal];
                self.notificationsCount.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_4];

                [button addSubview:self.notificationsCount];
            }
            
            
            [self addSubview:button];
            
            if (index == 0) {
                self.currentButton = button;
            }
        }];
        
        
        UIView *bottomButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 77, self.frame.size.width, 77)];
        bottomButtonContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:bottomButtonContainer];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.frame.size.width - 50, .5)];
        separatorView.backgroundColor = RGBCOLOR(38, 42, 48);
        [bottomButtonContainer addSubview:separatorView];
        
        UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, 77)];
        settingsButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_5];
        settingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        settingsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 35, 0, 0);
        settingsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 25, 2, 0);
        [settingsButton setTitleColor:RGBCOLOR(132, 140, 154) forState:UIControlStateNormal];
        [settingsButton setTitle:NSLocalizedString(@"Settings", nil) forState:UIControlStateNormal];
        [settingsButton setImage:[UIImage imageNamed:@"MenuButtonSettings"] forState:UIControlStateNormal];
        [settingsButton addTarget:self action:@selector(actionSettings) forControlEvents:UIControlEventTouchUpInside];
        [bottomButtonContainer addSubview:settingsButton];
        
        UIButton *addFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, 77)];
        addFriendsButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_5];
        addFriendsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        addFriendsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        addFriendsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 6, 0);
        [addFriendsButton setTitleColor:RGBCOLOR(132, 140, 154) forState:UIControlStateNormal];
        [addFriendsButton setTitle:NSLocalizedString(@"AddFriends", nil) forState:UIControlStateNormal];
        [addFriendsButton setImage:[UIImage imageNamed:@"MenuButtonAddFriends"] forState:UIControlStateNormal];
        [addFriendsButton addTarget:self action:@selector(actionAddFriends) forControlEvents:UIControlEventTouchUpInside];
       // [bottomButtonContainer addSubview:addFriendsButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications:) name:NOTIFICATION_NOTIFICATIONS_UPDATE object:nil];

        
    }
    return self;
}

- (void)selectButtonAtIndex:(NSUInteger)index
{
    self.currentButton = (UIButton *)[self viewWithTag:index+1];
}

#pragma mark Actions

- (void)actionOpen
{


    self.backgroundView = [[WDBackgroundBlurView alloc] initWithFrame:self.frame];
    self.backgroundView.alpha = 0;
    [self.backgroundView show];

    self.transform = CGAffineTransformMakeTranslation(0, 10);
    [UIView animateWithDuration:ANIMATION_DISPLAY_DURATION animations:^{
        self.alpha = 1;
        [MainViewController manager].bottomPlayer.alpha = 0;
        self.backgroundView.alpha = 1;
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}


- (void)actionClose
{
    [UIView animateWithDuration:ANIMATION_DISPLAY_DURATION animations:^{
        self.alpha = 0;
        self.backgroundView.alpha = 0;
        [MainViewController manager].bottomPlayer.alpha = 1;

    } completion:^(BOOL finished) {
        [self.backgroundView hide];
    }];

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}


- (void)actionTouchDown
{
    self.currentButton.selected = NO;
}


- (void)actionTouchUpOutside
{
    self.currentButton.selected = YES;
}


- (void)actionTouchDragOutside
{
    self.currentButton.selected = YES;
}


- (void)actionTouchUpInside:(UIButton*)button
{

    self.currentButton = button;
    [[MainViewController manager] displayViewControllerAtIndex: button.tag-1];
    [self actionClose];

}

- (void)actionSettings
{

    SettingsViewController *vc = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    
    [WDHelper runAfterDelay:0.25 block:^{
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    }];
    [[MainViewController manager] presentViewController:nav animated:YES completion:nil];
    

}

- (void)actionAddFriends
{
    
}

- (void)updateNotifications:(NSNotification *)notification
{

    NSInteger notifsCount = [[notification.userInfo valueForKey:NOTIFICATION_NOTIFICATIONS_UPDATE_COUNT_KEY] integerValue];
    if(notifsCount )
    {
        self.notificationsCount.hidden = NO;
        [self.notificationsCount setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)notifsCount] forState:UIControlStateNormal];
        [self.notificationsCount sizeToFit];
        CGRect frame = self.notificationsCount.frame;
        frame.size.width = frame.size.width + self.notificationsCount.titleEdgeInsets.left *2;
        self.notificationsCount.frame = frame;
    }else
    {
        self.notificationsCount.hidden = YES;
    }

}



#pragma Setters

- (void)setNotifCount:(NSUInteger)notifsCount
{
        
}

- (void)setCurrentButton:(UIButton *)currentButton
{
    if (_currentButton) {
        self.currentButton.selected = NO;
    }
    _currentButton = currentButton;
    self.currentButton.selected = YES;
}



@end
