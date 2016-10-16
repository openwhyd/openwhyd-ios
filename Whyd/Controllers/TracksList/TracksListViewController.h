//
//  TracksListViewController.h
//  Whyd
//
//  Created by Damien Romito on 19/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TrackCell.h"
#import "WDRootTableViewController.h"
#import "MainViewController.h"



@interface TracksListViewController : WDRootTableViewController

@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic) BOOL hasPlayAllButton;

- (void) actionPlayAll;

@end

