//
//  SettingsNotificationsCell.h
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsNotificationsCell : UITableViewCell

@property (nonatomic) NSString *pushKey;
@property (nonatomic) NSString *emailKey;
@property (nonatomic, weak) id delegate;

- (void) hasEmail:(BOOL)hasEmail forKey:(NSString *)emailKey;
- (void) hasPush:(BOOL)hasPush forKey:(NSString *)pushKey;

@end

@protocol SettingsNotificationCellDelegate <NSObject>

- (void)settingsNotifsKey:(NSString *)key isActive:(BOOL)isActive;
- (void)settingsActiveAPN;
@end