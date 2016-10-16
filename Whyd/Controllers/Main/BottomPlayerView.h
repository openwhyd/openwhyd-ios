//
//  BottomPlayerView.h
//  Whyd
//
//  Created by Damien Romito on 13/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BottomPlayerState) {

    BottomPlayerStateStop = 0,
	BottomPlayerStateLoading = 1,
	BottomPlayerStatePlay = 2,
    BottomPlayerStatePause = 3,
    
};


@interface BottomPlayerView : UIView
@property (nonatomic) NSString* title;
@property (nonatomic) BottomPlayerState state;

- (void)updateTrack;

@end
