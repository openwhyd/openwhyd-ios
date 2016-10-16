//
//  AddTrackViewController.h
//  Whyd
//
//  Created by Damien Romito on 12/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTrack.h"
#import "PlaylistSelectViewController.h"

@interface EditTrackViewController : UIViewController<UITextViewDelegate, PlaylistSelectDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL isNew;
@property (nonatomic) NSInteger tag;


- (id)initWithTrack:(WDTrack*)track fromPLaylist:(Playlist *)playlist;

@end

@protocol EditTrackDelegate <NSObject>

@optional
- (void) editTrackWithSuccess:(WDTrack*)track;

@end