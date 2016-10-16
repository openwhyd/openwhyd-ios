//
//  UserViewController.m
//  Whyd
//
//  Created by Damien Romito on 10/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//
#import "WDFacebookHelper.h"

#import "UserViewController.h"
#import "UIImageView+WebCache.h"
#import "WDHelper.h"
#import "WDClient.h"
#import "SMPageControl.h"
#import "UIImage+Additions.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "PlaylistUserCell.h"
#import "PlaylistViewController.h"
#import "OHAttributedLabel.h"
#import "FollowingViewController.h"
#import "FollowersViewController.h"
#import "ProfileEditViewController.h"
#import "WDFollowButton.h"
typedef NS_ENUM(NSUInteger, SegmentedButton) {
    SegmentedButtonTracks = 0,
    SegmentedButtonPlaylists = 1,
    SegmentedButtonLikes = 2,

};

typedef NS_ENUM(NSUInteger, LinksButton) {
    LinksButtonFacebook = 1,
    LinksButtonTwitter = 2,
    LinksButtonInstagram = 3,
    LinksButtonYoutube = 4,
    LinksButtonSoundcloud = 5,
};

@interface UserViewController ()
@property (nonatomic) BOOL isVisible;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *infoUserAvatarImageView;
@property (nonatomic, strong) UILabel *infoUserNameLabel;
@property (nonatomic, strong) SMPageControl *scrollPageControl;
@property (nonatomic, strong) UIScrollView *infosScrollView;
//
@property (nonatomic, strong) UILabel *infoUserDescription;
@property (nonatomic, strong) UILabel *infoUserLocation;
@property (nonatomic, strong) UIButton *infoUserLinkButton;
@property (nonatomic, strong) NSMutableArray *segmentedLabels;
@property (nonatomic, strong) UIView *linksView;

@property (nonatomic, strong) UIButton *followersButton;
@property (nonatomic, strong) UIButton *followingsButton;
@property (nonatomic, strong) WDFollowButton *followButton;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *currentButton;
@property (nonatomic, strong) UIImageView *gradientHeader;
@property (nonatomic, strong) UIView *secondGradientHeader;

@property (nonatomic, strong) Playlist *usersPlaylist;
@end

@implementation UserViewController


- (instancetype)initWithUser:(User *)user success:(void(^)(User *user))success
{
    self = [super init];
    if (self) {
        self.user = user;
        [self reloadUserInfos:^(User *u) {
            success(u);
        }];
        
    }
    return self;
}

- (instancetype)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        self.user = user;
        
        [self initPlaylists];
        [self reloadUserInfos];

    }
    return self;
}

- (void)initPlaylists
{
    self.usersPlaylist = [Playlist new];
    self.usersPlaylist.shuffleEnable = NO;
//    self.usersPlaylist.delegate = self;
    self.usersPlaylist.name = [NSString stringWithFormat:NSLocalizedString(@"ProfileLikesOf", nil), self.user.name];
    self.usersPlaylist.url = API_USER_LIKES(self.user.id);
    
    
    self.tracksPlaylist = [Playlist new];
    self.tracksPlaylist.shuffleEnable = NO;
  //  self.tracksPlaylist.delegate = self;
    NSLog(@" self.user.name %@", self.user.name);
    self.tracksPlaylist.name = [NSString stringWithFormat:NSLocalizedString(@"ProfileTracksOf", nil), self.user.name];
    self.tracksPlaylist.url = API_USER_TRACKS(self.user.id);

    //self.currentButton = _currentButton;
}



- (void)loadView
{
 
    
    [super loadView];
    
    //IF MODAL
    if (self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingsIconClose"] style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
    }
    
    self.title = [NSLocalizedString(@"ProfileTitle", nil) uppercaseString];
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 281)];
    self.headerImageView.backgroundColor = WDCOLOR_BLUE_DARK;
    self.headerImageView.clipsToBounds= YES;
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.headerImageView];

    self.secondGradientHeader = [[UIView alloc] initWithFrame:self.headerImageView.frame];
    self.secondGradientHeader.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.headerImageView addSubview:self.secondGradientHeader];
    
    self.refreshControl.tintColor = UICOLOR_WHITE;
    [self.view sendSubviewToBack:self.headerImageView];
    self.tableView.backgroundColor = UICOLOR_CLEAR;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 281)];
    self.headerView.backgroundColor = UICOLOR_CLEAR;
    self.headerView.userInteractionEnabled = YES;
    self.headerView.clipsToBounds = YES;
    
    self.gradientHeader = [[UIImageView alloc] initWithFrame:self.headerImageView.frame];
    self.gradientHeader.image = [UIImage imageNamed:@"ProfileBackgroundGradient"];
    [self.headerView addSubview:self.gradientHeader];
    
    self.infosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 225)];
    self.infosScrollView.scrollsToTop = NO;
    self.infosScrollView.pagingEnabled = YES;
    [self.infosScrollView  setContentSize:CGSizeMake(self.infosScrollView .frame.size.width*2, 200)];
    self.infosScrollView.delegate = self;
    self.infosScrollView.showsHorizontalScrollIndicator = NO;
    self.infosScrollView.scrollEnabled = NO;
    UITapGestureRecognizer *tap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapHeader)];
    [self.infosScrollView addGestureRecognizer:tap];
    self.infosScrollView.userInteractionEnabled = YES;
    [self.headerView addSubview: self.infosScrollView ];
    
    

    
    //PAGE CONTROL
    self.scrollPageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0 , 15 , self.view.frame.size.width - 11, 10)] ;
    self.scrollPageControl.numberOfPages = 2;
    self.scrollPageControl.tintColor = UICOLOR_WHITE;
    self.scrollPageControl.currentPage = 0;
    self.scrollPageControl.alignment = SMPageControlAlignmentRight;
    self.scrollPageControl.hidden = YES;
    [self.headerView addSubview:self.scrollPageControl];

    
    /******************* INFO 1ST PAGE ********************************/
    
    self.infoUserAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 34 , 21, 68, 68)];
    self.infoUserAvatarImageView.clipsToBounds = YES;
    self.infoUserAvatarImageView.layer.borderColor = UICOLOR_WHITE.CGColor;
    self.infoUserAvatarImageView.layer.borderWidth = 1;
    self.infoUserAvatarImageView.layer.cornerRadius = 34;
    self.infoUserAvatarImageView.backgroundColor = UICOLOR_WHITE;
    self.infoUserAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.infosScrollView addSubview:self.infoUserAvatarImageView];
    
    
    self.infoUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 102, self.view.frame.size.width, 20)];
    self.infoUserNameLabel.textAlignment = NSTextAlignmentCenter;
    self.infoUserNameLabel.textColor = UICOLOR_WHITE;
    self.infoUserNameLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_6];
    [self.infosScrollView addSubview:self.infoUserNameLabel];
    

    //STATS
    self.followersButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 126, self.view.frame.size.width / 2, 30)];
    //[self.followersButton setTintColor:UICOLOR_WHITE];
    [self.followersButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
    [self.followersButton setTitleColor:[UICOLOR_WHITE colorWithAlphaComponent:.7] forState:UIControlStateHighlighted];
    self.followersButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    self.followersButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    self.followersButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.followersButton addTarget:self action:@selector(actionFollowers) forControlEvents:UIControlEventTouchUpInside];
    [self.infosScrollView addSubview:self.followersButton];
    
    
    self.followingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 2, 126, self.view.frame.size.width / 2 + 2 , 30)];
 //   [self.followingsButton setTintColor:UICOLOR_WHITE];
    [self.followingsButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
    [self.followingsButton setTitleColor:[UICOLOR_WHITE colorWithAlphaComponent:.7] forState:UIControlStateHighlighted];
    [self.followingsButton setImage:[UIImage imageNamed:@"ProfileIconSeparation"] forState:UIControlStateNormal];
    self.followingsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    self.followingsButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    self.followingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.followingsButton addTarget:self action:@selector(actionFollowing) forControlEvents:UIControlEventTouchUpInside];
    [self.infosScrollView addSubview:self.followingsButton];
    
    
    //FOLLOW BUTTON
    self.followButton = [[WDFollowButton alloc] initWithPosition:CGPointMake(self.view.frame.size.width / 2 - 41, 165)];
    [self.followButton addTarget:self action:@selector(actionFollow) forControlEvents:UIControlEventTouchUpInside];
    self.followButton.hidden = YES;
    [self.infosScrollView addSubview:self.followButton];
    
    //EDIT BUTTON
    self.editButton = [[UIButton alloc] initWithFrame:self.followButton.frame];
    self.editButton.layer.borderColor = WDCOLOR_BLACK_LIGHT2.CGColor;
    self.editButton.layer.borderWidth = 1.;
    self.editButton.layer.cornerRadius = CORNER_RADIUS;
    self.editButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    [self.editButton setTitle: NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [self.editButton setTitleColor:WDCOLOR_BLACK_LIGHT2 forState:UIControlStateNormal];
    [self.editButton setTitleColor:WDCOLOR_GRAY_DARK2 forState:UIControlStateHighlighted];

    [self.editButton addTarget:self action:@selector(actionEdit) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.hidden = YES;
    [self.infosScrollView addSubview:self.editButton];

    /******************* INFO 2ND PAGE ********************************/
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.infosScrollView.frame.size.height)];
    [self.infosScrollView addSubview:secondView];
    
    UIView *spaceView = [UIView new];
    spaceView.translatesAutoresizingMaskIntoConstraints = NO;
    [secondView addSubview:spaceView];
    
    self.infoUserDescription = [UILabel new];
    self.infoUserDescription.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoUserDescription.numberOfLines = 0;
    self.infoUserDescription.preferredMaxLayoutWidth = 280;
    self.infoUserDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.infoUserDescription.textColor = UICOLOR_WHITE;
    self.infoUserDescription.textAlignment = NSTextAlignmentCenter;
    [self.infoUserDescription setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.infoUserDescription setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.infoUserDescription.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
    [secondView addSubview:self.infoUserDescription];
    
    self.infoUserLocation = [UILabel new];
    self.infoUserLocation.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoUserLocation.textAlignment = NSTextAlignmentCenter;
    self.infoUserLocation.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
    self.infoUserLocation.textColor = UICOLOR_WHITE;
    [secondView addSubview:self.infoUserLocation];

    self.infoUserLinkButton = [UIButton new];
    self.infoUserLinkButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoUserLinkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.infoUserLinkButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
    [self.infoUserLinkButton addTarget:self action:@selector(actionUserLink) forControlEvents:UIControlEventTouchUpInside];
    self.infoUserLinkButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_2];
    self.infoUserLinkButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
    [secondView addSubview:self.infoUserLinkButton];
    
    self.linksView = [UIView new];
    self.linksView.translatesAutoresizingMaskIntoConstraints = NO;
    [secondView addSubview:self.linksView];
    
    [@[@"Facebook", @"Twitter", @"Instagram", @"Youtube", @"Soundcloud"] enumerateObjectsUsingBlock:^(NSString * buttonTitle, NSUInteger index, BOOL *stop)
     {
         UIButton *button = [[UIButton alloc] init];
         [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"ProfileButton%@", buttonTitle]] forState:UIControlStateNormal];
         button.translatesAutoresizingMaskIntoConstraints = NO;
         button.tag = index + 1;
         [button addTarget:self action:@selector(actionLinks:) forControlEvents:UIControlEventTouchUpInside];
         [self.linksView addSubview:button];
     }];
    
  
    
    NSDictionary *views = @{@"spaceView" : spaceView,
                            @"description": self.infoUserDescription,
                            @"location": self.infoUserLocation,
                            @"link": self.infoUserLinkButton,
                            @"linksView": self.linksView
                            };
    
    [secondView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|-[spaceView]-|"
                                          options: 0
                                          metrics:0
                                          views:views]];

    [secondView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[spaceView][description][location(35)][link(35)]-[linksView]|"
                          options: NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllLeft
                          metrics:0
                          views:views]];
    
    
    //CENTER VERTICALY
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:self.linksView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:spaceView
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:1
                                      constant:0];
    [secondView addConstraint:constraint];
    
    
    //CENTER HORIZONTALY LINKS
    
    UIView *spaceView2 = [UIView new];
    spaceView2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.linksView addSubview:spaceView2];
    
    UIView *spaceView3 = [UIView new];
    spaceView3.translatesAutoresizingMaskIntoConstraints = NO;
    [self.linksView addSubview:spaceView3];
    
    
    views = @{@"spaceView2": spaceView2,
              @"facebook" : [self.linksView viewWithTag:LinksButtonFacebook] ,
              @"twitter" : [self.linksView viewWithTag:LinksButtonTwitter] ,
              @"instagram" : [self.linksView viewWithTag:LinksButtonInstagram] ,
              @"youtube" : [self.linksView viewWithTag:LinksButtonYoutube] ,
              @"soundcloud" : [self.linksView viewWithTag:LinksButtonSoundcloud] ,
              @"spaceView3": spaceView3,
             };

    [self.linksView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|[spaceView2][facebook(35)][twitter(35)][instagram(35)][youtube(35)][soundcloud(35)][spaceView3]|"
                                options: NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                metrics:0
                                views:views]];
    
    [self.linksView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:|[facebook]"
                                    options: 0
                                    metrics:0
                                    views:views]];
    
    //CENTER VERTICALY
    NSLayoutConstraint *constraint2  = [NSLayoutConstraint
                      constraintWithItem:spaceView2
                      attribute:NSLayoutAttributeWidth
                      relatedBy:NSLayoutRelationEqual
                      toItem:spaceView3
                      attribute:NSLayoutAttributeWidth
                      multiplier:1
                      constant:0];
    [self.linksView addConstraint:constraint2];
    
    //BUTTONS SEGMENTED CONTROL
    
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 225, self.view.frame.size.width, 0.5)];
    separatorLine.backgroundColor = [UICOLOR_WHITE colorWithAlphaComponent:.12];
    [self.headerView addSubview:separatorLine];
    
    CGFloat boutonWidth = self.view.frame.size.width/3;
    
    self.segmentedLabels = [NSMutableArray array];
    [@[ [NSLocalizedString(@"Tracks", nil) uppercaseString],
       [NSLocalizedString(@"Playlists", nil) uppercaseString],
       [NSLocalizedString(@"Likes", nil) uppercaseString]
       ] enumerateObjectsUsingBlock:^(NSString * buttonTitle, NSUInteger index, BOOL *stop)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(boutonWidth * index, 226, boutonWidth, 55)];
        button.tag = index;
        [button setBackgroundImage:[UIImage imageNamed:@"ProfileBackgroundTopTriangle"] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"ProfileBackgroundTopTriangle"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"ProfileBackgroundTopTriangle"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [button addTarget:self action:@selector(actionTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(actionTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(actionTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(actionTouchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        
        OHAttributedLabel * numberLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0, 20,boutonWidth, 25)];
        [button addSubview:numberLabel];
        [self.segmentedLabels addObject:numberLabel];

        if (index == 0) {
            self.currentButton = button;
            [self initPlaylists];
            self.currentButton.selected = YES;
            
        }else
        {
            button.alpha = 0.5;
        }
        [self.headerView addSubview:button];
    }];
    
    
    self.tableView.tableHeaderView = self.headerView;
    self.view.backgroundColor = WDCOLOR_WHITE;

    
    
    self.isVisible = YES;
}



- (void)viewWillAppear:(BOOL)animated
{
    
    
    
    [super viewWillAppear:animated];
    [self configureView];
    self.view.backgroundColor = WDCOLOR_WHITE;

}

- (void) configureView
{
    
    if (![self.user.id isEqualToString:[WDHelper manager].currentUser.id] )
    {
        if (self.user.isSubscribing == -1) {
            self.followButton.hidden = YES;
            self.editButton.hidden = YES;
        }else
        {
            self.followButton.hidden = NO;
            self.editButton.hidden = YES;
            self.followButton.selected = self.user.isSubscribing;
        }

    }else
    {
        self.followButton.hidden = YES;
        self.editButton.hidden = NO;
    }
    
    self.infoUserNameLabel.text = self.user.name;
    [self.followersButton setTitle:[NSString stringWithFormat:@"%ld %@", (long)self.user.nbSubscribers, NSLocalizedString(@"ProfileFollowers", nil)] forState:UIControlStateNormal];
    [self.followingsButton setTitle:[NSString stringWithFormat:@"%ld %@", (long)self.user.nbSubscriptions, NSLocalizedString(@"ProfileFollowing", nil)] forState:UIControlStateNormal];
    
    NSURL *imageURL = [NSURL URLWithString:[self.user imageUrl:UserImageSizeLarge] ];
    [self.infoUserAvatarImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder_track"]];
    
    NSURL *imageCoverUrl = [NSURL URLWithString:self.user.imageCoverUrl];
    
    __weak typeof(self) weakSelf = self;
    [self.headerImageView sd_setImageWithURL:imageCoverUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!error) {
            [weakSelf.headerImageView setImage:image];
            
            //SMOOTH DISPLAY IF NEED TO BE LOADING
            if (cacheType != SDImageCacheTypeMemory ) {
                weakSelf.headerImageView.alpha = 0.0;
                [UIView transitionWithView:weakSelf.headerImageView
                                  duration:.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    weakSelf.headerImageView.alpha = 1.0;
                                } completion:NULL];
            }
            
        }
    }];
    
    
    
    /*********************** 2nd Screen ******************************/
    BOOL hasSecondScreen = NO;
    //    //LINKS
    if (!self.user.lnk.fb || [self.user.lnk.fb isEqualToString:@""]) {
        [[self.linksView viewWithTag:LinksButtonFacebook] hideByWidth:YES];
    }else{
        hasSecondScreen = YES;
        [[self.linksView viewWithTag:LinksButtonFacebook] hideByWidth:NO];
    }
    if (!self.user.lnk.tw || [self.user.lnk.tw isEqualToString:@""]) {
        [[self.linksView viewWithTag:LinksButtonTwitter] hideByWidth:YES];
    }else{
        hasSecondScreen = YES;
        [[self.linksView viewWithTag:LinksButtonTwitter] hideByWidth:NO];
    }
    if (!self.user.lnk.igrm || [self.user.lnk.igrm isEqualToString:@""]) {
        [[self.linksView viewWithTag:LinksButtonInstagram] hideByWidth:YES];
    }else{
        hasSecondScreen = YES;
        [[self.linksView viewWithTag:LinksButtonInstagram] hideByWidth:NO];
    }
    if (!self.user.lnk.yt || [self.user.lnk.yt isEqualToString:@""]) {
        [[self.linksView viewWithTag:LinksButtonYoutube] hideByWidth:YES];
    }else{
        hasSecondScreen = YES;
        [[self.linksView viewWithTag:LinksButtonYoutube] hideByWidth:NO];
    }
    if (!self.user.lnk.sc || [self.user.lnk.sc isEqualToString:@""]) {
        [[self.linksView viewWithTag:LinksButtonSoundcloud] hideByWidth:YES];
    }else{
        hasSecondScreen = YES;
        [[self.linksView viewWithTag:LinksButtonSoundcloud] hideByWidth:NO];
    }
    self.linksView.alpha = hasSecondScreen;
    
    
    //bio
    if (self.user.bio && self.user.bio.length > 1) {
        hasSecondScreen = YES;
        self.infoUserDescription.text = self.user.bio;
        [self.infoUserDescription hideByHeight:NO];
    }else
    {
        [self.infoUserDescription hideByHeight:YES];
    }
    //location
    if (self.user.loc && self.user.loc.length > 1) {
        hasSecondScreen = YES;
        self.infoUserLocation.text = self.user.loc;
        [self.infoUserLocation hideByHeight:NO];
    }else
    {
        [self.infoUserLocation hideByHeight:YES];
    }
    
    if (self.user.lnk.home && ![self.user.lnk.home isEqualToString:@""]) {
        hasSecondScreen = YES;
        [self.infoUserLinkButton setTitle:self.user.lnk.home forState:UIControlStateNormal];
        [self.infoUserLinkButton hideByHeight:NO];
    }else
    {
        [self.infoUserLinkButton hideByHeight:YES];
        
    }
    
    
    //Display 2nd view?
    if (hasSecondScreen) {
        self.infosScrollView.scrollEnabled = YES;
        self.scrollPageControl.hidden = NO;

    }else{
        self.infosScrollView.scrollEnabled = NO;
        self.scrollPageControl.hidden = YES;
    }
  
    
    /*********************** Segmented Buttons ******************************/
    [self.segmentedLabels enumerateObjectsUsingBlock:^(OHAttributedLabel * label, NSUInteger index, BOOL *stop) {
        NSString *string;
        NSInteger count;
        switch (index) {
            case SegmentedButtonTracks:
            {
                string = [NSLocalizedString(@"Tracks", nil) uppercaseString];
                count = self.user.nbPosts;
                
            }
                break;
            case SegmentedButtonPlaylists:
            {
                string = [NSLocalizedString(@"Playlists", nil) uppercaseString];
                count = self.user.pl.count;
            }
                break;
            case SegmentedButtonLikes:
            {
                string = [NSLocalizedString(@"Likes", nil) uppercaseString];
                count = self.user.nbLikes;
            }
                break;
        }

        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@  %@",string, [WDHelper stringCountFromInteger:count]]];
        [attrStr setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_1]];
        [attrStr setTextColor:RGBACOLOR(255, 255, 255, .7)];
        NSRange range = NSMakeRange(0, string.length + 1);
        [attrStr setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3] range:range];
        [attrStr setTextColor:UICOLOR_WHITE range:range];
        label.attributedText = attrStr;
        [label setTextAlignment: NSTextAlignmentCenter];

    }];
    

}


- (void) reload
{
    if (self.playlist.tracks.count) {
        self.hasLoadingView = NO;
        [self reloadDatas];
        [self.tableView reloadData];
    }else
    {
        self.hasLoadingView = YES;
    }
    [super reload];
}




-(void)refreshView:(UIRefreshControl *)refresh {
    if (self.currentButton.tag ==  SegmentedButtonPlaylists) {
        [self reloadUserInfos];
    }else
    {
        [super reload];
    }
}

- (void)reloadUserInfos:(void(^)(User *user))success
{
    
    NSDictionary *parameters = @{@"id": self.user.id};
    [[WDClient client] GET:API_USER_INFOS parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"responseObject CRASH %@", responseObject);
        
        
        //TODO CHECK IF CRASH ALWAYS PRESENT https://www.crashlytics.com/whyd/ios/apps/com.whyd.whyd/issues/54685a6865f8dfea151a8826
//        if (responseObject && [responseObject valueForKey:@"_id"]) {
        
            self.user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:nil];
            [self initPlaylists];
            
            if ([[WDHelper manager].currentUser.id isEqualToString:self.user.id]) {
                [User saveAsCurrentUserFromDictionary:responseObject];
            }
        
            if (self.isVisible) {
                [self configureView];
            }
            if([self.refreshControl isRefreshing])
            {
                [self.refreshControl endRefreshing];
            }
            if (self.currentButton.tag ==  SegmentedButtonPlaylists) {
                self.hasPlayAllButton = NO;
                [self.tableView reloadData];
            }
            if(success) success(self.user);
            
//        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];

}
                    

- (void)reloadUserInfos
{
    [self reloadUserInfos:nil];
    
}



- (void)successResponse:(id)responseObject
{
    
    [super successResponse:responseObject];
    [self reloadDatas];
  
}

- (void)reloadDatas
{
    
    switch (self.currentButton.tag) {
        case SegmentedButtonTracks:
        {

            if ([self.user.id isEqualToString:[WDHelper manager].currentUser.id])
            {
                UIButton *searchButton = [[UIButton alloc] init];
                [searchButton setTitle: NSLocalizedString(@"ProfileTracksPlaceholderMeSub", nil) forState:UIControlStateNormal];
                [searchButton sizeToFit];
                searchButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
                [searchButton setTitleColor:RGBCOLOR(180, 182, 184) forState:UIControlStateNormal];
                [searchButton setImage:[UIImage imageNamed:@"ProfileIconSearchSmall"] forState:UIControlStateNormal];
                searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
                searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, searchButton.imageView.frame.size.width);
                [searchButton addTarget:[MainViewController manager] action:@selector(actionOpenSearch) forControlEvents:UIControlEventTouchUpInside];
                searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [self placeholderWithImageName:@"ProfileIconNoTrack" text:NSLocalizedString(@"ProfileTracksPlaceholderMe", nil) andSubView:searchButton ];
            }else
            {
                [self placeholderWithImageName:@"ProfileIconNoTrack" text: NSLocalizedString(@"ProfileTracksPlaceholder", nil) ];
            }
        }
            break;
        case SegmentedButtonPlaylists:
        {
           
        
            if ([self.user.id isEqualToString:[WDHelper manager].currentUser.id])
            {
                [self placeholderWithImageName:@"ProfileIconNoPlaylist" text:NSLocalizedString(@"ProfileUsersPlaceholderMe", nil) ];
            }else
            {
                [self placeholderWithImageName:@"ProfileIconNoPlaylist" text:NSLocalizedString(@"ProfileUsersPlaceholder", nil) ];
            }
        }
            break;
        case SegmentedButtonLikes:
        {
            
      
            if ([self.user.id isEqualToString:[WDHelper manager].currentUser.id])
            {
                [self placeholderWithImageName:@"ProfileIconNoLike" text:NSLocalizedString(@"ProfilePlaylistsPlaceholderMe", nil)];
            }else
            {
                [self placeholderWithImageName:@"ProfileIconNoLike" text:NSLocalizedString(@"ProfilePlaylistsPlaceholder", nil)];
            }
        }
            break;
        default:
            break;
    }
    
    //self.tableView.tableHeaderView = self.headerView;
}

#pragma mark SETTER


- (void)setCurrentButton:(UIButton *)currentButton
{
    _currentButton = currentButton;
    
    switch (currentButton.tag) {
        case SegmentedButtonTracks:
        {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self stopRequests];
            self.loadMoreEnable = YES;
            self.playlist = self.tracksPlaylist;
            [self reload];
            
        }
            break;
        case SegmentedButtonPlaylists:
        {
            
            self.tableView.separatorColor = WDCOLOR_GRAY_BORDER_LIGHT;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.loadMoreEnable = NO;
            self.hasPlayAllButton = NO;
            [self.tableView reloadData];
            self.playlist = nil;
          
            [self reloadUserInfos];
            [self reloadDatas];
            
        }
            break;
        case SegmentedButtonLikes:
        {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            [self stopRequests];
            self.loadMoreEnable = YES;
            self.playlist = self.usersPlaylist;
            [self reload];
        }
            break;
        default:
            break;
    }
    
    
}



#pragma mark Actions

- (void) actionLinks:(UIButton *)button
{
    NSString *linkString;
    switch (button.tag) {
        case LinksButtonFacebook:
        {
            NSString *fbId = [self.user.lnk.fb substringFromIndex:24];
            NSString *facebookInAppString =[ NSString stringWithFormat:@"fb://profile/%@",fbId];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:facebookInAppString]]) {
                linkString = facebookInAppString;
            } else {
                linkString = self.user.lnk.fb;
            }
        }
            break;
        case LinksButtonTwitter:
        {
            linkString = self.user.lnk.tw;
        }
            break;
        case LinksButtonInstagram:
        {
            linkString = self.user.lnk.igrm;
        }
            break;
        case LinksButtonYoutube:
        {
            linkString = self.user.lnk.yt;
        }
            break;
        case LinksButtonSoundcloud:
        {
            linkString = self.user.lnk.sc;

        }
            break;
    }
    NSURL *link = [NSURL URLWithString:linkString];
    [[UIApplication sharedApplication] openURL:link];
}

- (void)actionUserLink
{
    
    
    NSString *linkString = self.user.lnk.home;
    if (![linkString hasPrefix:@"http://"]) {
        linkString = [NSString stringWithFormat:@"http://%@", linkString ];
    }
    NSURL *link = [NSURL URLWithString:linkString];
    [[UIApplication sharedApplication] openURL:link];
}

- (void)actionFollowers
{
    FollowersViewController *vc = [[FollowersViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionFollowing
{
    FollowingViewController *vc = [[FollowingViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionEdit
{
    ProfileEditViewController *vc = [[ProfileEditViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionFollow
{
    
    self.user.isSubscribing = !self.user.isSubscribing;
    NSDictionary *parameters = @{@"tId":self.user.id,
                                @"action": (self.user.isSubscribing)?@"insert":@"delete"};
    [[WDClient client] GET:API_USER_FOLLOW parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    self.followButton.selected = self.user.isSubscribing;
}



- (void)actionTouchUpInside:(UIButton *)button
{
    [self button:button active:YES];
    self.currentButton.selected = NO;
    [self stopRequests];
    self.currentButton = button;
    button.selected = YES;
    

}

- (void)actionTouchDown:(UIButton *)button
{
    if (![self.refreshControl isRefreshing]) {
        [self button:button active:YES];
    }
}


- (void)actionTouchUpOutside:(UIButton *)button
{
    [self button:button active:NO];
    
}


- (void)actionTouchDragOutside:(UIButton *)button
{
    [self button:button active:NO];
}

- (void)button:(UIButton *)button active:(BOOL)active
{
    if (button != self.currentButton) {
        button.alpha = (active)?1:0.5;
        self.currentButton.alpha = (!active)?1:0.5;
    }
}

- (void)actionTapHeader
{
    if (!self.scrollPageControl.hidden) {
        self.scrollPageControl.currentPage = !self.scrollPageControl.currentPage;
        CGRect frame = self.infosScrollView.frame;
        frame.origin.x = frame.size.width * self.scrollPageControl.currentPage;
        frame.origin.y = 0;
        [self.infosScrollView scrollRectToVisible:frame animated:YES];
    }

}

- (void)actionDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)actionPlayAll
{
    [Flurry logEvent:FLURRY_PLAYALL_PROFIL];
    [super actionPlayAll];
}

#pragma mark tableVIew delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.currentButton.tag == SegmentedButtonPlaylists) {
        return self.user.pl.count;
    }else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentButton.tag == SegmentedButtonPlaylists) {
        return 95;
    }else
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.currentButton.tag == SegmentedButtonPlaylists) {
        //PLAYLISTS
        static NSString* CellIdentifierPlaylist = @"SearchPlaylistCell";
        PlaylistUserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierPlaylist];
        
        if (cell == nil)
        {
            cell = [[PlaylistUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierPlaylist ];
        }
        Playlist *playlist = [self.user.pl objectAtIndex:indexPath.row];
        [cell setPlaylist:playlist];
        return cell;
        
        return cell;
    }else
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.currentButton.tag == SegmentedButtonPlaylists) {
        PlaylistViewController *vc = [[PlaylistViewController alloc] initWithPlaylist:[self.user.pl objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.infosScrollView) {
        CGFloat alpha = scrollView.contentOffset.x/self.view.frame.size.width*0.7 ;
        self.secondGradientHeader.backgroundColor = RGBACOLOR(0, 0, 0, alpha);
    }
    
    if (scrollView == self.tableView && scrollView.contentOffset.y < 65) {
        if ( scrollView.contentOffset.y < 65) {
            CGRect frame = self.headerImageView.frame;
            frame.size.height = 281 - scrollView.contentOffset.y;
            frame.origin.y = 0;
            self.headerImageView.frame = frame;
        }
    }

    [super scrollViewDidScroll:scrollView];

}


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    
    if(self.infosScrollView == scrollView)
    {
        NSInteger pageNumber = roundf(scrollView.contentOffset.x / (scrollView.frame.size.width));
        self.scrollPageControl.currentPage = pageNumber;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
