//
//  CommentCell.m
//  Whyd
//
//  Created by Damien Romito on 24/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TrackCommentCell.h"
#import "UIImageView+AFNetworking.h"

@interface TrackCommentCell()
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *commentLabel;

@end
@implementation TrackCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = WDCOLOR_GRAY_BG_LIGHT;
        self.clipsToBounds = YES;
        self.contentView.backgroundColor = WDCOLOR_GRAY_BG;
        self.contentView.layer.borderWidth = 1.;
        self.contentView.layer.borderColor = WDCOLOR_GRAY_BORDER.CGColor;
        
        UIImageView *userMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrackPageUserMask"]];
        [self.imageView addSubview:userMask];
        
        self.userButton = [[UIButton alloc] initWithFrame:CGRectMake(55, 0, 220, 35)];
        self.userButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        self.userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.userButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.userButton setTitleColor:WDCOLOR_BLUE_LINK forState:UIControlStateNormal];
        self.userButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:13];
        [self.contentView addSubview:self.userButton];
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.frame = CGRectMake(55, 33, 230, 15);
        self.commentLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:13];
        self.commentLabel.backgroundColor = COLOR_CLEAR;
        self.commentLabel.textColor = RGBCOLOR(78, 84, 88);
        self.commentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.commentLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(11, 0, 297, self.frame.size.height+1);
    self.imageView.frame = CGRectMake(11, 15, 35, 35);
}

- (void)setComment:(Comment *)comment
{
    NSURL *avatarURL = [NSURL URLWithString:[comment.user imageUrl:UserImageSizeSmall]];
    [self.imageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
    [self.userButton setTitle:comment.user.name forState:UIControlStateNormal];
    self.commentLabel.text = comment.text;
    [self.commentLabel sizeToFit];
}


@end
