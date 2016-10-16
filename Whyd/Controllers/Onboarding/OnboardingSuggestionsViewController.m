//
//  OnboardingSuggestionsViewController.m
//  Whyd
//
//  Created by Damien Romito on 02/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "OnboardingSuggestionsViewController.h"
#import "UserCell.h"
#import "OnboardingFacebookViewController.h"
#import "WDHelper.h"
#import "WDActivityIndicatorView.h"

@interface OnboardingSuggestionsViewController ()<UserCellDelegate>
@property (nonatomic, strong) NSArray *usersSuggested;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;

@end

@implementation OnboardingSuggestionsViewController

- (id)initWithSuggestedUsers:(NSArray *)suggestedUsers
{
    self = [super init];
    if (self) {
        _usersSuggested = suggestedUsers;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];

    self.title = [NSLocalizedString(@"Suggestions", nil) uppercaseString];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionNext)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    //HEADER
    UIImageView *headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OnboardingSuggestionCoverPhoto.jpg"]];
    
    UILabel *hoorayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 15)];
    hoorayLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5];
    hoorayLabel.text = [NSLocalizedString(@"Hooray", nil) uppercaseString];
    hoorayLabel.textColor = UICOLOR_WHITE;
    hoorayLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:hoorayLabel];
    
    UILabel *infosLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 85, self.view.frame.size.width - 60, 45)];
    infosLabel.textColor = UICOLOR_WHITE;
    infosLabel.numberOfLines = 2;
    infosLabel.textAlignment = NSTextAlignmentCenter;
    infosLabel.text = NSLocalizedString(@"WeFoundSomePeopleWithTheSameTasteAsYou", nil);
    infosLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    [headerView addSubview:infosLabel];
    
    self.tableView.tableHeaderView = headerView;
    self.tableView.separatorColor =  WDCOLOR_GRAY_BORDER_LIGHT;
    self.tableView.separatorInset = UIEdgeInsetsZero;

    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
    [self.view addSubview:self.loadingView];
    

}


#pragma -mark ACTIONS

- (void)actionNext
{

    if ([WDHelper manager].currentUser.fbTok) {
        
        [self.loadingView startAnimating];
        
        NSDictionary *parameters = @{@"ajax" : @"fbFriends",
                                     @"fbTok" : [WDHelper manager].currentUser.fbTok };
        
        [[WDClient client] POST:API_ONBOARDING parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.loadingView stopAnimating];
            
            NSMutableArray *fbFriends = [NSMutableArray new];
            for (NSDictionary *u in responseObject) {
                User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:u error:nil];
                [fbFriends addObject:user];
            }
            
            if (fbFriends.count) {
                OnboardingFacebookViewController *vc = [[OnboardingFacebookViewController alloc] initWithFacebookUsers:fbFriends andUIdToFollowed:self.uIdsToFollowed];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self onboardingOver];
            }

            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"ERROR %@", error);
            
            [self.loadingView stopAnimating];
        }];

    }else
    {
        
        [self onboardingOver];

    }

}

- (void)onboardingOver
{
    
    [WDHelper onBoardingEndinView:self WithUIsdToFollow:self.uIdsToFollowed];
    

}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersSuggested.count;
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
    cell.user = [self.usersSuggested objectAtIndex:indexPath.row];
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
    
    NSLog(@"self.uIdsToFollowed  %@",self.uIdsToFollowed );
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING ONBOARDING SUGGESTION");
    [super didReceiveMemoryWarning];
}
@end
