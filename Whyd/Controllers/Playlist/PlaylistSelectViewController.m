//
//  PlaylistSelectViewController.m
//  Whyd
//
//  Created by Damien Romito on 24/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PlaylistSelectViewController.h"
#import "WDHelper.h"
#import "PlaylistCell.h"
#import "UIImage+Additions.h"
#import "WDNavigationController.h"

@interface PlaylistSelectViewController ()
@property (nonatomic, strong) NSArray *playlists;
@property (nonatomic) NSUInteger indexToDelete;

@end

@implementation PlaylistSelectViewController


- (void)loadView
{
    [super loadView];
    self.title = [NSLocalizedString(@"PlaylistSelectTitle", nil) uppercaseString];
    [self.navigationController.navigationBar setTranslucent:NO];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
    self.navigationItem.leftBarButtonItem = cancel;
    
    UIBarButtonItem* create = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionCreate)];
    self.navigationItem.rightBarButtonItem = create;
    
    self.playlists = [WDHelper manager].currentUser.pl;
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    self.tableView.rowHeight = 73;
    self.urlString = API_USER_INFOS;
    [self configureView];

}

- (void)successResponse:(id)responseObject
{
    
    User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:nil];

    if (user == [WDHelper manager].currentUser) {
        
    }else
    {
        self.playlists = user.pl;
        [User saveAsCurrentUser:user];
    }
    
    [super successResponse:responseObject];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)configureView
{
    
    if (self.playlists.count) {
        [self displayNavBarForEmpty:NO];
        self.tableView.tableHeaderView = nil;
    }else
    {
        if (!self.tableView.tableHeaderView) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            self.tableView.tableHeaderView = headerView;
            
            //NO PLAYLIST
            UILabel *infoNoPlaylistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            infoNoPlaylistLabel.backgroundColor = WDCOLOR_BLUE;
            infoNoPlaylistLabel.textColor = UICOLOR_WHITE;
            infoNoPlaylistLabel.text = NSLocalizedString(@"CreateYourFirstPlaylist", nil);
            infoNoPlaylistLabel.textAlignment = NSTextAlignmentCenter;
            infoNoPlaylistLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
            [headerView addSubview:infoNoPlaylistLabel];
            
            //PLACEHOLDER
            UIImageView *playlistImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -25, 135, 47, 45)];
            playlistImage.image = [UIImage imageNamed:@"AddPlaylistIconEmply"];
            [headerView addSubview:playlistImage];
            
            UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 15)];
            placeholderLabel.text = NSLocalizedString(@"YouHaventCreatedAnyPlaylistsYet", nil);
            placeholderLabel.textColor = RGBCOLOR(180, 182, 184);
            placeholderLabel.textAlignment = NSTextAlignmentCenter;
            placeholderLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
            [headerView addSubview:placeholderLabel];
            
            self.tableView.scrollEnabled = NO;
        }
        [self displayNavBarForEmpty:YES];
    }
}

- (void) displayNavBarForEmpty:(BOOL)isEmpty
{
    if (isEmpty) {
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"AddPlaylistBackgroundNoPlaylistTopTriangle"] stretchableImageWithLeftCapWidth:0 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }else
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:RGBCOLOR(237, 237, 237)]];
    }
}

#pragma mark TableView Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playlists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"PlaylistCell";
    
    PlaylistCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[PlaylistCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:CellIdentifier
                              containingTableView:self.tableView // Used for row height and selection
                               leftUtilityButtons:nil
                              rightUtilityButtons:[self rightButtons]];
    }

    cell.delegate = self;

    Playlist *playlist = [self.playlists objectAtIndex:indexPath.row];
    cell.playlist = playlist;
    if (self.selectedPlaylist && [playlist.id isEqualToString:self.selectedPlaylist.id]) {
        cell.isSelected = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistCell *cell = (PlaylistCell *)[tableView cellForRowAtIndexPath:indexPath];
    Playlist *playlist = [self.playlists objectAtIndex:indexPath.row];
    if ([playlist.id isEqualToString:self.selectedPlaylist.id]) {
        [self.delegate PlaylistSelect:nil];
        cell.isSelected = NO;

    }else
    {
        cell.isSelected = YES;
        [self.delegate PlaylistSelect:playlist];
    }
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:WDCOLOR_GRAY_BG_LIGHT
                                                 icon:[UIImage imageNamed:@"CommentButtonDelete"]];
    //    [rightUtilityButtons sw_addUtilityButtonWithColor:
    //     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
    //                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

#pragma mark Actions

- (void)actionDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionCreate
{
    
    PlaylistCreateViewController * vc = [[PlaylistCreateViewController alloc] init];
    vc.delegate = self;
    WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    

}


#pragma mark SWTableViewCell delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteThePlaylist", nil)
                                                            message:NSLocalizedString(@"AreYouSure", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            [alert show];
            
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            self.indexToDelete = cellIndexPath.row ;
            return;
            
            break;
        }
        default:
            break;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:self.indexToDelete inSection:0];
    PlaylistCell *playlistCell = (PlaylistCell*) [self.tableView cellForRowAtIndexPath:cellIndexPath];
    
    if([title isEqualToString:NSLocalizedString(@"No", nil)])
    {
        [playlistCell hideUtilityButtonsAnimated:YES];
    }
    else if([title isEqualToString:NSLocalizedString(@"Yes", nil)])
    {        
  

        NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.playlists];
        [mArray removeObjectAtIndex:cellIndexPath.row ];
        self.playlists = mArray;
        
        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        NSDictionary *parameters = @{@"action": @"delete",
                                     @"id": playlistCell.playlist.id};
        
        [[WDClient client] POST:API_PLAYLIST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"ERROR %@", error);
           // [self reload];
            [self configureView];
        }];
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}


- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return !cell.selected;
}



#pragma mark PlaylistCreate Delegate

- (void)playlistCreated:(Playlist *)playlist
{
    NSMutableArray * mArray = [NSMutableArray arrayWithArray:self.playlists];
    [mArray addObject:playlist];
    self.playlists = mArray;
    [self.tableView reloadData];
    [self reload];
    [self configureView];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
