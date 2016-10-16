//
//  TrackViewController.h
//  Whyd
//
//  Created by Damien Romito on 19/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDTrack.h"
#import "WDPlayerManager.h"
#import "EditTrackViewController.h"
#import "MainViewController.h"
#import "OHAttributedLabel.h"
#import "CommentsViewController.h"


@interface TrackViewController : UIViewController<WDPlayerManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EditTrackDelegate, OHAttributedLabelDelegate, MainViewDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) WDTrack* track;
@property (nonatomic) NSUInteger tag;
@property (nonatomic, strong) Playlist *playlist;


@end
