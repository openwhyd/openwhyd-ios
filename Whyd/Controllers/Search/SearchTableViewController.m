//
//  SearchTableViewController.m
//  Whyd
//
//  Created by Damien Romito on 22/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SearchTableViewController.h"
#import "WDPlayerManager.h"
#import "MainViewController.h"
#import "PlaylistViewController.h"
#import "UserViewController.h"
#import "EditTrackViewController.h"
#import "TrackViewController.h"
#import "WDMessage.h"
#import "WDNavigationController.h"

@interface SearchTableViewController()
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, weak) TrackSearchCell *currentCellInPreview;

@end
@implementation SearchTableViewController 

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lockReload = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
   
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationController.navigationBarHidden = NO;
    
    self.currentIndex = -1;
    
    //BUTTON
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
    self.navigationItem.rightBarButtonItem = closeButton;

    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    self.tableView.separatorColor = WDCOLOR_GRAY_BORDER_LIGHT;
    
}





- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    self.tableView.backgroundColor = UICOLOR_WHITE;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

   // self.tableView.frame = self.view.bounds;
    
}


#pragma mark TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    switch (self.searchType) {
            
            
        case SearchTypeTrack:
        {
  
            TrackSearchCell *cell;
            WDTrack *track = [self.resultsArray objectAtIndex:indexPath.row];
            
            
            if (track.user) {
                static NSString* CellIdentifierTrackWhyd = @"SearchTrackWhydCell";
                cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierTrackWhyd];
                if (cell == nil)
                {
                    cell = [[TrackSearchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierTrackWhyd andType:SearchCellTypeWhyd];
                }

            }else
            {
                static NSString* CellIdentifierTrackExternal = @"SearchTrackExternalCell";
                
                //TRACKS
                cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierTrackExternal];
                
                if (cell == nil)
                {
                    cell = [[TrackSearchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierTrackExternal andType:SearchCellTypeExternal];
                }
            }
            
            cell.tag = indexPath.row;
            cell.delegate = self;
            cell.track = track;
            //TRACKS


            return cell;
        }
            break;
        case SearchTypePlaylist:
        {
            //PLAYLISTS
            static NSString* CellIdentifierPlaylist = @"SearchPlaylistCell";
            PlaylistSearchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierPlaylist];
            
            if (cell == nil)
            {
                cell = [[PlaylistSearchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierPlaylist];
            }
            Playlist *playlist = [self.resultsArray objectAtIndex:indexPath.row];
            cell.playlist = playlist;
            
            return cell;
            
        }
            break;
        case SearchTypeUser:
        {
            //USERS
            static NSString* CellIdentifierUser = @"SearchUserCell";
            UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierUser];
            
            if (cell == nil)
            {
                cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierUser];
            }
            User *user = [self.resultsArray objectAtIndex:indexPath.row];
            cell.user = user;
            return cell;
            
        }
            break;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIViewController *vc;
    
    switch (self.searchType) {
        case SearchTypeTrack:
        {
            TrackSearchCell * cell = (TrackSearchCell*)[self.tableView cellForRowAtIndexPath:indexPath];

            if (cell.type == SearchCellTypeWhyd) {
                vc = [[TrackViewController alloc] init];
                ((TrackViewController*)vc).playlist = self.playlist;
                ((TrackViewController*)vc).track =  [self.resultsArray objectAtIndex:indexPath.row];
                ((TrackViewController*)vc).tag = cell.tag;
            }else
            {
                [self trackCellAdd:cell];
            }

        }
            break;
        case SearchTypePlaylist:
        {
            vc = [[PlaylistViewController alloc] initWithPlaylist:[self.resultsArray objectAtIndex:indexPath.row]];
        }
            break;
        case SearchTypeUser:
        {
            vc = [[UserViewController alloc] initWithUser:[self.resultsArray objectAtIndex:indexPath.row]];
        }
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
    
}


#pragma -mark ACTION


- (void)actionDismiss
{
    [self.delegate searchViewDismissed];
}




#pragma mark TrackSearchCell Delegate

- (void)playTrackCell:(TrackSearchCell *)cell
{

    [[WDPlayerManager manager] playAtIndex:cell.tag inPlayList:self.playlist];

    
}


- (void)trackCellPlay:(TrackSearchCell *)cell
{
    [[WDPlayerManager manager] playAtIndex:cell.tag inPlayList:self.playlist];
}


- (void)trackCellAdd:(TrackSearchCell*)cell
{
    EditTrackViewController *vc = [[EditTrackViewController alloc] initWithTrack:cell.track fromPLaylist:self.playlist];
    vc.tag = cell.tag;
    vc.isNew = YES;
    WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    [Flurry logEvent:FLURRY_ADD_FROM_SEARCH];

}

- (void)trackCellPlayUnaivailable
{
    [WDMessage showMessage: NSLocalizedString(@"UnavailableTrack", nil) inView:self.view withTopMargin:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
