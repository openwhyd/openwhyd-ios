//
//  SearchViewController.m
//  Whyd
//
//  Created by Damien Romito on 11/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//
#import "SearchViewController.h"
#import "WDTrack.h"
#import "UIImage+Additions.h"
#import "WDLabel.h"
#import "WDHelper.h"
#import "PlaylistViewController.h"
#import "UserViewController.h"
#import "EditTrackViewController.h"
#import "SearchDetailsViewsController.h"


static const NSInteger MAX_USERS_RESULT = 2;
static const NSInteger MAX_PLAYLISTS_RESULT = 2;
static const NSInteger MAX_TRACKS_RESULT = 4;

@interface SearchViewController ()
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) WDSearchEngines *search;

@property (nonatomic, strong) UIActivityIndicatorView *searchSpinner;
@property (nonatomic, strong) UIActivityIndicatorView *searchSpinnerBar;

@property (nonatomic, strong) UIImageView *searchImage;

@property (nonatomic, strong) NSArray *tracksWhyd;
@property (nonatomic, strong) NSArray *tracksYoutube;
@property (nonatomic, strong) NSArray *tracksSoundcloud;

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic) NSInteger totalType;
@property (nonatomic, strong) NSArray *playlists;
@property (nonatomic, strong) NSArray *users;

@property (nonatomic, strong) UILabel *noresultLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapPlaceholder;
@property (nonatomic ) CGFloat currentFooterInSectionHeight;
@property (nonatomic) BOOL readyToDisplayResults;

@end

@implementation SearchViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableviewStyle = UITableViewStyleGrouped;
        
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = WDCOLOR_BLACK_TRANSPARENT;

    /************* SEARCH BAR **********************/
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.searchBar setImage:[UIImage imageNamed:@"SearchIconSearch"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchBar.placeholder = NSLocalizedString(@"SearchPlaceholder", nil); //HACK DE NOOB
    self.searchBar.delegate = self;
    [self.searchBar setTintColor:RGBCOLOR(87, 99, 106)];
    [self.searchBar becomeFirstResponder];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:RGBCOLOR(87, 99, 106)];
    self.navigationItem.titleView = self.searchBar;
    
    for (UIView *subview in self.searchBar.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }

    
    self.searchSpinnerBar = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.navigationItem.titleView addSubview:self.searchSpinnerBar];
    self.searchSpinnerBar.frame = CGRectMake(self.view.frame.size.width - 125, 15, 15, 15);

    /************* DEFAULT SEARCH CONTENT **********************/
    
    CGFloat diffY= (IS_IPHONE_5)?30:0;
    
    self.searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 -  20, 77+ diffY, 40, 38)];
    self.searchImage.image = [UIImage imageNamed:@"SearchFirstScreenIconSearch"];
    [self.view addSubview:self.searchImage];
    
    
    self.searchSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.searchSpinner.frame = CGRectMake(self.view.frame.size.width / 2 -  20, 77 + diffY, 40, 38);
    [self.view addSubview:self.searchSpinner];
    
    self.tapPlaceholder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDismiss)];
    [self.view addGestureRecognizer:self.tapPlaceholder];
    self.view.userInteractionEnabled = YES;
    
    UILabel *infosLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 -  105, 120+ diffY, 210, 40)];
    infosLabel.numberOfLines = 2;
    infosLabel.text = NSLocalizedString(@"SearchInfo", nil);
    infosLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:13];
    infosLabel.textColor = RGBCOLOR(99, 110, 118);
    infosLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:infosLabel];
    
    [self.view sendSubviewToBack:infosLabel];
    [self.view sendSubviewToBack:self.searchSpinner];
    [self.view sendSubviewToBack:self.searchImage];

    self.tableView.hidden = YES;
   
}


- (void) reloadData
{


    [self.searchBar resignFirstResponder];

    NSMutableArray *mArray  = [NSMutableArray arrayWithArray:self.tracksWhyd];

    if (self.tracksSoundcloud) {
        [mArray addObjectsFromArray:self.tracksSoundcloud];
    }
    if (self.tracksYoutube) {
        [mArray addObjectsFromArray:self.tracksYoutube];
    }

    
    //REMOVE DOUBLONS
    
    NSMutableArray *lookup = [[NSMutableArray alloc] init];

    for (int index = 0; index < [mArray count]; index++)
    {
        WDTrack *t = [mArray objectAtIndex:index];

        NSString *identifier = t.eId;

        if ([lookup containsObject:identifier]) {
            NSUInteger initIndex = [lookup indexOfObject:identifier];
            ((WDTrack *)[mArray objectAtIndex:initIndex]).doublonCount ++;
            [mArray removeObject:t];
            index --;
        }else
        {

            [lookup addObject:identifier];
        }
    }
    
    self.tracks = mArray;
    
    
    
    self.playlist = [Playlist new];
    self.playlist.name = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SearchPlaylistName", nil), self.searchBar.text];
    self.playlist.tracks = self.tracks;
    
    [self.tableView reloadData];
    [self.searchSpinner stopAnimating];

    self.tableView.hidden = NO;
    
    if (self.readyToDisplayResults ) {
        [self.searchSpinnerBar stopAnimating];
    }
    

}

#pragma -mark ACTIONS


- (void)actionSearchWithString:(NSString *)searchString
{
    
    [self.view removeGestureRecognizer:self.tapPlaceholder];
    [self.searchSpinnerBar startAnimating];
    self.searchImage.hidden = YES;
    self.readyToDisplayResults = NO;
    self.tracksYoutube = self.tracksSoundcloud = self.tracksWhyd =  nil;
    self.search = [[WDSearchEngines alloc] initWithSearch:searchString andDelegate:self];
    [self.searchSpinner startAnimating];
}


- (void)actionDismiss
{
    [self stopRequests];
    [self.searchBar resignFirstResponder];
    [super actionDismiss];
    

}

- (void)actionSelectMore:(UIButton *)button
{

    SearchDetailsViewsController *vc = [[SearchDetailsViewsController alloc] init];
    vc.delegate = self.delegate;
    vc.searchType = button.tag;
    NSString *title;
    switch (button.tag) {
        case SearchTypeTrack:
            vc.resultsArray = self.tracks;
            vc.playlist = self.playlist;
            title = [NSLocalizedString(@"Tracks", nil) uppercaseString];
            vc.title = [ NSLocalizedString(@"SearchDetailsTracksTitle", nil) uppercaseString];

            break;
        case SearchTypePlaylist:
            vc.resultsArray = self.playlists;
            title = [NSLocalizedString(@"Playlists", nil) uppercaseString];
            vc.title = [ NSLocalizedString(@"SearchDetailsPlaylistsTitle", nil) uppercaseString];

            break;
        case SearchTypeUser:
            vc.resultsArray = self.users;
            title = [NSLocalizedString(@"Users", nil) uppercaseString];
            vc.title = [ NSLocalizedString(@"SearchDetailsUsersTitle", nil) uppercaseString];

            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma -mark TableView Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    WDLabel* headerSectionLabel= [[WDLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 38)];
    headerSectionLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:13];
    headerSectionLabel.textColor = WDCOLOR_GRAY_TEXT_DARK_MEDIUM;
    headerSectionLabel.backgroundColor = WDCOLOR_WHITE;
    headerSectionLabel.edgeInsets = UIEdgeInsetsMake(3, 11, 0, 0);
    
    switch (section) {
        case SearchTypeTrack:
            headerSectionLabel.text = [NSLocalizedString(@"Tracks", nil) uppercaseString];
            break;
        case SearchTypeUser:
            headerSectionLabel.text = [NSLocalizedString(@"Users", nil) uppercaseString];
            break;
        case SearchTypePlaylist:
            headerSectionLabel.text = [NSLocalizedString(@"Playlists", nil) uppercaseString];
            break;
    }
    
    
    return headerSectionLabel;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    
    if ((section == SearchTypeTrack && self.tracks.count) ||
        (section == SearchTypePlaylist && self.playlists.count) ||
        (section == SearchTypeUser && self.users.count))
    {
        
        if ((section == SearchTypeTrack && self.tracks.count > MAX_TRACKS_RESULT) ||
            (section == SearchTypePlaylist && self.playlists.count > MAX_PLAYLISTS_RESULT) ||
            (section == SearchTypeUser && self.users.count > MAX_USERS_RESULT))
        {
            UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
            [moreButton setTitle: [NSLocalizedString(@"SearchSeeMore", nil) uppercaseString] forState:UIControlStateNormal];
            moreButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
            [moreButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
            [moreButton setTitleColor:WDCOLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
            [moreButton setImage:[UIImage imageNamed:@"SearchIconMoreResult"] forState:UIControlStateNormal];
            [moreButton setImage:[UIImage imageNamed:@"SearchIconMoreResultActive"] forState:UIControlStateHighlighted];
            moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 155, 0, 0);
            moreButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
            moreButton.tag = section;
            [moreButton addTarget:self action:@selector(actionSelectMore:) forControlEvents:UIControlEventTouchUpInside];
            return moreButton;
        }else
        {
            return nil;
        }
    }else
    {
        UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 125)];

        //IMAGE
        UIImageView *placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 25, 20, 50, 50)];
        placeholderImage.contentMode = UIViewContentModeBottom;
        [placeholderView addSubview:placeholderImage];
        
        //LABEL
        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 16)];
        placeholderLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        placeholderLabel.textColor = RGBCOLOR(94, 97, 104);
        placeholderLabel.textAlignment = NSTextAlignmentCenter;
        [placeholderView addSubview:placeholderLabel];
        
        
        switch (section) {
            case SearchTypeTrack:
            {
                placeholderImage.image = [UIImage imageNamed:@"ProfileIconNoTrack"];
                placeholderLabel.text = NSLocalizedString(@"SearchTrackPlaceholder", nil);
            }break;
            case SearchTypePlaylist:
            {
                placeholderImage.image = [UIImage imageNamed:@"ProfileIconNoPlaylist"];
                placeholderLabel.text = NSLocalizedString(@"SearchPlaylistPlaceholder", nil) ;
            }break;
            case SearchTypeUser:
            {
                placeholderImage.image = [UIImage imageNamed:@"SearchIconNoUser"];
                placeholderLabel.text = NSLocalizedString(@"SearchUserPlaceholder", nil) ;
            }break;
        }
        
        return placeholderView;

        
    }
    
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ((section == SearchTypeTrack && self.tracks.count) ||
        (section == SearchTypePlaylist && self.playlists.count) ||
        (section == SearchTypeUser && self.users.count))
    {
        
        if ((section == SearchTypeTrack && self.tracks.count > MAX_TRACKS_RESULT) ||
            (section == SearchTypePlaylist && self.playlists.count > MAX_PLAYLISTS_RESULT) ||
            (section == SearchTypeUser && self.users.count > MAX_USERS_RESULT))
        {
            return 66;
        }else
        {
            return 0.01f;
        }
    }else
    {
        return 125;

    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = 0;
    switch (indexPath.section) {
        case SearchTypeTrack:
            height = 60;
            break;
        case SearchTypePlaylist:
            height = 60;
            break;
        case SearchTypeUser:
            height = 55;
            break;
        default:
            break;

    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
            
        case SearchTypeTrack:
        {
            count = (self.tracks.count > MAX_TRACKS_RESULT)?MAX_TRACKS_RESULT:self.tracks.count;
        }
            break;
        case SearchTypePlaylist:
        {
            count = (self.playlists.count > MAX_PLAYLISTS_RESULT)?MAX_PLAYLISTS_RESULT:self.playlists.count;
        }
            break;
        case SearchTypeUser:
        {
            count = (self.users.count > MAX_USERS_RESULT)?MAX_USERS_RESULT:self.users.count;
        }
            break;
    }

    return count;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setCurrentTypeBySection:indexPath.section];
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setCurrentTypeBySection:indexPath.section];
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)setCurrentTypeBySection:(NSInteger)section
{
    self.searchType = section;
    switch (self.searchType = section) {
        case SearchTypeTrack:
        {
            self.resultsArray = self.tracks;
        }
            break;
        case SearchTypePlaylist:
        {
            self.resultsArray = self.playlists;
        }
            break;
        case SearchTypeUser:
        {
            self.resultsArray = self.users;
        }
            break;
    }
    
}


#pragma mark ScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    
}

#pragma mark SearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self actionSearchWithString:searchBar.text];
    
}


- (void)trackCellPlay:(TrackSearchCell *)cell
{
    self.resultsArray = self.tracks;
    [super trackCellPlay:cell];

    [self.searchBar resignFirstResponder];
    
}


#pragma mark Search Delegate


- (void)searchResultTracksFromWhyd:(NSArray *)tracks andPlaylist:(NSArray *)playlists andUsers:(NSArray *)users
{
    self.playlists = playlists;
    self.users = users;
    self.tracksWhyd = tracks;
    self.readyToDisplayResults = YES;
    [self reloadData];
}


- (void)searchResultTracksFromYoutube:(NSArray *)tracks
{
    self.tracksYoutube = tracks;
    [self reloadData];

}


- (void)searchResultTracksFromSoundCloud:(NSArray *)tracks
{
    self.tracksSoundcloud = tracks;
    [self reloadData];
}



@end
