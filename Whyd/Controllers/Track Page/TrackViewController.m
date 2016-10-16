//
//  TrackViewController.m
//  Whyd
//
//  Created by Damien Romito on 19/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TrackViewController.h"
#import "WDTrack.h"
#import "UIImageView+WebCache.h"
#import "TrackCommentCell.h"
#import "CommentsViewController.h"
#import "WDClient.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "WDHelper.h"
#import "WDLabel.h"
#import "UIImage+Additions.h"
#import "PlaylistViewController.h"
#import "UserViewController.h"
#import "UsersViewController.h"
#import "GHContextMenuView.h"
#import "WDPlayerButton.h"
#import "WDMessage.h"
#import "WDNavigationController.h"
#import "WDShareSheet.h"

static const NSInteger HEIGHT_HEADER = 150;


@interface TrackViewController ()< GHContextOverlayViewDelegate>
@property (nonatomic, strong) WDShareSheet *shareSheet;
@property (nonatomic, strong) UIBarButtonItem *likeBarButton;


@property (nonatomic, strong) UITableView* tableView;

//HEADER TABLEVIEW
@property (nonatomic, strong) UIView *tableViewHeader;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIView *backgroundUnavailable;
@property (nonatomic, strong) UIImageView *gradientBackground;
@property (nonatomic, strong) WDPlayerButton* playButton;

@property (nonatomic, strong) UIView *topInfosContainer;
@property (nonatomic, strong) WDLabel* titleLabel;
@property (nonatomic, strong) OHAttributedLabel* repostLabel;
@property (nonatomic, strong) UIView* statsContainer;
@property (nonatomic, strong) UIView* statsSeparator;
@property (nonatomic, strong) UIButton* statsLikesButton;
@property (nonatomic, strong) UIButton* statsRepostsButton;
@property (nonatomic, strong) UIButton* statsCommentsButton;

@property (nonatomic) CGFloat topInfosBottom;
@property (nonatomic) CGFloat topInfosHeight;
//USER
@property (nonatomic, strong) UIView *userView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIImageView* userAvatarImage;
@property (nonatomic, strong) UILabel* userLabel;
@property (nonatomic, strong) UIButton *timeButton;
@property (nonatomic, strong) UIButton *playlistButton;
@property (nonatomic, strong) UIImageView *playlistImage;
@property (nonatomic, strong) UIButton *commentInput;
@property (nonatomic, strong) UIImageView *userImageView;

@property (nonatomic, strong) UIButton *commentsHeaderButton;

//FOOTER
@property (nonatomic, strong) UILabel* poweredByLabel;

@property (nonatomic) BOOL isScrolling;


@end


@implementation TrackViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"track.state" options:NSKeyValueObservingOptionNew context:NULL];
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    //IF MODAL
    if (self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingsIconClose"] style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
    }
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    self.view.backgroundColor = WDCOLOR_WHITE;
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    /*********************************** IMAGE ***********************************/
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.imageView.backgroundColor = UICOLOR_BLACK;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];
    
    self.backgroundUnavailable = [[UIView alloc] initWithFrame:self.imageView.frame];
    self.backgroundUnavailable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundUnavailable.backgroundColor = RGBACOLOR(24, 27, 31, .76);
    [self.imageView addSubview:self.backgroundUnavailable];
    
    
    
    //TABLE VIEW
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UICOLOR_CLEAR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview: self.tableView];
    
    /***************************************************************************************/
    /*********************************** HEADER TABLEVIEW ***********************************/
    /***************************************************************************************/
    
    
    self.tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    
    
    self.gradientBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"TrackPageBackgroundGradientCover"] stretchableImageWithLeftCapWidth:.5 topCapHeight:0]];
    [self.tableViewHeader addSubview:self.gradientBackground];
    
    
    /*********************************** PLAY BUTTON ***********************************/
    DLog(@"self.view.frame.size.width %f",self.view.frame.size.width);
    
    self.playButton = [[WDPlayerButton alloc] initWithOrigin:CGPointMake(self.view.frame.size.width/2 - 32 , (HEIGHT_HEADER - 64)/2)];
    [self.playButton addTarget:self action:@selector(actionPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.tableViewHeader addSubview:self.playButton];
    
    /*********************************** ACTION BAR ***********************************/
    
    self.topInfosContainer = [UIView new];
    self.topInfosContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableViewHeader addSubview:self.topInfosContainer];
    
    
    //TITLE
    self.titleLabel = [WDLabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5];
    self.titleLabel.textColor = UICOLOR_WHITE;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    self.titleLabel.preferredMaxLayoutWidth = self.view.frame.size.width;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.topInfosContainer addSubview:self.titleLabel];
    
    //VIA
    self.repostLabel = [[OHAttributedLabel alloc] init];
    self.repostLabel.delegate = self;
    self.repostLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topInfosContainer addSubview:self.repostLabel];
    
    
    
    /*********************************** STATS ***********************************/
    
    self.statsContainer = [[UIView alloc] init];
    self.statsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topInfosContainer addSubview:self.statsContainer];
    
    self.statsRepostsButton = [[UIButton alloc] init];
    [self.statsRepostsButton setImage:[UIImage imageNamed:@"TrackPageIconAddNumber"] forState:UIControlStateNormal];
    [self.statsRepostsButton addTarget:self action:@selector(actionRepostsList) forControlEvents:UIControlEventTouchUpInside];
    [self.statsContainer addSubview:self.statsRepostsButton];
    
    self.statsLikesButton = [[UIButton alloc] init];
    [self.statsLikesButton setImage:[UIImage imageNamed:@"TrackPageIconLikeNumber"] forState:UIControlStateNormal];
    [self.statsLikesButton addTarget:self action:@selector(actionLikesList) forControlEvents:UIControlEventTouchUpInside];
    
    [self.statsContainer addSubview:self.statsLikesButton];
    
    self.statsCommentsButton = [[UIButton alloc] init];
    [self.statsCommentsButton setImage:[UIImage imageNamed:@"TrackPageIconCommentNumber"] forState:UIControlStateNormal];
    [self.statsCommentsButton addTarget:self action:@selector(actionOpenComments) forControlEvents:UIControlEventTouchUpInside];
    [self.statsContainer addSubview:self.statsCommentsButton];
    
    
    [self.statsContainer.subviews enumerateObjectsUsingBlock:^(UIButton *b, NSUInteger idx, BOOL *stop) {
        b.imageEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
        b.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_2];
        [b setTitleColor:RGBCOLOR(163, 164, 158) forState:UIControlStateNormal];
        b.translatesAutoresizingMaskIntoConstraints = NO;
        b.layer.borderColor = RGBCOLOR(56, 59, 51).CGColor;
        b.layer.cornerRadius = 1.;
        b.layer.borderWidth = 0.5;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }];
    
    NSDictionary *views = @{
                            @"statsRepostsButton": self.statsRepostsButton,
                            @"statsLikesButton": self.statsLikesButton,
                            @"statsCommentsButton" : self.statsCommentsButton,
                            };
    
    [self.statsContainer addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"H:|-11-[statsRepostsButton]-15-[statsLikesButton]-15-[statsCommentsButton]"
                                         options: NSLayoutFormatAlignAllTop| NSLayoutFormatAlignAllBottom
                                         metrics:0
                                         views:views]];
    
    [self.statsContainer addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:|-7-[statsRepostsButton(23)]-7-|"
                                         options: 0
                                         metrics:0
                                         views:views]];
    
    
    
    
    views = @{
              @"titleLabel": self.titleLabel,
              @"repostLabel": self.repostLabel,
              @"statsContainer" : self.statsContainer,
              
              };
    
    [self.topInfosContainer addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"H:|[titleLabel]|"
                                            options: 0
                                            metrics:0
                                            views:views]];
    
    [self.topInfosContainer addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"V:|[titleLabel]-8-[repostLabel(20)][statsContainer]-8-|"
                                            options:  NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllLeft
                                            metrics:0
                                            views:views]];
    
    
    
    
    /*********************************** USER CONTAINER ***********************************/
    
    
    
    //USER
    self.userButton = [[UIButton alloc] init];
    self.userButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.userButton.backgroundColor = UICOLOR_WHITE;
    [self.userButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
    [self.userButton setTitleColor:WDCOLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
    self.userButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    self.userButton.titleEdgeInsets = UIEdgeInsetsMake(0, 55, 0, 50);
    self.userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.userButton addTarget:self action:@selector(actionUser) forControlEvents:UIControlEventTouchUpInside];
    [self.tableViewHeader addSubview:self.userButton];
    
    self.userAvatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 35, 35)];
    self.userAvatarImage.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatarImage.layer.cornerRadius = 17.5;
    self.userAvatarImage.clipsToBounds = YES;
    [self.userButton addSubview:self.userAvatarImage];
    
    //    self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 180, 60)];
    //    self.userLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    //    self.userLabel.textColor = WDCOLOR_BLUE;
    //    [self.userButton addSubview:self.userLabel];
    
    self.timeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-215, 0, 200, 60)];
    self.timeButton.userInteractionEnabled = NO;
    self.timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.timeButton setTitleColor:WDCOLOR_GRAY forState:UIControlStateNormal];
    self.timeButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_1];
    self.timeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 2, 3);
    [self.timeButton setImage:[UIImage imageNamed:@"PostIconTime"] forState:UIControlStateNormal];
    [self.userButton addSubview:self.timeButton];
    
    
    //    //PLAYLIST
    
    self.playlistButton = [UIButton new];
    self.playlistButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playlistButton.backgroundColor = UICOLOR_WHITE;
    self.playlistButton.layer.borderColor = WDCOLOR_WHITE.CGColor ;
    self.playlistButton.layer.borderWidth = .5;
    [self.playlistButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
    [self.playlistButton setTitleColor:WDCOLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
    self.playlistButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    [self.playlistButton addTarget:self action:@selector(actionPlaylist) forControlEvents:UIControlEventTouchUpInside];
    self.playlistButton.imageEdgeInsets = UIEdgeInsetsMake(13, 11, 0, 0);
    self.playlistButton.titleEdgeInsets = UIEdgeInsetsMake(30, 21, 0, 30);
    self.playlistButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.playlistButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.playlistButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [self.playlistButton setImage:[UIImage imageNamed:@"PageTrackPlaylistPlaceholder"] forState:UIControlStateNormal];
    
    
    self.playlistImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 13, 35, 35)];
    self.playlistImage.contentMode = UIViewContentModeScaleAspectFill;
    self.playlistImage.clipsToBounds = YES;
    [self.playlistButton addSubview:self.playlistImage];
    
    
    UILabel *inPlaylistLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 17, 200, 12)];
    inPlaylistLabel.textColor = RGBCOLOR(146, 147, 149);
    inPlaylistLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
    inPlaylistLabel.text = [NSLocalizedString(@"inPlaylist", nil) uppercaseString];
    [self.playlistButton addSubview:inPlaylistLabel];
    
    
    UIImageView *accessorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrackPageIconLinkPlaylist"]];
    accessorImage.frame = CGRectMake(self.view.frame.size.width - 20, 24, 8, 14);
    [self.playlistButton addSubview:accessorImage];
    
    [self.tableViewHeader  addSubview:self.playlistButton];
    //PLAYLIST
    
    
    UIView *separatorView =  [UIView new];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO,
    separatorView.backgroundColor = WDCOLOR_WHITE;
    [self.tableViewHeader addSubview:separatorView];
    
    self.commentsHeaderButton = [UIButton new];
    self.commentsHeaderButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.commentsHeaderButton.backgroundColor = RGBCOLOR(251, 251, 251);
    [self.commentsHeaderButton addTarget:self action:@selector(actionOpenComments) forControlEvents:UIControlEventTouchUpInside];
    [self.tableViewHeader addSubview:self.commentsHeaderButton];
    
    
    views = @{
              @"topInfosContainer" : self.topInfosContainer,
              @"userButton":self.userButton,
              @"playlistButton":self.playlistButton,
              @"separatorView":separatorView,
              @"commentsHeaderButton":self.commentsHeaderButton
              };
    NSDictionary *metrics = @{@"HEIGHT_HEADER": [NSNumber numberWithFloat:HEIGHT_HEADER]};
    
    
    [self.tableViewHeader addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[topInfosContainer]|"
                                          options: 0
                                          metrics:0
                                          views:views]];
    [self.tableViewHeader addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-HEIGHT_HEADER-[topInfosContainer][userButton(61)][playlistButton(61)][separatorView(23)][commentsHeaderButton(33)]"
                                          options:  NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllLeft
                                          metrics:metrics
                                          views:views]];
#pragma mark CREATE footer table view
    
    /***************************************************************************************/
    /*********************************** FOOTER TABLE VIEW ***********************************/
    /***************************************************************************************/
    
    UIView* tableViewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 170)];
    tableViewFooter.clipsToBounds = YES;
    tableViewFooter.backgroundColor = WDCOLOR_WHITE;
    self.tableView.tableFooterView = tableViewFooter;
    
    /*********************************** COMMENT INPUT ***********************************/
    
    
    
    self.commentInput = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 62)];
    self.commentInput.backgroundColor = UICOLOR_WHITE;
    self.commentInput.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.commentInput addTarget:self action:@selector(actionWriteComments) forControlEvents:UIControlEventTouchUpInside];
    [tableViewFooter addSubview:self.commentInput];
    
    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 14, 35, 35)];
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.userInteractionEnabled = NO;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 17.5;
    [self.commentInput addSubview:self.userImageView];
    
    
    WDLabel *inputComment = [[WDLabel alloc] initWithFrame:CGRectMake(55, 14, self.view.frame.size.width - 68, 35)];
    inputComment.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    inputComment.text = NSLocalizedString(@"AddAComment", nil);
    inputComment.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    inputComment.textColor = WDCOLOR_GRAY_DARK;
    inputComment.backgroundColor =  RGBCOLOR(250, 250, 250);
    inputComment.layer.borderWidth = 1.;
    inputComment.layer.borderColor = WDCOLOR_WHITE_DARK.CGColor;
    inputComment.layer.cornerRadius = 1.;
    inputComment.clipsToBounds = YES;
    [self.commentInput addSubview:inputComment];
    
    
    
    /*********************************** POWERED ***********************************/
    
    UIView *footerSeparator = [[UIView alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2 - 10, 115, 20, 1)];
    footerSeparator.backgroundColor = RGBCOLOR(225, 225, 225);
    [tableViewFooter addSubview:footerSeparator];
    
    
    self.poweredByLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 127, self.view.frame.size.width, 15)];
    self.poweredByLabel.textAlignment = NSTextAlignmentCenter;
    self.poweredByLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
    self.poweredByLabel.textColor = WDCOLOR_GRAY_TEXT;
    [tableViewFooter addSubview:self.poweredByLabel];
    
    
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MainViewController manager] setDelegate:self];
    
    [self configureView];
    
}

#pragma Configure View

- (void) configureView
{
 //   [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
    //NAVBAR
    [self updateRightBarButtonItems];
    [self updateButtonLike];
    
    
    //LONG TAP
    GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
    overlay.delegate = self;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
    [self.tableViewHeader addGestureRecognizer:longPress];
    self.tableViewHeader.userInteractionEnabled = YES;
    
    [self updateState];
    if (self.track.state == TrackStateUnavailable) {
        [WDMessage showMessage:NSLocalizedString(@"UnavailableTrack", nil) inView:self.view withTopMargin:NO];
    }
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.track.imageUrl]
                      placeholderImage:[UIImage imageWithColor:RGBCOLOR(156, 161, 165)]];
    
    //TITLE
    self.titleLabel.text = self.track.name;
    [self.titleLabel sizeToFit];
    
    //STATS CONTAINER
    // if (self.track.repostsCount) {
    [self.statsRepostsButton setTitle:[NSString stringWithFormat:@"    %d   ",(int)self.track.repostsCount] forState:UIControlStateNormal];
    //}
    
    // if (self.track.likesCount) {
    [self.statsLikesButton setTitle:[NSString stringWithFormat:@"    %d   ",(int)self.track.likesCount] forState:UIControlStateNormal];
    // }
    
    //COMMENTS TABLE VIEW
    //if (self.track.comments.count) {
    [self.statsCommentsButton setTitle:[NSString stringWithFormat:@"    %d   ",(int)self.track.comments.count] forState:UIControlStateNormal];
    // }
    
    
    //REPOST
    if (self.track.repost) {
        
        // [self.repostLabel hidden:NO];
        
        NSString *string = [NSString stringWithFormat:@"   %@ %@", NSLocalizedString(@"TrackViewReaddVia", nil), self.track.repost.user.name];
        NSURL *userURL = [NSURL URLWithString: OPEN_URL_USER(self.track.repost.user.id)];
        NSMutableAttributedString* attributedString = [NSMutableAttributedString attributedStringWithString:string];
        
        NSRange range = [string rangeOfString: NSLocalizedString(@"TrackViewReaddVia", nil)];
        [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2] range:range];
        [attributedString setTextColor:WDCOLOR_WHITE range:range];
        
        range = [string rangeOfString:self.track.repost.user.name];
        [attributedString setLink:userURL range:range];
        [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_2] range:range];
        self.repostLabel.attributedText = attributedString;
        [self.repostLabel hideByHeight:NO];
        
    }else
    {
        [self.repostLabel hideByHeight:YES];
    }
    
    
    
    
    
    //USER INFOS
    [self.userAvatarImage sd_setImageWithURL:[NSURL URLWithString:[self.track.user imageUrl:UserImageSizeSmall]] placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
    [self.userButton setTitle:self.track.user.name forState:UIControlStateNormal];
    [self.timeButton setTitle:self.track.date forState:UIControlStateNormal];
    
    
    //PLAYLIST
    if (self.track.playlist) {
        [self.playlistButton setTitle:[self.track.playlist.name capitalizedString] forState:UIControlStateNormal];
        NSURL *imageUrl = [NSURL URLWithString:self.track.playlist.imageUrl ];
        [self.playlistImage sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"PageTrackPlaylistPlaceholder"]];
        [self.playlistButton hideByHeight:NO];
    }else
    {
        [self.playlistButton hideByHeight:YES];
    }
    
    //COMMENT HEADER
    [[self.commentsHeaderButton subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    OHAttributedLabel *atLabel = [[OHAttributedLabel alloc] init];
    NSMutableAttributedString* attributedString;
    NSString *vString = [NSString stringWithFormat:@"%lu",(unsigned long)self.track.comments.count];
    NSString *tString =(self.track.comments.count > 1)?[NSLocalizedString(@"Comments", nil) uppercaseString] :[NSLocalizedString(@"Comment", nil) uppercaseString] ;
    NSString *string = [NSString stringWithFormat:@"%@ %@", vString, tString];
    attributedString = [NSMutableAttributedString attributedStringWithString:string];
    NSRange range = [string rangeOfString:vString];
    [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3] range:range];
    [attributedString setTextColor:WDCOLOR_GRAY_DARK range:range];
    range = [string rangeOfString:tString];
    [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3] range:range];
    [attributedString setTextColor:WDCOLOR_GRAY range:range];
    atLabel.attributedText = attributedString;
    [atLabel sizeToFit];
    atLabel.frame = CGRectMake(11, 9, 140, 20);
    [self.commentsHeaderButton addSubview:atLabel];
    
    
    [self.tableView reloadData];
    
    NSURL *avatarUrl =[NSURL URLWithString:[[WDHelper manager].currentUser imageUrl:UserImageSizeSmall]];
    [self.userImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
    
    
    
    NSString *poweredString = self.track.sourceKey;
    if([poweredString isEqualToString:WDSourceUnAvailable])
    {
        self.poweredByLabel.text = NSLocalizedString(@"SourceNotSupported", nil);
    }else
    {
        self.poweredByLabel.text = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"TrackViewPowered", nil), [poweredString capitalizedString] ];
    }
    
    [self.topInfosContainer sizeToSubviews];

    //RESIZE FRAME
    self.topInfosBottom = HEIGHT_HEADER + self.topInfosContainer.bounds.size.height;
    self.topInfosHeight = self.topInfosContainer.bounds.size.height;
    
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.topInfosBottom);

    
    CGRect frame = self.gradientBackground.frame;
    frame.origin.y =  self.topInfosBottom - 227;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = 227;
    self.gradientBackground.frame = frame;


    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height );

    if(!self.isScrolling)
    {
        [self.commentsHeaderButton updateSizes];
        CGFloat height = self.commentsHeaderButton.frame.origin.y + self.commentsHeaderButton.frame.size.height;
        self.tableViewHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, height);//);
        self.tableView.tableHeaderView = self.tableViewHeader;
    }

    
}


#pragma mark Action

- (void)actionEdit
{
    EditTrackViewController *vc = [[EditTrackViewController alloc] initWithTrack:self.track fromPLaylist:self.playlist];
    WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)actionShareNavBar
{
    [Flurry logEvent:FLURRY_SHARE_FROM_TRACKPAGE_NAVBAR];
    
    [self actionShare];
}

- (void)actionShare
{
    
    self.shareSheet = [WDShareSheet showInController:self withTrack:self.track dismiss:^(NSString *message) {
        self.shareSheet = nil;
        if (message) {
            [WDMessage showMessage:message inView:self.view withTopMargin:NO withBackgroundColor:WDCOLOR_GREEN];
        }
    }];
}

- (void)actionLikeNavBar
{
    [Flurry logEvent:FLURRY_LIKE_FROM_TRACK_NABARBUTTON];
    [self actionLike];
}


- (void)actionLike
{
    if (self.track.id) {
        NSDictionary *parameters = @{@"pId": self.track.id};
        
        //CREATE SYSTEM TO AVOID A LOT OF REQUEST
        if (self.track.isLiked) {
            self.track.isLiked = NO;
        }else
        {
            self.track.isLiked = YES;
        }
        
        [self updateButtonLike];
        
        [[WDClient client] GET:@"/api/post?action=toggleLovePost" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            //        BOOL isLiked = [[responseObject objectForKey:@"loved"] boolValue];
            // DLog(@"RESPONSE %@", responseObject);
            
            //        self.track.isLiked = isLiked;
            //
            //
            //        [self updateButtonLike];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
    
}


- (void)actionAddNavBar
{
    [Flurry logEvent:FLURRY_ADD_FROM_TRACKPAGE_NAVBAR];
    [self actionAdd];
}
- (void)actionAdd
{
    EditTrackViewController* vc = [[EditTrackViewController alloc] initWithTrack:self.track fromPLaylist:self.playlist];
    vc.delegate = self;
    vc.isNew = YES;
    WDNavigationController* nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
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
            [[WDPlayerManager manager] playAtIndex:self.tag inPlayList:self.playlist];
            break;
        case TrackStateUnavailable:
            [WDMessage showMessage:NSLocalizedString(@"UnavailableTrack", nil) inView:self.view withTopMargin:NO];
            break;
        default:
            break;
            
    }
}


- (void)actionUser
{
    
    UserViewController *vc = [[UserViewController alloc] initWithUser:self.track.user];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionPlaylist
{
    PlaylistViewController *vc = [[PlaylistViewController alloc] initWithPlaylist:self.track.playlist playingTrack:self.track];
    
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)actionRepostsList
{
    if (!self.track.repostsCount) return;
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.urlString = API_USERS_REPOSTS_POST(self.track.id);
    vc.title = [NSLocalizedString(@"TrackViewAdds", nil) uppercaseString];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionLikesList
{
    if (!self.track.likesCount) return;
    
    
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.title = [NSLocalizedString(@"Likes", nil) uppercaseString];
    vc.urlString = API_USERS_LIKES_POST(self.track.id);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionWriteComments
{
    [self actionOpenCommentsEdit:YES];
}

- (void)actionOpenComments
{
    [self actionOpenCommentsEdit:NO];
}


- (void)actionOpenCommentsEdit:(BOOL)editMode
{
    
    CommentsViewController* vc = [[CommentsViewController alloc] init];
    vc.editMode = YES;
    vc.delegate = self;
    vc.track = self.track;
    vc.title = [NSLocalizedString(@"Likes", nil) uppercaseString];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Update interface

- (void)updateButtonLike
{
    if (self.track.isLiked)
    {
        self.likeBarButton.tintColor = RGBCOLOR(189,21,42);
        
        [self.statsLikesButton setContentScaleFactor:1];
        CGAffineTransform t = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:0.2 animations:^{
            CGAffineTransform t = CGAffineTransformIdentity;
            self.statsLikesButton.transform = CGAffineTransformScale(t, 1.2, 1.2);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.statsLikesButton.transform = t;
            } completion:^(BOOL finished) {
            }];
        }];
        
    }else
    {
        self.likeBarButton.tintColor = WDCOLOR_BLUE;
        
    }
    [self.statsLikesButton setTitle:[NSString stringWithFormat:@"    %d   ",(int)self.track.likesCount] forState:UIControlStateNormal];
    
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
            
            self.backgroundUnavailable.hidden = NO;
        }
            break;
            
    }
    
    if (self.track.state != TrackStateUnavailable) {
        
        self.backgroundUnavailable.hidden = YES;
    }
    
}


- (void)updateRightBarButtonItems
{
    //NAVIGATION BAR
    
    UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TrackPageButtonShare"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionShareNavBar)];
    
    //   UIBarButtonItem *repostBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TrackPageButtonAdd"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionRepost)];
    
    UIButton *addButton = [[UIButton alloc] init];
    addButton.layer.cornerRadius = CORNER_RADIUS;
    [addButton setTitle:[NSLocalizedString(@"Add", nil) uppercaseString] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"TrackPageIconButtonAdd"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageWithColor:WDCOLOR_BLUE] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageWithColor:WDCOLOR_BLUE_LIGHT] forState:UIControlStateHighlighted];
    addButton.clipsToBounds = YES;
    addButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_2];
    [addButton sizeToFit];
    CGRect frame = addButton.frame;
    frame.origin.x = 10;
    frame.size.height = 30;
    frame.size.width += 20;
    addButton.frame = frame;
    addButton.titleEdgeInsets = UIEdgeInsetsMake(2, 7, 0, 0);
    addButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
    [addButton addTarget:self action:@selector(actionAddNavBar) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *repostBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    repostBarButton.tintColor = WDCOLOR_BLUE;
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    spacer.width = self.view.frame.size.width - 205;
    
    //TRACK OF CURRENT USER CAN EDIT
    if ([self.track.user.id isEqualToString:[WDHelper manager].currentUser.id]) {
        UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TrackPageButtonEdit"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionEdit)];
        self.navigationItem.rightBarButtonItems = @[repostBarButton, spacer, editBarButton , shareBarButton ];
        
    }else
    {
        self.likeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TrackPageButtonLoveDisable"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionLikeNavBar)];
        self.navigationItem.rightBarButtonItems = @[repostBarButton, spacer, self.likeBarButton , shareBarButton ];
        
    }
    
    
    
}



#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment* comment = [self.track.comments objectAtIndex:indexPath.row];
    
    return [Comment heightForComment:comment];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.track.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CommentCell";
    
    TrackCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[TrackCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    cell.comment = [self.track.comments objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self actionOpenComments];
}

#pragma  mark TRACK COMMENT CELL DELEGATE

- (void)trackCommentCell:(CommentCell *)cell openUser:(User *)user
{
    UserViewController *vc = [[UserViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:vc animated:YES];
    
}


-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    
    [self.navigationController pushViewController:[WDHelper viewControllerToPushWithLinkInfo:linkInfo] animated:YES];
    return YES;
}



- (UIColor *)attributedLabel:(OHAttributedLabel *)attributedLabel colorForLink:(NSTextCheckingResult *)linkInfo underlineStyle:(int32_t *)underlineStyle
{
    return RGBCOLOR(205, 205, 205);
}



#pragma MainView Delegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateState];
    
}



#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
    if ( scrollView.contentOffset.y < 65) {
        CGRect frame = self.imageView.frame;
        
        frame.size.height = self.topInfosBottom - scrollView.contentOffset.y;
        
        
        
        frame.origin.y = 0;
        self.imageView.frame = frame;
        
        frame = self.playButton.frame;
        frame.origin.y = (self.imageView.frame.size.height - self.topInfosHeight) /2 - frame.size.height/2 + scrollView.contentOffset.y;
        self.playButton.frame = frame;
        
        if (scrollView.contentOffset.y<-100) {
            self.playButton.alpha = 0;
        }else
        {
            self.playButton.alpha = abs(100+scrollView.contentOffset.y)/100.;
        }
        
    }
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
}




#pragma mark GHContextMenu Delegate


- (void)didSelectItemType:(MenuActionType)type
{
    
    switch (type) {
        case MenuActionTypeAdd:
            [Flurry logEvent:FLURRY_ADD_FROM_TRACKPAGE_LONGTAP];
            
            [self actionAdd];
            break;
        case MenuActionTypeLike:
            [Flurry logEvent:FLURRY_LIKE_FROM_PLAYER_LONGTAP];
            [self actionLike];
            
            break;
            
        case MenuActionTypeEdit:
            [self actionEdit];
            
            break;
        case MenuActionTypeShare:
            [Flurry logEvent:FLURRY_SHARE_FROM_TRACKPAGE_LONGTAP];
            
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"MEMORY WARNING TRACK VIEW");
    // Dispose of any resources that can be recreated.
}

@end