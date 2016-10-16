//
//  PlaylistViewController.m
//  Whyd
//
//  Created by Damien Romito on 01/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PlaylistViewController.h"
#import "WDPlayerManager.h"
#import "UIImage+Additions.h"
#import "UIImageView+WebCache.h"
#import "UserViewController.h"
#import "WDHelper.h"
#import "WDShareSheet.h"
#import "WDMessage.h"

@interface PlaylistViewController ()
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageContainer;
@property (nonatomic, strong) UIImageView *gradientBackground;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tracksCountLabel;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) WDShareSheet *shareSheet;
@property (nonatomic, strong) WDTrack *preloadedTrack;
@end

@interface PlaylistViewController()<UIScrollViewDelegate>

@end

@implementation PlaylistViewController

- (instancetype)initWithPlaylist:(Playlist *)playlist playingTrack:(WDTrack*)currentTrack
{
    self = [self initWithPlaylist:playlist];
    if (self) {
        self.preloadedTrack = currentTrack;
    }
    return self;
}


- (instancetype)initWithPlaylist:(Playlist *)playlist
{
    self = [super init];
    if (self) {
        self.playlist = playlist;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)loadView
{
    self.title = [NSLocalizedString(@"PlaylistTitle", nil) uppercaseString];
    [super loadView];
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];

    //IF MODAL
    if (self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingsIconClose"] style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
    }
    
    //IMAGE
    self.imageContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 185)];
    self.imageContainer.image = [UIImage imageNamed:@"PlaylistBackgroundPlaceholder"];
    self.imageContainer.backgroundColor = WDCOLOR_GRAY;
    self.imageContainer.contentMode = UIViewContentModeScaleAspectFill;
    self.imageContainer.clipsToBounds = YES;
    [self.view  addSubview:self.imageContainer];
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.imageContainer.frame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.clipsToBounds = YES;
    [self.imageContainer addSubview:self.imageView];

    
    self.gradientBackground = [[UIImageView alloc] initWithFrame:self.imageContainer.frame];
    self.gradientBackground.image =[UIImage imageNamed:@"PlaylistBackgroundGradientCover"] ;
    self.gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.gradientBackground.clipsToBounds = YES;
    

    self.refreshControl.tintColor = UICOLOR_WHITE;
    [self.imageContainer addSubview:self.gradientBackground];

    [self.view sendSubviewToBack:self.imageContainer];
    
    self.tableView.backgroundColor = UICOLOR_CLEAR;
    //HEADER
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 186)];
    self.headerView.clipsToBounds = YES;
    self.headerView.backgroundColor = UICOLOR_CLEAR;
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 43, self.view.frame.size.width - 22, 30)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5];
    self.titleLabel.textColor = UICOLOR_WHITE;
    [self.headerView addSubview:self.titleLabel];
    
    self.tracksCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 68, self.view.frame.size.width - 22, 20)];
    self.tracksCountLabel.textAlignment = NSTextAlignmentCenter;
    self.tracksCountLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
    self.tracksCountLabel.textColor = RGBCOLOR(207, 207, 207);
    [self.headerView addSubview:self.tracksCountLabel];
    
    
    UILabel *createByLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 114, self.view.frame.size.width - 22, 10)];
    createByLabel.textAlignment = NSTextAlignmentCenter;
    createByLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_1];
    createByLabel.textColor = RGBCOLOR(207, 207, 207);
    createByLabel.text = [NSLocalizedString(@"CreatedBy", nil) uppercaseString];
    [self.headerView addSubview:createByLabel];
    
    //USER
    self.userButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, 24)];
    [self.userButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
    [self.userButton setTitleColor:[UICOLOR_WHITE colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];

    self.userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.userButton.titleEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0);
    self.userButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_2];
    [self.userButton addTarget:self action:@selector(actionUser) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.userButton];
    
    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.layer.cornerRadius = 12;
    self.userImageView.clipsToBounds = YES;
    [self.userButton addSubview:self.userImageView];
    
    self.tableView.tableHeaderView = self.headerView;
    
    
    
    [self configureView];
    
    if (!self.playlist.tracks.count) {
        [self reload];
    }
//    
//    else
//    {
//        [self updatePreloadedTrack];
//    }
    

    
}
//
//- (void)updatePreloadedTrack
//{
//    ///PRELOADED TRACK
//    if (self.preloadedTrack) {
//        int i = 0 ;
//        for (WDTrack *t in self.playlist.tracks) {
//            if ([t.id isEqualToString:self.preloadedTrack.id]) {
//                if (self.preloadedTrack == t) {
//                    break;
//                }else
//                {
//                    self.preloadedTrack.playlist = self.playlist;
//                    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:self.playlist.tracks];
//                    [mArray replaceObjectAtIndex:i withObject:self.preloadedTrack];
//             
//                    self.playlist.tracks = [mArray copy];
//
//                    
//                    self.preloadedTrack = nil;
//                    break;
//                }
//            }
//            i++;
//        }
//        
//        [self.tableView reloadData];
//        
//        
////        NSIndexPath* ipath = [NSIndexPath indexPathForRow:i inSection:0];
////        [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionMiddle animated: YES];
////    
//    }
//}

- (void)configureView
{
    
    //IMAGE
    NSURL *imageUrl = [NSURL URLWithString:self.playlist.imageUrl ];
    [self.imageView sd_setImageWithURL:imageUrl];
    
    self.titleLabel.text = self.playlist.name;

    self.tracksCountLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)self.playlist.tracks.count , (self.playlist.tracks.count == 1)?[NSLocalizedString(@"Track", nil) uppercaseString] :[NSLocalizedString(@"Tracks", nil) uppercaseString] ];
    [self.userButton setTitle:self.playlist.userName forState:UIControlStateNormal];
    NSURL *avatarUrl = [NSURL URLWithString:[User imageUrl:UserImageSizeSmall ofUserId:self.playlist.userId]];
    [self.userImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
    
    [self.userButton sizeToFit];
    CGRect frame = self.userButton.frame;
    frame.size.width = self.userButton.frame.size.width + 32;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width/2 ;
    self.userButton.frame = frame;
    
    //TRACK OF CURRENT USER CAN EDIT
    
    
    UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TrackPageButtonShare"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionShare)];
    self.navigationItem.rightBarButtonItems = @[ shareBarButton ];
 
 
//    if ([self.playlist.userId isEqualToString:[WDHelper manager].currentUser.id]) {
//        UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TrackPageButtonEdit"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionEdit)];
//        self.navigationItem.rightBarButtonItems = @[ shareBarButton, editBarButton ];
//        
//    }else
//    {
//        self.navigationItem.rightBarButtonItems = @[ shareBarButton ];
//        
//    }
    
   
    


}

#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if ( scrollView.contentOffset.y < 65) {
        CGRect frame = self.imageContainer.frame;
        frame.size.height = 185 - scrollView.contentOffset.y;
        frame.origin.y = 0;
        self.imageContainer.frame = frame;
    }
    
    
}

#pragma -mark ACTIONS

- (void)actionShare
{
    self.shareSheet = [WDShareSheet showInController:self withPlaylist:self.playlist dismiss:^(NSString *message) {
        self.shareSheet = nil;
        if (message) {
            [WDMessage showMessage:message inView:self.view withTopMargin:NO withBackgroundColor:WDCOLOR_GREEN];
        }
    }];
}

- (void)actionEdit
{
    
}

- (void)actionUser
{
    User *user = [User new];
    user.name = self.playlist.userName;
    user.id = self.playlist.userId;
    UserViewController *vc = [[UserViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)successResponse:(id)responseObject
{
    NSLog(@" self.playlist %p", self.playlist);
    NSLog(@" SHUFFLE %d", self.playlist.shuffleEnable);

    [super successResponse:responseObject];
    self.loadMoreEnable = NO;

    
    [self configureView];
    [self placeholderWithImageName:@"ProfileIconNoTrack" text:NSLocalizedString(@"PlaylistPlaceholder", nil)];
    
  //  [self updatePreloadedTrack];
}



- (void)actionDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
