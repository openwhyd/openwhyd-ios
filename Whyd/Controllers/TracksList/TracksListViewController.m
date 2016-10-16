//
//  TracksListViewController.m
//  Whyd
//
//  Created by Damien Romito on 19/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//
#import "Config.h"
#import "WDHelper.h"

#import "LoginViewController.h"
#import "TrackSearchCell.h"
#import "TracksListViewController.h"
#import "WDPlayerManager.h"
#import "TrackViewController.h"
#import "PlaylistViewController.h"
#import "ProfileViewController.h"
#import "WDMessage.h"
#import "UIImage+Additions.h"
#import "WDNavigationController.h"
#import "WDShareSheet.h"

@interface TracksListViewController()< TrackCellDelegate, MainViewDelegate>
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) BOOL isScrolling;
@property (nonatomic, strong) WDShareSheet *shareSheet;
@end

@implementation TracksListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableviewStyle = UITableViewStyleGrouped;

    }
    return self;
}

-(void)loadView
{
    self.hasPlayAllButton = YES;
    [super loadView];
    self.currentIndex = -1;
    [self.view setBackgroundColor:UICOLOR_WHITE];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];

}


- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MainViewController manager] setDelegate:self];

}


- (void)reload
{
  
    [self.playlist reloadPlaylist:^(Playlist *playlist) {
        
            if (!playlist.tracks) {
                [self anyResponse];
            }else{
                self.loadMoreEnable = playlist.allowLoadMore;
                [self successResponse:nil];
            }
        

    } failure:^(NSError *error) {
        
        [[MainViewController manager] handleError:error];
        [self failureResponse:error];
        

    }];
    [super reload];
}


- (void)loadMore
{
    [self.playlist loadMore];
    [super loadMore];
}


- (void) actionPlayAll
{
   
    if(self.playlist && self.playlist.tracks.count)
    {
        [[WDPlayerManager manager] playAtIndex:0 inPlayList:self.playlist];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)setPlaylist:(Playlist *)playlist
{
    _playlist = playlist;
   // _playlist.delegate = self;
}


#pragma -mark TableView Delegate



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    if (self.hasPlayAllButton) {
        UIButton* playAllButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
        [playAllButton setImage:[UIImage imageNamed:@"PlaylistPlayAll"] forState:UIControlStateNormal];
        [playAllButton setImage:[UIImage imageNamed:@"PlaylistPlayAllActive"] forState:UIControlStateHighlighted];
        [playAllButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
        [playAllButton setTitleColor:WDCOLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
        playAllButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        playAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
        playAllButton.imageEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
        playAllButton.backgroundColor = UICOLOR_WHITE;
       // [playAllButton setBackgroundImage:[UIImage imageWithColor:UICOLOR_WHITE] forState:UIControlStateNormal];
     //   [playAllButton setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(225, 228, 231)] forState:UIControlStateHighlighted];
        [playAllButton setTitle:[NSLocalizedString(@"PlayAll", nil) uppercaseString] forState:UIControlStateNormal];
        
        [playAllButton addTarget:self action:@selector(actionPlayAll) forControlEvents:UIControlEventTouchUpInside];
        return playAllButton;
    }

    return nil;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.hasPlayAllButton && self.playlist.tracks.count)
        return 45;
    else
    {
        self.hasPlayAllButton = YES;
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.playlist.tracks.count;
    //self.hasLoadingView
    return count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 255;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"SearchCell";
    
    TrackCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[TrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    WDTrack *track =[self.playlist.tracks objectAtIndex:indexPath.row];
    //track.playlist = self.playlist;

    
//    @try {
        cell.track = track;
//    }
//    @catch (NSException *exception) {
//       // [[NSNotificationCenter defaultCenter] postNotificationName:WDPlayerItemDeallocNotification object:cell.track.playerItem];
//
//        NSLog(@"EXCEPTION %@",exception);
//    }
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell isKindOfClass:[TrackCell class]]) {
//        [(TrackCell *)cell disappear];
//    }
//}
#pragma ScrollView Dragging


//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    self.isScrolling = NO;
//}
//
//
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    self.isScrolling = YES;
//}
//
//- (void)setIsScrolling:(BOOL)isScrolling
//{
//
//    if (isScrolling != self.isScrolling) {
//        _isScrolling = isScrolling;
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:(isScrolling)
//                                                                  ?TRACKSLIST_WILL_BEGIN_DRAGGING
//                                                                  :TRACKSLIST_DID_END_DECELERATING object:nil];
//
//    
//    }
//    
//}
#pragma mark TrackCell Delegate


- (void)trackCell:(TrackCell *)cell repost:(WDTrack *)track
{
    EditTrackViewController* vc = [[EditTrackViewController alloc] initWithTrack:track fromPLaylist:self.playlist];
    vc.delegate = self;
    vc.isNew = YES;
    WDNavigationController* nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)trackCell:(TrackCell *)cell openUser:(User *)user
{

    UserViewController *vc = [[UserViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)trackCell:(TrackCell *)cell openPlaylist:(Playlist *)playlist
{
    PlaylistViewController *vc = [[PlaylistViewController alloc] initWithPlaylist:playlist playingTrack:cell.track];
//    if ([WDPlayerManager manager].currentTrack == cell.track) {
//        vc = [[PlaylistViewController alloc] initWithPlaylist:playlist playingTrack:cell.track];
//
//    }else
//    {
//        vc = [[PlaylistViewController alloc] initWithPlaylist:playlist playingTrack:cell.track];
////        vc = [[PlaylistViewController alloc] initWithPlaylist:playlist];
//    }
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)trackCellOpenDetail:(TrackCell*)cell
{
    TrackViewController * trackView = [[TrackViewController alloc] init];
    trackView.playlist = self.playlist;
    
    
    trackView.track = cell.track;
    trackView.tag = cell.tag;
    
    [self.navigationController pushViewController:trackView animated:YES];
}

- (void)trackCell:(TrackCell *)cell editTrack:(WDTrack *)track
{

    EditTrackViewController *vc = [[EditTrackViewController alloc] initWithTrack:track fromPLaylist:self.playlist];
    WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (void)trackCell:(TrackCell *)cell shareTrack:(WDTrack *)track
{
    self.shareSheet = [WDShareSheet showInController:self withTrack:track dismiss:^(NSString *message) {
        self.shareSheet = nil;
        if (message) {
            [WDMessage showMessage:message inView:self.view withTopMargin:NO withBackgroundColor:WDCOLOR_GREEN];
        }
    }];
  
}


- (void)trackCellPlay:(TrackCell *)cell
{
    [[WDPlayerManager manager] playAtIndex:cell.tag inPlayList:self.playlist];
}

- (void)trackCellPlayUnaivailable
{
    [WDMessage showMessage:NSLocalizedString(@"UnavailableTrack", nil) inView:self.view withTopMargin:NO];
}

- (void) stopTrackCell
{
    
}



#pragma MainView Delegate
- (void)highlightCurrentTrackAtIndex:(NSInteger)index
{
    if ([WDPlayerManager manager].playlist == self.playlist) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        @try {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        @catch (NSException *exception) {
            
        }
       
        
    }else
    {
        DLog(@"you are not on the right playlist");
    }
    
}

#pragma mark Tests for admins

//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (motion == UIEventSubtypeMotionShake)
//    {
//        if([[WDHelper manager] isAdmin])
//        {
//           // [[Tests manager] toggleTestPlaylist:self.playlist.tracks];
//            DLog(@"test desactivé pour instbug");
//        }
//    }
//}
//


@end
