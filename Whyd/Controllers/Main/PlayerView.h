//
//  PlayerView.h
//  Whyd
//
//  Created by Damien Romito on 04/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTrack.h"
#import "WDPlayerManager.h"
#import "WDBackgroundBlurView.h"


@interface PlayerView : UIView <WDPlayerManagerDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) WDBackgroundBlurView *backgroundView;

- (void) show;
- (void)updatePosition:(float)position;
- (void)updateTotalDuration:(float)duration;

@end

@protocol PlayerViewDelegate <NSObject>

@optional
- (void)playerViewDismissedWithCurrentTrack:(WDTrack *)currentTrack;
- (void)playerViewDismissed;
@end


