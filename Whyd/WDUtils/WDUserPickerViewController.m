//
//  WDUserPickerViewController.m
//  Whyd
//
//  Created by Damien Romito on 08/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDUserPickerViewController.h"
#import "UserCell.h"
#import "WDHelper.h"
#import "WDClient.h"
#import <UITableView+NXEmptyView.h>
#import "MainViewController.h"
#import "WDActivityIndicatorView.h"

@interface WDUserPickerViewController () <THContactPickerDelegate>

@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, strong) NSMutableArray *selectedUsersUids;
@property (nonatomic, strong) WDTrack *track;
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic, strong) UIActivityIndicatorView *searchIndicator;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;

@end

@implementation WDUserPickerViewController

static const CGFloat kPickerViewHeight = 100.0;

NSString *THContactPickerContactCellReuseID = @"THContactPickerContactCell";

@synthesize contactPickerView = _contactPickerView;

+ (instancetype)pickerWithTrack:(WDTrack*)track
{
    WDUserPickerViewController *vc = [[WDUserPickerViewController alloc] init];
    vc.track = track;
    return vc;
}

+ (instancetype)pickerWithPlaylist:(Playlist*)playlist
{
    WDUserPickerViewController *vc = [[WDUserPickerViewController alloc] init];
    vc.playlist = playlist;
    return vc;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = [NSLocalizedString(@"SearchUserPickerTitle", nil) uppercaseString];
        self.contacts = @[];/* [NSArray arrayWithObjects:@"Tristan Himmelman",
                             @"John Snow", @"Alex Martin", @"Nicolai Small",@"Thomas Lee", @"Nicholas Hudson", @"Bob Barss",
                             @"Andrew Stall", @"Marc Sarasin", @"Mike Beatson",@"Erica Slon", @"Eric Anderson", @"Josh Salpeter", nil];*/
        
        self.selectedUsersUids = [[NSMutableArray alloc] init];
        

        self.contacts = [[NSArray alloc] initWithArray:[WDHelper favoritesUsers]];
        self.filteredContacts = self.contacts;
        
    
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = UICOLOR_WHITE;
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingsIconClose"] style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share",nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionShare)];
    self.navigationItem.rightBarButtonItem = done;

    
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
//    
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPickerViewHeight)];
    self.contactPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.contactPickerView.delegate = self;
   // [self.contactPickerView setPlaceholderLabelText:@"Who would you like to message?"];
//    [self.contactPickerView setPromptLabelText:@"To:"];
    //[self.contactPickerView setLimitToOne:YES];
    [self.view addSubview:self.contactPickerView];
    
    self.searchIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.searchIndicator.frame = CGRectMake(self.view.frame.size.width - self.searchIndicator.frame.size.width - 17, 13, 30, 30);
    [self.view addSubview:self.searchIndicator];
    
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];

    
    CALayer *layer = [self.contactPickerView layer];
    layer.borderColor = RGBCOLOR(237, 237, 237).CGColor;
    layer.borderWidth = .5;
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor =  WDCOLOR_GRAY_BORDER_LIGHT;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [UIView new];


    //PLACEHOLDER
    UIView *placeholderView = [[UIView alloc] init];
    
    UIImageView *placeholderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareViaWhydIconSearchPeople"]];
    placeholderImage.contentMode =UIViewContentModeScaleAspectFill;
    CGRect frame = placeholderImage.frame;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width/2;
    frame.origin.y = (IS_IPHONE_5)?50:15;
    placeholderImage.frame = frame;
    [placeholderView addSubview:placeholderImage];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, placeholderImage.frame.origin.y + 25, self.view.frame.size.width - 40, 100)];
    textLabel.text = NSLocalizedString(@"SearchUserPickerPlaceholder", nil);
    textLabel.textColor = WDCOLOR_BLUE_DARK;
    textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    [placeholderView addSubview:textLabel];
//
    self.tableView.nxEV_emptyView = placeholderView;
    
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
}



- (void)viewDidLayoutSubviews {
    [self adjustTableFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)selectedContacts{
    return [self.privateSelectedContacts copy];
}


#pragma mark - ACTION


- (void)actionDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionShare
{
        [self.loadingView startAnimating];
    [WDHelper favoritesUsersSave:self.privateSelectedContacts];

    if (self.track) {
        NSDictionary *parameters = @{@"pId":self.track.id,
                                     @"uidList": self.selectedUsersUids  ,
                                     };
   
        [[WDClient client] POST:API_TRACK_SHARE(self.track.id) parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {

            [self dismissViewControllerAnimated:YES completion:^{
                
                [Flurry logEvent:FLURRY_SHARE_WHYD];

                [[MainViewController manager] handleMessage:NSLocalizedString(@"SearchUserPickerTrackSuccess", nil)];
                [self.loadingView stopAnimating];
            }];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self displayError];
        }];

    }else if (self.playlist)
    {
        NSString *playlistId = [NSString stringWithFormat:@"%@_%@", self.playlist.userId, self.playlist.id];

        NSDictionary *parameters = @{@"plId": playlistId,
                                     @"uidList": self.selectedUsersUids,
                                     @"action": @"sendToUsers"
                                     };
        
        [[WDClient client] POST:API_PLAYLIST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [Flurry logEvent:FLURRY_SHARE_WHYD];

                    [[MainViewController manager] handleMessage:NSLocalizedString(@"SearchUserPickerPlaylistSuccess", nil)];
            }];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self displayError];
        }];
    }


}

- (void) displayError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorUnknownTitle", nil) message:NSLocalizedString(@"ErrorUnknown", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    [alert show];
}
#pragma mark - Publick properties

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _contacts;
    }
    return _filteredContacts;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}

#pragma mark - Private methods

- (void)adjustTableFrame {
    CGFloat yOffset = self.contactPickerView.frame.origin.y + self.contactPickerView.frame.size.height;
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset);
    self.tableView.frame = tableFrame;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}



- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return [NSPredicate predicateWithFormat:@"self contains[cd] %@", text];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.filteredContacts objectAtIndex:indexPath.row];
}

- (void) didChangeSelectedItems {
    
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:THContactPickerContactCellReuseID];
    if (cell == nil){
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THContactPickerContactCellReuseID withType:UserCellTypePick];
    }
    
    [cell setUser:[self.filteredContacts objectAtIndex:indexPath.row]];
    
    if ([self.privateSelectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.active = YES;
    } else {
        cell.active = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserCell *cell = (UserCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    User *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.privateSelectedContacts containsObject:contact]){ // contact is already selected so remove it from ContactPickerView
        cell.active = NO;
        [self.privateSelectedContacts removeObject:contact];
        [self.contactPickerView removeContact:contact];
        [self.selectedUsersUids removeObject:contact.id];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.active = YES;
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:contact.name];
        [self.selectedUsersUids addObject:contact.id];
    }
    
    self.filteredContacts = self.contacts;
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)searchUsersWithString:(NSString*)searchString
{
    NSDictionary *parameter = @{@"q":searchString};
    [self.searchIndicator startAnimating];
    
    [[WDClient client] GET:API_SEARCH_USER parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"Result for %@ =>%@",searchString,[responseObject objectForKey:@"hits"]);
        self.filteredContacts = [User parseUsersArray:[responseObject objectForKey:@"hits"]];
        [self.tableView reloadData];
        [self.searchIndicator stopAnimating];
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [self.searchIndicator stopAnimating];

         DLog(@"ERROR %@", error);
     }];
}

        

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    
    if (textViewText.length >1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(searchUsersWithString:) withObject:textViewText afterDelay:.5];
    }
    
//    if ([textViewText isEqualToString:@""]){
//        self.filteredContacts = self.contacts;
//    } else {
//        NSPredicate *predicate = [self newFilteringPredicateWithText:textViewText];
//        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
//    }
//    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    CGRect frame = self.tableView.frame;
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    self.tableView.frame = frame;
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.contacts indexOfObject:contact];
    UserCell *cell = (UserCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.active = NO;
    [self didChangeSelectedItems];
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

@end
