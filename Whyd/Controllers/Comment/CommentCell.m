//
//  CommentDetailCell.m
//  Whyd
//
//  Created by Damien Romito on 19/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "WDHelper.h"
#import "UserViewController.h"

@interface CommentCell()
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) OHAttributedLabel *commentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIButton *maskAvatarButton;

@end
@implementation CommentCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier containingTableView:containingTableView leftUtilityButtons:leftUtilityButtons rightUtilityButtons:rightUtilityButtons];
    
    CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;

   self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.contentView.backgroundColor = UICOLOR_WHITE;
    
    
    self.maskAvatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [self.maskAvatarButton setBackgroundImage:[UIImage imageNamed:@"PostUserMask"] forState:UIControlStateNormal];
    [self.maskAvatarButton addTarget:self action:@selector(actionUser) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.maskAvatarButton];
    

    self.contentView.layer.borderColor = RGBCOLOR(242, 244, 245).CGColor;
    self.contentView.layer.borderWidth = 1;
    
    self.userButton = [[UIButton alloc] initWithFrame:CGRectMake(55, 0, size.width - 100, 35)];
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
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width - 95, 18, 84, 10)];
    self.timeLabel.textColor = RGBCOLOR(184, 187, 192);
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_1];
    [self.contentView addSubview:self.timeLabel];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.frame = CGRectMake(size.width - 25, 20, 10, 10);
    self.activityIndicator.color = WDCOLOR_GRAY_TEXT_DARK;
    [self.contentView addSubview:self.activityIndicator];
    
    self.retryButton = [[UIButton alloc] initWithFrame:CGRectMake(size.width - 68, 0, 70, 27)];
    [self.retryButton setTitle:NSLocalizedString(@"Retry",nil) forState:UIControlStateNormal];
    [self.retryButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(actionRetry) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.hidden = YES;
    [self.contentView addSubview:self.retryButton];

    
    return self;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height + 1 );
    self.imageView.frame = CGRectMake(11, 15, 35, 35);
    self.contentView.frame = CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height + 1 );
    
    [self.contentView bringSubviewToFront:self.imageView];
}

- (void)setComment:(Comment *)comment
{
    _comment = comment;

    NSURL *avatarURL = [NSURL URLWithString:[comment.user imageUrl:UserImageSizeSmall]];
    
    [self.imageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];

    [self.userButton setTitle:comment.user.name forState:UIControlStateNormal];
    self.commentLabel.attributedText = comment.attributedText;
    self.commentLabel.frame = CGRectMake(55, 33, COMMENT_WIDTH, 500);
    [self.commentLabel sizeToFit];
    self.commentLabel.delegate = self.commentDelegate;
    
    if (comment.isSending) {
        self.timeLabel.hidden = YES;
        [self.activityIndicator startAnimating];
    }else
    {
        self.timeLabel.hidden = NO;
        [self.activityIndicator stopAnimating];
        self.timeLabel.text = comment.date;
    }
    
    [self setCellHeight:64 + (self.commentLabel.frame.size.height - 15)];
    

}

- (void)sendingFail
{
    self.retryButton.hidden = NO;
    DLog(@"FAIL");
}

- (void)actionRetry
{
    self.retryButton.hidden = YES;
    [self.activityIndicator startAnimating];
    [self.commentDelegate sendComment:self.comment];
}

- (void)actionUser
{
    [self.commentDelegate commentCell:self openUser:self.comment.user];
}



@end
