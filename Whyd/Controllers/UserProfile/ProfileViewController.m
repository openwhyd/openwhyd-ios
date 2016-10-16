//
//  ProfileViewController.m
//  Whyd
//
//  Created by Damien Romito on 04/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIViewController+WD.h"
#import "WDHelper.h"

@implementation ProfileViewController

- (instancetype)init
{
    if ([WDHelper manager].currentUser) {
        
        self = [self initWithUser:[WDHelper manager].currentUser];
    }else
    {
        self = [super init];
    }
    
    return self;
}


- (void)loadView
{
    [super loadView];
    [self makeAsMainViewController];
}

- (void) updateUser
{
    self.user = [WDHelper manager].currentUser;
    [self initPlaylists];
    [self configureView];
}



@end
