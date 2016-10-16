//
//  WDAlertView.m
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDAlertView.h"
#import "WDHelper.h"
#import "WDBackgroundBlurView.h"
#import "MainViewController.h"

@interface WDAlertView()
@property (nonatomic, strong) WDBackgroundBlurView *backgroundView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic) WDAlertType type;
@property (nonatomic) NSString *titleString;
@property (nonatomic) NSString *infoString;

@end
@implementation WDAlertView


+ (WDAlertView *)showWithType:(WDAlertType)type
{
    return [self showWithType:type andInfoString:nil];
}

+ (WDAlertView *)showWithType:(WDAlertType)type andInfoString:(NSString*)infoString{
    return [self showWithType:type title:nil andInfoString:infoString];
}

+ (WDAlertView *)showWithType:(WDAlertType)type title:(NSString*)title andInfoString:(NSString*)infoString
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];

    WDAlertView *alert = [[WDAlertView alloc] initWithType:type title:title andString:infoString];
    if (infoString) {
        alert.infoString = infoString;
    }
    
    
    [window addSubview:alert];
//    [[MainViewController manager].view addSubview:alert];
    
    alert.containerView.alpha = 0;
    
    alert.backgroundView = [[WDBackgroundBlurView alloc] initWithFrame:alert.frame];
    alert.backgroundView.alpha = 0;
    
    
    if ([MainViewController manager].searchContainer.hidden) {
        [alert.backgroundView show];
    }else
    {
        [alert.backgroundView showInView:[MainViewController manager].searchContainer];
    }
    
    alert.containerView.transform = CGAffineTransformMakeScale(1.2, 1.1);
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        alert.backgroundView.alpha = 1;
        alert.containerView.alpha = 1;
        
        alert.containerView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        
    }];
    
    return alert;
    
    
}



- (id)initWithType:(WDAlertType)type title:(NSString*)title andString:(NSString*)string
{
    self = [super initWithFrame:[MainViewController manager].view.frame];
    if (self) {
        
        self.type = type;
        self.backgroundColor = WDCOLOR_BLACK_TRANSPARENT;

        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = UICOLOR_WHITE;
        self.containerView.clipsToBounds = YES;
        self.containerView.layer.cornerRadius = CORNER_RADIUS;
        
        [self addSubview:self.containerView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5];
        titleLabel.textColor = WDCOLOR_BLACK;
        [self.containerView addSubview:titleLabel];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
        label.textColor = WDCOLOR_BLUE_DARK;
        label.numberOfLines = 0;
        [self.containerView addSubview:label];
        
        UIImageView *illustrationImage = [[UIImageView alloc] init];
        
        [self.containerView addSubview:illustrationImage];

        UIButton *noButton = [[UIButton alloc] init];
        noButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        [noButton setTitleColor:WDCOLOR_GRAY_DARK forState:UIControlStateNormal];
        noButton.layer.borderColor = WDCOLOR_GRAY_LIGHT.CGColor;
        noButton.layer.borderWidth = 1;
        noButton.layer.cornerRadius = CORNER_RADIUS;
        [noButton setTitle:NSLocalizedString(@"NoThanks", nil) forState:UIControlStateNormal];
        [noButton addTarget:self action:@selector(actionNo) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:noButton];
        
    
        

        UIButton *yesButton = [[UIButton alloc] init];
        [yesButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
        yesButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        yesButton.backgroundColor = WDCOLOR_BLUE;
        yesButton.layer.cornerRadius = CORNER_RADIUS;
        yesButton.clipsToBounds = YES;
        [yesButton addTarget:self action:@selector(actionYes) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:yesButton];
        
        self.containerView.frame = CGRectMake((self.frame.size.width - 298) / 2, self.frame.size.height /2 - 102, 298, 205);

        if (type == WDAlertTypeAPN) {
            titleLabel.frame = CGRectMake(0, 37, self.containerView.frame.size.width, 20);
            if ([WDHelper manager].currentUser.nbPosts <=1) {
                titleLabel.text =  NSLocalizedString(@"NotificationsAlertFirstPost", nil) ;
            }else
            {
                titleLabel.text =  NSLocalizedString(@"AlertTitleTrack", nil) ;
            }

            illustrationImage.image = [UIImage imageNamed:@"NotificationMessageIconSmarphone"];
            illustrationImage.frame = CGRectMake(30, 75, 29, 39);
            
            label.frame = CGRectMake(70, 76, 200, 40);
            label.text = NSLocalizedString(@"NotificationsAlertBeAlerted", nil);
            
            [yesButton setTitle:NSLocalizedString(@"NotifyMe", nil) forState:UIControlStateNormal];

            
            noButton.frame = CGRectMake(46, 140, 94, 34);
            yesButton.frame = CGRectMake(153, 140, 94, 34);
            
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_APN_POST_ASKED];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }else if (type == WDAlertTypeRate)
        {
            titleLabel.frame = CGRectMake(0, 20, self.containerView.frame.size.width, 20);
            titleLabel.text =  NSLocalizedString(@"NotificationsAlertRateTitle", nil) ;
            
            illustrationImage.image = [UIImage imageNamed:@"StreamIconStarRate"];
            illustrationImage.frame = CGRectMake(self.containerView.frame.size.width/2 - 55, 50, 110, 19);
            
            label.frame = CGRectMake(35, 76, 250, 70);
            label.text = NSLocalizedString(@"NotificationsAlertRate", nil);
            label.textAlignment = NSTextAlignmentCenter;
            [yesButton setTitle:NSLocalizedString(@"NotificationsAlertRateYes", nil) forState:UIControlStateNormal];
            yesButton.frame = CGRectMake(158, 150, 107, 34);
            
            noButton.frame = CGRectMake(46, 150, 94, 34);

            
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_RATE_ASKED];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }
        else if (type == WDAlertTypeUpdate)
        {
            titleLabel.frame = CGRectMake(0, 20, self.containerView.frame.size.width, 20);
            titleLabel.text =  NSLocalizedString(@"AlertUpdateTitle", nil) ;
            
            label.frame = CGRectMake(35, 46, 250, 70);
            label.text = NSLocalizedString(@"AlertUpdate", nil);
            label.textAlignment = NSTextAlignmentCenter;
            [yesButton setTitle:NSLocalizedString(@"AlertUpdateOk", nil) forState:UIControlStateNormal];
            
            noButton.frame = CGRectMake(46, 140, 94, 34);
            yesButton.frame = CGRectMake(153, 140, 94, 34);
            
        }else if (type == WDAlertTypeInfo){
            
            titleLabel.frame = CGRectMake(0, 20, self.containerView.frame.size.width, 20);
            titleLabel.text = title;
            
            label.frame = CGRectMake(20, 45, 270, 90);
            NSLog(@"==> %@", self.infoString);
            label.text = string;
            label.textAlignment = NSTextAlignmentLeft;
            [yesButton setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
            yesButton.frame = CGRectMake(90, 150, 107, 34);
            
            noButton.hidden = YES;
        }
        
    }
    return self;
}



- (void)actionYes
{
    if (self.type == WDAlertTypeAPN) {
        
        [WDHelper apnSet];
    }else if (self.type == WDAlertTypeRate)
    {
        [Flurry logEvent:FLURRY_RATE_POPUP_YES];
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=874380201"];
        [[UIApplication sharedApplication] openURL:url];
    }else if (self.type == WDAlertTypeUpdate)
    {
        [Flurry logEvent:FLURRY_UPDATE_ACCEPTED];

        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.com/apps/whyd"];
        [[UIApplication sharedApplication] openURL:url];
        
    }
    
    [self actionClose];
    
}


- (void)actionNo
{
    if (self.type == WDAlertTypeAPN) {
        
        [Flurry logEvent:FLURRY_ALLOWNOTIF_POPUP_NO];
    }else if (self.type == WDAlertTypeRate)
    {
        [Flurry logEvent:FLURRY_RATE_POPUP_SKIP];
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_RATE_ASKED_SKIP];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else if (self.type == WDAlertTypeUpdate)
    {
        [Flurry logEvent:FLURRY_UPDATE_SKIP];

        [[NSUserDefaults standardUserDefaults] setValue:self.infoString forKey:USERDEFAULT_UPDATE_VER_SKIP];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    [self actionClose];
}


- (void)actionClose
{
    if ([self.delegate respondsToSelector:@selector(WDAlertViewClosed)]) {
        [self.delegate WDAlertViewClosed];
    }
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.backgroundView.alpha = 0;
        self.containerView.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeScale(0.6, 0.6);

    } completion:^(BOOL finished) {
        [self.backgroundView hide];

         [self removeFromSuperview];
    }];
   
}




@end
