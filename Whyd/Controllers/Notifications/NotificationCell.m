//
//  NotificationCell.m
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "NotificationCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "WDHelper.h"
#import "OHAttributedLabel.h"
#import "UIImage+Additions.h"
#import "Activity.h"
#import "Playlist.h"
#import "User.h"

@interface NotificationCell()
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) OHAttributedLabel *infosLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *typeImage;
@property (nonatomic, strong) UIImageView *typeBackgroundImage;

@end
@implementation NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        //AVATAR
        self.avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 57, 57)];
        self.avatarButton.imageEdgeInsets = UIEdgeInsetsMake(11, 11, 11, 11);
        [self.avatarButton addTarget:self action:@selector(actionUser) forControlEvents:UIControlEventTouchUpInside];
        self.avatarButton.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.avatarButton];
        
        UIImageView *userMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PostUserMask"]];
        userMask.frame = CGRectMake(11, 11, 35, 35);
        [self.contentView addSubview:userMask];
        
        
        //IMAGE TRACK
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        self.typeBackgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        self.typeBackgroundImage.image = [UIImage imageNamed:@"NotificationBackgroundLeftTopCorner"];
        [self.imageView addSubview:self.typeBackgroundImage];
        self.typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 24, 24)];
        self.typeImage.contentMode = UIViewContentModeTopLeft;
        [self.typeBackgroundImage addSubview:self.typeImage];
       
        //TEXT
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:10];
        self.dateLabel.textColor = WDCOLOR_GRAY_TEXT;
        [self.contentView addSubview:self.dateLabel];
        
        self.infosLabel = [[OHAttributedLabel alloc] init];
        self.infosLabel.frame = CGRectMake(55, 11, INFO_WIDTH, 15);
        self.infosLabel.backgroundColor = UICOLOR_CLEAR;
        self.infosLabel.numberOfLines = 0;
        [self.contentView addSubview:self.infosLabel];

    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height + 1 );
    self.imageView.frame = CGRectMake(self.frame.size.width - 48, 6, 45, 45);
}


- (void)setActivity:(Activity *)activity
{
    _activity = activity;
    NSString *avatarImageString;
    
    
    avatarImageString = [activity.lastAuthor imageUrl:UserImageSizeSmall];
    
    self.infosLabel.attributedText = activity.attributedText;
    self.infosLabel.frame = CGRectMake(55, 11, INFO_WIDTH, 500);
    [self.infosLabel sizeToFit];
    
    self.dateLabel.text = activity.date;
    self.dateLabel.frame = CGRectMake(55, self.infosLabel.frame.size.height + self.infosLabel.frame.origin.y , COMMENT_WIDTH, 15);
    
    
    [self.avatarButton sd_setImageWithURL:[NSURL URLWithString:avatarImageString] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];

    //Image
    NSURL *imageURL;
    if(activity.activityType == ActivityTypeSendPlaylist)
    {
        imageURL = [NSURL URLWithString:[Playlist playlistFromHref:self.activity.href].imageUrl];
    }
    else if (activity.track.img ) {
            imageURL = [NSURL URLWithString:activity.track.img];
    }
    
    if(imageURL)
    {
        self.imageView.hidden = NO;
        [self.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageWithColor:WDCOLOR_GRAY_PLACEHOLDER_IMAGE]];
    }else
    {
        self.imageView.hidden = YES;
    }
    
    
    
    if (activity.activityType == ActivityTypeLike) {
        self.typeImage.image = [UIImage imageNamed:@"NotificationIconLikeSmall"];
        self.typeBackgroundImage.hidden = NO;
    }else if (activity.activityType == ActivityTypeRepost)
    {
        self.typeImage.image = [UIImage imageNamed:@"NotificationIconAddSmall"];
        self.typeBackgroundImage.hidden = NO;
    }else
    {
        self.typeBackgroundImage.hidden = YES;
    }

}

- (void)actionUser
{
    if (self.activity.lastAuthor) {
        [self.delegate notificationCell:self openUser:self.activity.lastAuthor];
    }
}



@end
