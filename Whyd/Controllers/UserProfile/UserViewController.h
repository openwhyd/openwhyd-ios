//
//  UserViewController.h
//  Whyd
//
//  Created by Damien Romito on 10/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TracksListViewController.h"
#import "User.h"

@interface UserViewController : TracksListViewController<UIScrollViewDelegate>

@property (nonatomic, strong) User *user;
@property (nonatomic) NSString* userId;
@property (nonatomic, strong) Playlist *tracksPlaylist;

- (instancetype)initWithUser:(User *)user;
- (instancetype)initWithUser:(User *)user success:(void(^)(User *user))success;
- (void) configureView;
- (void) initPlaylists;

@end
