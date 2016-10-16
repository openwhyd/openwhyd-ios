//
//  SettingsSharingCell.h
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SharingType) {
    
	SharingTypeFacebook = 0,
    SharingTypeTwitter = 1,
};

@interface SettingsSharingCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSharingType:(SharingType)sharingType;

@end
