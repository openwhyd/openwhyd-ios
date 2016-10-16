//
//  SearchTableViewController.h
//  Whyd
//
//  Created by Damien Romito on 22/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDRootTableViewController.h"
#import "PlaylistSearchCell.h"
#import "UserCell.h"
#import "TrackSearchCell.h"


@interface SearchTableViewController : WDRootTableViewController<TrackSearchCellDelegate>

@property (nonatomic) SearchType searchType;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *resultsArray;
@property (nonatomic, strong) Playlist *playlist;

- (void)actionDismiss;

@end

@protocol SearchViewDelegate <NSObject>

- (void) searchViewDismissed;

@end