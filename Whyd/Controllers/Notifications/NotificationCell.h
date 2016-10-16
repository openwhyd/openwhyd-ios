//
//  NotificationCell.h
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Activity;
@class User;

@interface NotificationCell : UITableViewCell
@property (nonatomic, strong) Activity *activity;

@property (nonatomic, weak) id delegate;
@end

@protocol NotificationCellDelegate <NSObject>


- (void)notificationCell:(NotificationCell*)cell openUser:(User*)user;
@end