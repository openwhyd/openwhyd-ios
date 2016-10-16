//
//  UserCell.h
//  Whyd
//
//  Created by Damien Romito on 27/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


typedef NS_ENUM(NSUInteger, UserCellType) {
	UserCellTypeDefault = 0,
    UserCellTypeGenres = 1,
    UserCellTypeSearch = 3,
    UserCellTypePick = 4,
};


@interface UserCell : UITableViewCell

@property (nonatomic, weak) User *user;
@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL active;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withType:(UserCellType)type;
@end

@protocol UserCellDelegate <NSObject>

- (void)userCell:(UserCell *)cell isFollow:(BOOL)isFollow;

@end
