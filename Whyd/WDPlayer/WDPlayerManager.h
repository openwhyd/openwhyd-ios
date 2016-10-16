//
//  WDPlayerManager.h
//  Whyd
//
//  Created by Damien Romito on 28/01/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerConfig.h"
#import "WDTrack.h"

typedef NS_ENUM(NSUInteger, WDPlayerState) {
    WDPlayerStateStop = 0,
	WDPlayerStatePlay = 1,
    WDPlayerStatePause = 2,
    WDPlayerStateLoading = 3,
    WDPlayerStateNext = 4,
    WDPlayerStatePrev = 5,
};

typedef NS_ENUM(NSUInteger, WDPlayerTransitionSource) {
    WDPlayerTransitionSourceInit = 0,
	WDPlayerTransitionSourceEndMusic = 1,
    WDPlayerTransitionSourceUserInteraction = 2,
    WDPlayerTransitionSourceError = 3,


};


typedef NS_ENUM(NSInteger, WDPlayerError) {
    WDPlayerErrorDefault = 0,
    WDPlayerErrorTimeout = -991,
};

typedef NS_ENUM(NSUInteger, WDPlayerSourceType) {
    WDPlayerSourceTypeNull = 0,
    WDPlayerSourceTypeAudio = 1,
	WDPlayerSourceTypeVideo = 2,
};



static NSString* const WDPlayerStateKey = @"WDPlayerStateKey";
static NSString* const WDPlayerManagerFailedToPlayNotification = @"WDPlayerManagerFailedToPlayNotification";
static NSString* const WDPlayerManagerStartTrack = @"WDPlayerManagerStartTrackNotification";

static NSString* const WDPlayerStateDidChange  = @"WDPlayerStateDidChangeNotification";


@interface WDPlayerManager : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL suffleMode;
@property (nonatomic) WDPlayerState currentState;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, weak) WDTrack *currentTrack;
@property (nonatomic, readonly) NSString *lastTrackId;
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic) WDPlayerSourceType sourceType;
@property (nonatomic) UIView *movieContainer;


+ (instancetype)manager;

//LOAD
- (void)playAtIndex:(NSUInteger)index inPlayList:(Playlist *)playlist;

//ACTIONS
- (void) togglePlayPause;
- (void) play;
- (void) pause;
- (void) stop;
- (void) actionNext;
- (void) actionPrev;
- (void) seekTo:(float)time;
- (void) setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;
- (void) displayMovieInMovieContainer;
- (CGFloat)currentPosition;
@end


@protocol WDPlayerManagerDelegate <NSObject>

@optional
- (void)WDPlayerManagerReadyToPlay;
//- (void) WDPlayerManagerStateChange:(WDPlayerState)state forTrack:(WDTrack*)track;
- (void)WDPlayerManagerUpdatePosition:(float)position;
- (void)WDPlayerManagerUpdateTotalDuration:(float)duration;
- (void)WDPlayerManagerHandleError:(NSError*)error;
@end