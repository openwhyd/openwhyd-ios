//
//  SettingsNotificationsCell.m
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsNotificationsCell.h"
#import "WDHelper.h"


@interface SettingsNotificationsCell()
@property (nonatomic, strong) UIButton* emailButton;
@property (nonatomic, strong) UIButton* pushButton;
@end
@implementation SettingsNotificationsCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];

        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_4];
        self.textLabel.textColor = WDCOLOR_BLUE_DARK;
        
        self.emailButton = [[UIButton alloc] initWithFrame:CGRectMake(window.frame.size.width - 80, 0, 40, self.frame.size.height)];
        [self.emailButton setImage:[UIImage imageNamed:@"settingUISettingNotificationButtonEmailDisable"] forState:UIControlStateNormal];
        [self.emailButton setImage:[UIImage imageNamed:@"settingUISettingNotificationButtonEmailSelected"] forState:UIControlStateSelected];
        [self.emailButton setImage:[UIImage imageNamed:@"settingUISettingNotificationButtonEmailDisable"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.emailButton setImage:[UIImage imageNamed:@"settingUISettingNotificationButtonEmailSelected"] forState:UIControlStateNormal|UIControlStateHighlighted];
        [self.emailButton addTarget:self action:@selector(actionEmail) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.emailButton];
        
        self.pushButton = [[UIButton alloc] initWithFrame:CGRectMake(window.frame.size.width - 40, 0, 40, self.frame.size.height)];
        [self.pushButton setImage:[UIImage imageNamed:@"SettingNotificationButtonMobileDisable"] forState:UIControlStateNormal];
        [self.pushButton setImage:[UIImage imageNamed:@"SettingNotificationButtonMobileSelected"] forState:UIControlStateSelected];
        [self.pushButton setImage:[UIImage imageNamed:@"SettingNotificationButtonMobileDisable"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.pushButton setImage:[UIImage imageNamed:@"SettingNotificationButtonMobileSelected"] forState:UIControlStateNormal|UIControlStateHighlighted];
        [self.pushButton addTarget:self action:@selector(actionPush) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.pushButton];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(11, 1, self.frame.size.width, self.frame.size.height);
}



- (void)hasEmail:(BOOL)hasEmail forKey:(NSString *)emailKey
{
    self.emailButton.hidden = NO;
    self.emailButton.selected = hasEmail;
    _emailKey = emailKey;
    
}
- (void)hasPush:(BOOL)hasPush forKey:(NSString *)pushKey
{
    self.pushButton.hidden = NO;
    self.pushButton.selected = hasPush;
    _pushKey = pushKey;
}


- (void)actionEmail
{
    self.emailButton.selected = !self.emailButton.selected;
    [self.delegate settingsNotifsKey:self.emailKey isActive:self.emailButton.selected];
}

- (void)actionPush
{
    if(![WDHelper apnIsAlreadyAsked])
    {
        [self.delegate settingsActiveAPN];
        
    }else
    {
        self.pushButton.selected = !self.pushButton.selected;
        [self.delegate settingsNotifsKey:self.pushKey isActive:self.pushButton.selected];
    }
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
    self.emailButton.hidden = YES;
    self.pushButton.hidden = YES;
}


@end
