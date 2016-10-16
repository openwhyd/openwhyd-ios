//
//  TrackCell.m
//  Whyd
//
//  Created by Damien Romito on 13/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TrackCell.h"
#import "UIImageView+WebCache.h"
#import "WDPlayerManager.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "UIImage+Additions.h"
#import "WDLabel.h"
#import "WDHelper.h"
#import "UIImageView+WebCache.h"
#import "GHContextMenuView.h"
#import "WDPlayerButton.h"
#import "Playlist.h"
#import "WDFacebookHelper.h"
#import "WDTwitterHelper.h"

@interface TrackCell()
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL actionsDisplayed;
@property (nonatomic, strong) UIImageView *gradientBackground;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *buttonReposts;
@property (nonatomic, strong) UIButton *buttonLikes;
@property (nonatomic, strong) UIButton *buttonComments;
@property (nonatomic, strong) UIView *statsView;
@property (nonatomic, strong) UIImageView *buttonView;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UIImageView *sourceImageView;

@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *playlistButton;
@property (nonatomic, strong) UIButton *timeButton;
@property (nonatomic, strong) WDPlayerButton *playButton;
@property (nonatomic, strong) WDLabel *topLabel;
@property (nonatomic, strong) GHContextMenuView* overlay;

@end


@interface TrackCell()< GHContextOverlayViewDelegate>

@end

@implementation TrackCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        UIView *v = [UIView new];
        v.backgroundColor = WDCOLOR_RED;
        v.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:v];
        
        
//        [self addConstraints:[NSLayoutConstraint
//                                          constraintsWithVisualFormat:@"H:|[v(20)]"
//                                          options:0
//                                          metrics:0
//                                          views:@{@"v" : v}]];
        
//        [self.contentView addConstraints:[NSLayoutConstraint
//                                   constraintsWithVisualFormat:@"V:|10-[v(30)]"
//                                   options:0
//                                   metrics:0
//                                   views:@{@"view" : v}]];
        
        
        CGFloat screenWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;

        // Initialization code
        self.backgroundColor = WDCOLOR_WHITE;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.gradientBackground = [[UIImageView alloc] init];
        self.gradientBackground.image = [UIImage imageNamed:@"PostBackgroundGradientBottomCover"];
        [self.imageView addSubview:self.gradientBackground];
        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionSingleTap)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        /************** SOURCE ICON ****************/

        
        self.sourceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StreamCornerBackgroundSourceRight"]];
        CGRect frame = self.sourceImageView.frame;
        frame.origin.x = screenWidth - self.sourceImageView.frame.size.width;
        self.sourceImageView.frame = frame;
        [self.contentView addSubview:self.sourceImageView ];
       

        
        /************** TOP LABEL ****************/
        self.topLabel = [[WDLabel alloc] init];
        self.topLabel.edgeInsets = UIEdgeInsetsMake(0, 0, 20, 30);
        self.topLabel.frame = CGRectMake(0, 0, 65, 65);
        self.topLabel.textColor = UICOLOR_WHITE;
        self.topLabel.textAlignment = NSTextAlignmentCenter;
        self.topLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_4];
        [self.topLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"HotTrackBackgroundNumber"]]];
        self.topLabel.hidden = YES;
        [self.contentView addSubview:self.topLabel];
        
        /************** BUTTON VIEW ****************/
        self.playButton = [[WDPlayerButton alloc] initWithOrigin:CGPointMake(screenWidth/2 - 32 , 39)];
        [self.playButton addTarget:self action:@selector(actionPlay) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playButton];
        
        /************** TITLE ****************/
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIZE_PADDING, 155, screenWidth - 40, 17)];
        self.titleLabel.textColor = UICOLOR_WHITE;
        self.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.titleLabel];
        
        self.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"PostIconLink" ]];
        
        /************** ACTIONS ****************/
        
        //UIView *statsView = [UIView new];
        self.statsView = [UIView new];
        //statsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.statsView];
        
        
        self.buttonReposts = [[UIButton alloc] init];
        self.buttonReposts.userInteractionEnabled = NO;
        
        [self.buttonReposts setImage:[UIImage imageNamed:@"PostIconAdd"] forState:UIControlStateNormal];
        [self.buttonReposts setTitleColor:RGBCOLOR(215, 215, 215) forState:UIControlStateNormal];
        [self.statsView addSubview:self.buttonReposts];
        
        self.buttonLikes = [[UIButton alloc] init];
        self.buttonLikes.userInteractionEnabled = NO;
        [self.buttonLikes setImage:[UIImage imageNamed:@"PostIconLike"] forState:UIControlStateNormal];
        [self.buttonLikes setTitleColor:RGBCOLOR(215, 215, 215) forState:UIControlStateNormal];
        [self.statsView addSubview:self.buttonLikes];
        
        self.buttonComments = [[UIButton alloc] init];
        self.buttonComments.userInteractionEnabled = NO;
        [self.buttonComments setImage:[UIImage imageNamed:@"PostIconComment"] forState:UIControlStateNormal];
        [self.buttonComments setTitleColor:RGBCOLOR(215, 215, 215) forState:UIControlStateNormal];
        [self.statsView addSubview:self.buttonComments];
        
        for (UIButton* v in [self.statsView subviews]) {
            v.translatesAutoresizingMaskIntoConstraints = NO;
            v.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_1];
            v.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
            v.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }

        
//        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:statsView attribute:NSLayoutAttributeTop relatedBy:nil toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1. constant:50.]];
        

        
        /************** USER ****************/
        
        UIView* userBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 190, screenWidth, 45)];
        userBackground.backgroundColor = UICOLOR_WHITE;
        [self.contentView addSubview:userBackground];
        
        self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 5, 35, 35)];
        self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.userImageView.userInteractionEnabled = YES;
        self.userImageView.clipsToBounds = YES;
        UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionUser)];
        [self.userImageView addGestureRecognizer:tapAvatar];
        [userBackground addSubview:self.userImageView];
        
        UIImageView *userMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PostUserMask"]];
        [self.userImageView addSubview:userMask];
        
        self.userButton = [[UIButton alloc] initWithFrame:CGRectMake(52, 0, 220, 45)];
        [self.userButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
        [self.userButton setTitleColor:WDCOLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
        self.userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.userButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
        [self.userButton addTarget:self action:@selector(actionUser) forControlEvents:UIControlEventTouchUpInside];
        [userBackground addSubview:self.userButton];
        
        self.playlistButton = [[UIButton alloc] initWithFrame:CGRectMake(52, 26, 220, 20)];
        [self.playlistButton setTitleColor:RGBCOLOR(146, 168, 200) forState:UIControlStateNormal];
        [self.playlistButton setTitleColor:RGBCOLOR(166, 188, 220) forState:UIControlStateHighlighted];
        
        self.playlistButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.playlistButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 9, 0);
        self.playlistButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.playlistButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_2];
        [self.playlistButton addTarget:self action:@selector(actionPlaylist) forControlEvents:UIControlEventTouchUpInside];
        [userBackground addSubview:self.playlistButton];
        
        self.timeButton = [[UIButton alloc] init];
        self.timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.timeButton setTitleColor:RGBCOLOR(184, 187, 192) forState:UIControlStateNormal];
        self.timeButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_1];
        self.timeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3);
        [self.timeButton setImage:[UIImage imageNamed:@"PostIconTime"] forState:UIControlStateNormal];
        [userBackground addSubview:self.timeButton];
        
        /************** STATE ****************/
        
        [self updateState];
        [self addObserver:self forKeyPath:@"track.state" options:NSKeyValueObservingOptionNew context:NULL];
        
        //        //LIKE
        //        self.likeImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
        //        self.likeImage.image = [UIImage imageNamed:@"TrackLike"];
        //        self.likeImage.hidden = YES;
        //        self.likeImage.alpha = 0;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, 191);
    self.imageView.clipsToBounds = YES;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    self.gradientBackground.frame = self.imageView.frame;
    [self.contentView sendSubviewToBack:self.imageView];
    CGRect frame = self.contentView.frame;
    frame.size.width = self.frame.size.width;
    self.contentView.frame = frame;
    
    frame = self.accessoryView.frame;
    frame.origin.y = 156;
    frame.origin.x = self.frame.size.width - frame.size.width - 11;
    self.accessoryView.frame = frame;
    
    
    
    self.statsView.frame = CGRectMake(10, 130, 200, 12);
    
    NSDictionary *views = @{@"reposts": self.buttonReposts,
                            @"likes": self.buttonLikes,
                            @"comments": self.buttonComments,
                            };
    
    
    [self.statsView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[reposts][likes][comments]"
                               options:NSLayoutFormatAlignAllTop| NSLayoutFormatAlignAllBottom
                               metrics:0
                               views:views]];
    [self.statsView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[comments]"
                               options:0
                               metrics:0
                               views:views]];

}


- (void)updateLikeAnimated:(BOOL)animated
{
    if (self.track.likesCount) {
        [self.buttonLikes setConstraintConstant:40 forAttribute:NSLayoutAttributeWidth];
        [self.buttonLikes setTitle:[NSString stringWithFormat:@"%d",(int)self.track.likesCount] forState:UIControlStateNormal];
        if (animated) {
            [self.buttonLikes setContentScaleFactor:1];
            CGAffineTransform t = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:0.2 animations:^{
                CGAffineTransform t = CGAffineTransformIdentity;
                self.buttonLikes.transform = CGAffineTransformScale(t, 1.2, 1.2);
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.buttonLikes.transform = t;
                } completion:^(BOOL finished) {
                }];
            }];
            
        }
    }else{
        [self.buttonLikes setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
    }
    [self updateOverlay];
    
    
}

#pragma -mark SETTER

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)setTrack:(WDTrack *)track
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];

    _track = track;
    
    [self updateOverlay];
    

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self.overlay action:@selector(longPressDetected:)];
    [self.contentView addGestureRecognizer:longPress];
    self.contentView.userInteractionEnabled = YES;
    
    self.sourceImageView.hidden = YES;
    
    
    /************** TITLE ****************/
    self.titleLabel.text = [track.name capitalizedString];
    
    /************** IMAGE ****************/
    if(self.track.imageUrl)
    {
        [self setImageView];
    }
    /************** TOP ****************/
    
    if (track.topNumber) {
        self.topLabel.text = [NSString stringWithFormat:@"%li", (long)track.topNumber];
        self.topLabel.hidden = NO;
    }else
    {
        self.topLabel.hidden = YES;
    }
    
    /************** ACTIONS ****************/
    [self updateLikeAnimated:NO];
    if (self.track.repostsCount) {
        [self.buttonReposts setConstraintConstant:40 forAttribute:NSLayoutAttributeWidth];
        [self.buttonReposts setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.track.repostsCount] forState:UIControlStateNormal];
    }else
    {
        [self.buttonReposts setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
    }
    if (self.track.comments.count) {
        [self.buttonComments setConstraintConstant:40 forAttribute:NSLayoutAttributeWidth];
        [self.buttonComments setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.track.comments.count] forState:UIControlStateNormal];
    }else{
        [self.buttonComments setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
    }
    
    /************** USER ****************/
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[track.user imageUrl:UserImageSizeSmall]] placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
    [self.userButton setTitle: track.user.name/*[NSString stringWithFormat:@"%@ - %@", track.user.name,track.sourceKey ]*/ forState:UIControlStateNormal];
    
    if (track.playlist) {
        self.userButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
        self.timeButton.frame = CGRectMake(window.bounds.size.width - 160, 10, 150, 15);
        [self.playlistButton setTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"TrackCellInPlaylist", nil), track.playlist.name] forState:UIControlStateNormal];
        self.playlistButton.hidden = NO;
        
    }else
    {
        CGRect frame = CGRectMake(window.bounds.size.width - 160, 10, 150, 15);
        frame.origin.y += 5;
        self.timeButton.frame = frame;
        self.userButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.playlistButton.hidden = YES;
    }
    
    [self.timeButton setTitle:track.date forState:UIControlStateNormal];
    
    
}



- (void)setImageView
{
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.track.imageUrl ] placeholderImage:[UIImage imageWithColor:WDCOLOR_GRAY_PLACEHOLDER_IMAGE] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!error) {
            [weakSelf.imageView setImage:image];
            
            //SMOOTH DISPLAY IF NEED TO BE LOADING
            if (cacheType != SDImageCacheTypeMemory ) {
                weakSelf.imageView.alpha = 0.0;
                [UIView transitionWithView:weakSelf.imageView
                                  duration:.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    weakSelf.imageView.alpha = 1.0;
                                } completion:NULL];
            }
            
        }else
        {
            if ([weakSelf.track updatedAvailableImageUrl] < 2) {
                [weakSelf setImageView];
            };
        }
    }];
    
}


#pragma Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateState];
    
}

- (void)updateState
{
    
    switch (self.track.state) {
        case TrackStateLoading:
        {
            self.playButton.currentState = WDPlayerButtonStateLoading;
        }
            break;
        case TrackStateStop:
        {
            
            self.playButton.currentState = WDPlayerButtonStateStop;
        }
            break;
        case TrackStatePlay:
        {
            self.playButton.currentState = WDPlayerButtonStatePlay;
        }
            break;
        case TrackStatePause:
        {
            self.playButton.currentState = WDPlayerButtonStatePause;
        }
            break;
        case TrackStateUnavailable:
        {
            self.playButton.currentState = WDPlayerButtonStateUnavailable;
            self.gradientBackground.backgroundColor = RGBACOLOR(24, 27, 31, .76);
        }
            break;
            
    }
    
    if (self.track.state != TrackStateUnavailable) {
        
        self.gradientBackground.backgroundColor = UICOLOR_CLEAR;
    }
    
    
}

- (void)updateOverlay
{
    self.overlay = [[GHContextMenuView alloc] init];
    self.overlay.isLiked = self.track.isLiked;
    self.overlay.byCurrentUser = [[WDHelper manager].currentUser.id isEqualToString:self.track.user.id];
    self.overlay.delegate = self;
}

#pragma mark Action

//- (void)actionEnableInteration
//{
//    DLog(@"INTERATION YES");
//    self.userInteractionEnabled = YES;
//}
//
//- (void)actionDisableInteration
//{
//    self.userInteractionEnabled = NO;
//    DLog(@"INTERATION NO");
//}

- (void)actionUser
{
    [self.delegate trackCell:self openUser:self.track.user];
}

- (void)actionPlaylist
{
    [self.delegate trackCell:self openPlaylist:self.track.playlist];
}


- (void)actionSingleTap
{
    [self.delegate trackCellOpenDetail:self ];
}


- (void)actionPlay
{
    
    
    switch (self.track.state) {
        case TrackStatePause:
            [[WDPlayerManager manager] play];
            break;
        case TrackStatePlay:
            [[WDPlayerManager manager] pause];
            
            break;
        case TrackStateStop:
            [self.delegate trackCellPlay:self];
            break;
        case TrackStateUnavailable:
            [self.delegate trackCellPlayUnaivailable];
            break;
        default:
            break;
            
    }
}

- (void)actionAdd
{
    [self.delegate trackCell:self repost:self.track];
}

- (void)actionLike
{
    if(self.track.id)
    {
        self.track.isLiked = !self.track.isLiked;
        [self updateLikeAnimated:YES];
        
        //SEND LIKE
        NSDictionary *parameters = @{@"pId": self.track.id};
        [[WDClient client] GET:@"/api/post?action=toggleLovePost" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        [Flurry logEvent:FLURRY_LIKE_FROM_TRACKCELL_LONGTAP];
        
    }

}

- (void)actionShare
{
    if ([self.delegate respondsToSelector:@selector(trackCell:shareTrack:)]) {
        [self.delegate trackCell:self shareTrack:self.track];
    }
}



#pragma mark GHContextMenu Delegate


- (void)didSelectItemType:(MenuActionType)type
{
    
    switch (type) {
        case MenuActionTypeAdd:
            [Flurry logEvent:FLURRY_ADD_FROM_TRACKCELL_LONGTAP];
            
            [self actionAdd];
            break;
        case MenuActionTypeLike:
            [Flurry logEvent:FLURRY_LIKE_FROM_TRACKCELL_LONGTAP];
            
            [self actionLike];
            break;
        case MenuActionTypeEdit:
            if ([self.delegate respondsToSelector:@selector(trackCell:editTrack:)]) {
                [self.delegate trackCell:self editTrack:self.track];
            }
            break;
        case MenuActionTypeShare:
            [Flurry logEvent:FLURRY_SHARE_FROM_TRACKCELL_LONGTAP];
            
            [self actionShare];
            break;
            
        default:
            break;
    }
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"track.state"];
    
}



@end