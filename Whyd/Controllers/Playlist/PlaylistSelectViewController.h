//
//  PlaylistSelectViewController.h
//  Whyd
//
//  Created by Damien Romito on 24/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "PlaylistCreateViewController.h"
#import "WDRootTableViewController.h"
#import "SWTableViewCell.h"

@interface PlaylistSelectViewController : WDRootTableViewController<PlaylistCreateDelegate, SWTableViewCellDelegate>
@property (nonatomic, weak) Playlist *selectedPlaylist;
@property (nonatomic, weak) id delegate;
@end

@protocol PlaylistSelectDelegate <NSObject>

- (void)PlaylistSelect:(Playlist*)playlist;

@end
