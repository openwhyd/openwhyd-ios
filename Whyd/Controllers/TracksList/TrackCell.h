//
//  TrackCell.h
//  Whyd
//
//  Created by Damien Romito on 13/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDTrack.h"




static NSString * const TRACKSLIST_WILL_BEGIN_DRAGGING = @"TracksListWillBeginDragging";
static NSString * const TRACKSLIST_DID_END_DECELERATING = @"TracksListDidEndDecelerating";


@interface TrackCell : UITableViewCell

@property (nonatomic, strong) WDTrack* track;
@property (nonatomic, weak) id delegate;


@end

@protocol TrackCellDelegate <NSObject>

- (void)trackCell:(TrackCell *)cell openUser:(User *)user;
- (void)trackCell:(TrackCell *)cell repost:(WDTrack *)track;
- (void)trackCell:(TrackCell *)cell openPlaylist:(Playlist *)playlist;
- (void)trackCellOpenDetail:(TrackCell*)cell;
- (void)trackCellPlay:(TrackCell *)cell;
- (void)trackCell:(TrackCell *)cell editTrack:(WDTrack *)track;
- (void)trackCellPlayUnaivailable;
- (void)trackCell:(TrackCell *)cell shareTrack:(WDTrack *)track;


@end