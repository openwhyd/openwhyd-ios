//
//  OnboardingFacebookViewController.m
//  Whyd
//
//  Created by Damien Romito on 02/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "OnboardingFacebookViewController.h"
#import "UserCell.h"
#import "WDHelper.h"
#import "WDActivityIndicatorView.h"

@interface OnboardingFacebookViewController ()
@property (nonatomic, strong) NSArray *usersFacebook;
@property (nonatomic, strong) NSMutableArray *uIdsToFollowed;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;
@end

@implementation OnboardingFacebookViewController

- (id)initWithFacebookUsers:(NSArray *)facebookUsers andUIdToFollowed:(NSMutableArray *)uIdToFollowed
{
    self = [super init];
    if (self) {
        _usersFacebook = facebookUsers;
        _uIdsToFollowed = uIdToFollowed;

        for (User *user in facebookUsers) {
            if (!user.isSubscribing) {
                [_uIdsToFollowed addObject:user.id];
                user.isSubscribing = YES;
            }
        }
        
        
    }
    return self;
}



- (void)loadView
{
    [super loadView];
    
    self.title = [NSLocalizedString(@"OnboardingFacebookTitle", nil) uppercaseString];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionNext)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    //HEADER
    UIImageView *headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OnboardingFriendsCoverPhoto.jpg"]];
    
    UIImageView *facebookImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OnboardingFriendsIconFacebook"]];
    CGRect frame = facebookImage.frame;
    frame.origin.x = self.view.frame.size.width / 2 - facebookImage.frame.size.width/2;
    frame.origin.y = 23;
    facebookImage.frame = frame;
    [headerView addSubview:facebookImage];
    
    UILabel *infosLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 85, self.view.frame.size.width - 60, 45)];
    infosLabel.textColor = UICOLOR_WHITE;
    infosLabel.numberOfLines = 2;
    infosLabel.textAlignment = NSTextAlignmentCenter;
    infosLabel.text = NSLocalizedString(@"WeFoundSomeOfYourFriendsWhoAreAlreadyOnWhyd", nil);
    infosLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    [headerView addSubview:infosLabel];
    
    self.tableView.tableHeaderView = headerView;
    self.tableView.separatorColor =  WDCOLOR_GRAY_BORDER_LIGHT;
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
}


#pragma -mark ACTIONS

- (void)actionNext
{
    //[self.loadingView startAnimating];
    [WDHelper onBoardingEndinView:self WithUIsdToFollow:self.uIdsToFollowed];

    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersFacebook.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //USERS
    static NSString* CellIdentifierUser = @"UserCell";
    UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierUser];
    if (cell == nil)
    {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierUser withType:UserCellTypeGenres];
    }
    cell.delegate = self;
    cell.user = [self.usersFacebook objectAtIndex:indexPath.row];
    return cell;
}


#pragma -mark UserCell Delegate

- (void)userCell:(UserCell *)cell isFollow:(BOOL)isFollow
{
    if (isFollow) {
        [self.uIdsToFollowed addObject:cell.user.id];
    }else
    {
        [self.uIdsToFollowed removeObject:cell.user.id];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING FACEBOOK");
    [super didReceiveMemoryWarning];
}
@end
