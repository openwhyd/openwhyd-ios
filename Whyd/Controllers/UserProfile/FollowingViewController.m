//
//  FollowingViewController.m
//  Whyd
//
//  Created by Damien Romito on 14/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "FollowingViewController.h"
#import "WDHelper.h"


@interface FollowingViewController ()
    @property (nonatomic, strong) User *user;
@end

@implementation FollowingViewController

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
    self.urlString = API_USER_FOLLOWING(self.user.id);
    self.title =  [NSLocalizedString(@"FollowingTitle", nil) uppercaseString];
    
    [super loadView];
    


}


- (void)successResponse:(id)responseObject
{
    [super successResponse:responseObject];
    [self generatePlaceholders];

    

}

- (void) generatePlaceholders
{
    if ([self.user.id isEqualToString:[WDHelper manager].currentUser.id]) {
        [self placeholderWithImageName:@"ProfileIconNoFollowing" text:NSLocalizedString(@"FollowingPlaceholderMe", nil)];
    }
    else
    {
        [self placeholderWithImageName:@"ProfileIconNoFollowing" text: NSLocalizedString(@"FollowingPlaceholder", nil) ];
    }
}


@end
