//
//  PlaylistViewController.h
//  Whyd
//
//  Created by Damien Romito on 01/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TracksListViewController.h"

@interface PlaylistViewController : TracksListViewController

- (instancetype)initWithPlaylist:(Playlist *)playlist;
- (instancetype)initWithPlaylist:(Playlist *)playlist playingTrack:(WDTrack*)currentTrack;

@end
