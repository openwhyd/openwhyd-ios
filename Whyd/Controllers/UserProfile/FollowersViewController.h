//
//  FollowersViewController.h
//  Whyd
//
//  Created by Damien Romito on 14/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "UsersViewController.h"
#import "User.h"

@interface FollowersViewController : UsersViewController

- (instancetype)initWithUser:(User *)user;

@end
