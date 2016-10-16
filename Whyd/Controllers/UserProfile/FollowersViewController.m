//
//  FollowersViewController.m
//  Whyd
//
//  Created by Damien Romito on 14/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "FollowersViewController.h"
#import "WDHelper.h"

@interface FollowersViewController ()
@property (nonatomic, strong) User *user;
@end

@implementation FollowersViewController

- (instancetype)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}

- (void)loadView
{
    self.urlString = API_USER_FOLLOWERS(self.user.id);
    self.title = [NSLocalizedString(@"FollowersTitle", nil) uppercaseString];
    
    [super loadView];

}


- (void)successResponse:(id)responseObject
{
    [super successResponse:responseObject];
    
    
    if ([self.user.id isEqualToString:[WDHelper manager].currentUser.id]) {
        [self placeholderWithImageName:@"ProfileIconNoFollowers" text: NSLocalizedString(@"FollowersPlaceholder", nil) ];
    }
    else
    {
        [self placeholderWithImageName:@"ProfileIconNoFollowers" text: NSLocalizedString(@"FollowersPlaceholder", nil) ];
    }
}
@end
