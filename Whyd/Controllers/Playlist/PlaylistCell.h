//
//  PlaylistCell.h
//  Whyd
//
//  Created by Damien Romito on 24/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "SWTableViewCell.h"

@interface PlaylistCell : SWTableViewCell
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic) BOOL isSelected;

@end
