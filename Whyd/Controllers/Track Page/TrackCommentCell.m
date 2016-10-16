//
//  CommentCell.m
//  Whyd
//
//  Created by Damien Romito on 24/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TrackCommentCell.h"
#import "UIImageView+WebCache.h"
#import "WDHelper.h"
#import "UserViewController.h"



@interface TrackCommentCell()
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) OHAttributedLabel *commentLabel;

@end
@implementation TrackCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UICOLOR_WHITE;
        
        UIImageView *userMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PostUserMask"]];
        [self.imageView addSubview:userMask];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionUser)];
        self.imageView.userInteractionEnabled = YES;
        [self.imageView addGestureRecognizer:tap];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
    
        
        self.contentView.layer.borderColor = WDCOLOR_WHITE_DARK.CGColor;
        self.contentView.layer.borderWidth = .5;
        
        self.userButton = [[UIButton alloc] initWithFrame:CGRectMake(55, 0, 220, 35)];
        self.userButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        self.userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.userButton addTarget:self action:@selector(actionUser) forControlEvents:UIControlEventTouchUpInside];
        self.userButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        [self.userButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
        [self.contentView addSubview:self.userButton];
        
        self.commentLabel = [[OHAttributedLabel alloc] init];
        self.commentLabel.frame = CGRectMake(55, 33, COMMENT_WIDTH, 15);
        self.commentLabel.backgroundColor = UICOLOR_CLEAR;
        self.commentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.commentLabel];
        

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(11, 15, 35, 35);
    self.contentView.frame = CGRectMake(-1, -1, 322, self.frame.size.height + 1 );
    
    [self.contentView bringSubviewToFront:self.imageView];
    
}


- (void)setComment:(Comment *)comment
{
    _comment = comment;
    NSURL *avatarURL = [NSURL URLWithString:[comment.user imageUrl:UserImageSizeSmall]];
    [self.imageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
    [self.userButton setTitle:comment.user.name forState:UIControlStateNormal];
    [self.userButton sizeToFit];
    self.userButton.frame = CGRectMake(55, 0, self.userButton.frame.size.width, 35);
    
    self.commentLabel.attributedText = comment.attributedText;
    self.commentLabel.frame = CGRectMake(55, 33, COMMENT_WIDTH, 500);
    [self.commentLabel sizeToFit];
    self.commentLabel.delegate = self.delegate;
}

- (void)actionUser
{
    [self.delegate trackCommentCell:self openUser:self.comment.user];
}

@end
