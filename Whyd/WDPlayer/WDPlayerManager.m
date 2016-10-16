//
//  WDPlayerManager.m
//  Whyd
//
//  Created by Damien Romito on 28/01/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerManager.h"
#import <CoreMedia/CMTime.h>
#import "UIImageView+WebCache.h"
#import "WDHelper.h"
#import "AVPlayerItem+Additions.h"
#import "WDQueuePlayer.h"
#import "Playlist.h"
#import "NSTimer+Blocks.h"

@import MediaPlayer;
@import AVFoundation;


@interface WDPlayerManager ()
@property (nonatomic, strong) MPNowPlayingInfoCenter *infoCenter;
@property (nonatomic, strong) NSMutableDictionary* songInfo;
@property (nonatomic, strong) NSError *error;
@property (nonatomic) WDPlayerTransitionSource lastTransitionSource;
@property (nonatomic, strong) WDQueuePlayer *player;
@property (nonatomic, strong) WDTrack *oldTrack;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) AVPlayerLayer *videoLayer;
@property (nonatomic, strong) id preloadObserver;
@property (nonatomic) BOOL inInterruption;

@end

@implementation WDPlayerManager

+ (instancetype)manager {
    static WDPlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.currentIndex = -1;
        
        //Background Audio
        NSString *category = AVAudioSessionCategoryPlayback;
        if (category)
        {
            NSError *error = nil;
            BOOL success = [[AVAudioSession sharedInstance] setCategory:category error:&error];
            if (!success)
                DLog(@"Audio Session Category error: %@", error);
        }
        AVAudioSession *aSession = [AVAudioSession sharedInstance];
        [aSession setActive:NO error:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationAudioSessionInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:aSession];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationMediaServicesReset)
                                                     name:AVAudioSessionMediaServicesWereResetNotification
                                                   object:aSession];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackgroundNotification)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:NULL];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(WDPlayerItemInit:)
                                                     name:@"WDPlayerItemInitNotification"
                                                   object:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(WDPlayerItemDealloc:)
                                                     name:@"WDPlayerItemDeallocNotification"
                                                   object:NULL];

        //Observe plug/unplug headphone
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioRouteChangeListenerCallback:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PlayVideoInBackground"];
        
        self.infoCenter = [MPNowPlayingInfoCenter defaultCenter];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ItemDidPlayToEndTimeNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
    }
    return self;
}


- (void)playAtIndex:(NSUInteger)index
{
    
    if (self.currentTrack && self.currentTrack.state != TrackStateUnavailable) {
        self.currentTrack.state = TrackStateStop;
        self.currentTrack.readyToPlay = NO;
        if (self.currentTrack.playerItem) {
            self.currentTrack.playerItem = nil;
        }
    }
    
    if(self.playlist.tracks.count)
    {
        //******************** LOAD TRACK ***************************/
        self.currentIndex = index;
        if (self.currentTrack) {
            self.currentTrack.readyToPlay = NO;
            [self pausePlayer];
            DLog(@"PAUSE TRACK");
            [self.currentTrack streamUrlCancelRequest];
            
            if (self.videoLayer) {
                NSLog(@"self.videoLayer %p",self.videoLayer);

                [self.videoLayer removeFromSuperlayer];
                self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
                
                [self.movieContainer.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *obj, NSUInteger idx, BOOL *stop) {
                    NSLog(@"Layer %lui : %p (%@)",(unsigned long)idx, obj, [obj class]);
                }];
                
            }
            if (self.preloadObserver) {
                [self.player removeTimeObserver:self.preloadObserver];
            }
        }
        
        self.oldTrack = self.currentTrack;
        self.currentTrack = [self.playlist.tracks objectAtIndex:index];
        if ([self.oldTrack.id isEqualToString:self.currentTrack.id]) {
            [self reset];
            return;
        }
        
        
        /******************** IF TRACK SOURCE UNAIVALABLE ***************************/

        if (self.currentTrack.sourceKey == WDSourceUnAvailable) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Data failed decoding as a UTF-8 string", @"AFNetworking", nil),
                                       };
            NSError *error =[NSError errorWithDomain:API_BASE_URL code:ERROR_TRACK_UNAVAILABLE userInfo:userInfo];
            [self handleError:error];
            return;
        }
        
        
        /******************** IF TRACK UNAIVALABLE ***************************/
        if (self.currentTrack.state == TrackStateUnavailable) {
            DLog(@"UNAVAILABLE :%@", self.currentTrack.name);
            
            if (self.playlist.unavailable) {
                NSError *error =[NSError errorWithDomain:API_BASE_URL code:ERROR_PLAYLIST_UNAVAILABLE userInfo:nil];
                [self.delegate WDPlayerManagerHandleError:error];
                [self stop];
            }else
            {
                self.lastTransitionSource = WDPlayerTransitionSourceError;
                if (self.currentState == WDPlayerStateNext)
                {
                    [self next];
                }else if (self.currentState == WDPlayerStatePrev)
                {
                    [self prev];
                }
            }
            
            return;
        }
        
        
        self.currentTrack.index = index;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WDPlayerManagerStartTrack object:nil];
        
        
        /******************** //SET CONTROL CENTER ***************************/
        [self initControlCenter];
        
        //LOAD TRACK
        [self setCurrentState:WDPlayerStateLoading];
        self.currentTrack.state = TrackStateLoading;
        
        
        //CHECK TO LOAD MORE

        
        if (self.playlist.allowLoadMore &&  (self.playlist.tracks.count < 3 || index > self.playlist.tracks.count  - 3)) {
            [self.playlist loadMore];
            [self.playlist reloadPlaylist:^(Playlist *playlist) {
                NSLog(@"PLAYLIST %p manager playlist %p", playlist , self.playlist);
            } failure:^(NSError *error) {
                
            }];
        }
        
        
        //AVOID OVER-NEXT => add delay before to play a track
        if (self.lastTransitionSource == WDPlayerTransitionSourceUserInteraction) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(loadTrack) withObject:nil afterDelay:.4];
        }else
        {
            [self loadTrack];
        }


    }else {
        //EMPTY PLAYLIST
        
        NSError *error =[NSError errorWithDomain:API_BASE_URL code:ERROR_PLAYLIST_EMPTY userInfo:nil];
        [self.delegate WDPlayerManagerHandleError:error];
        [self stop];
        
        return;
    }
    
    return;
    
}


- (void) loadTrack
{

    
    if (self.currentTrack.playerItem && self.player.items.lastObject == self.currentTrack.playerItem) {
        
        [self.player advanceToNextItem];
        [self readyToPlayTrack];
        
    }else
    {
        __weak WDQueuePlayer *player = self.player;
        __weak WDTrack *currentTrack = self.currentTrack;

        [currentTrack prepareTrack:^(AVPlayerItem *playerItem) {
     
            if (self.currentIndex != currentTrack.index || !player ) return ;

            //PREVIEW SKIP
            if (currentTrack.isPreview && self.lastTransitionSource != WDPlayerTransitionSourceUserInteraction)
            {
                [self next];
                return;
            //NORMAL TRACK OR PREVIEW
            }else
            {
                [player removeAllItems];
                [player insertItem:playerItem afterItem:nil];
            }
        } failure:^(NSError *error) {
            [self handleError:error];
            
        }];
    
        
    }
}


#pragma -mark NOTIFICATIONS

- (void) didEnterBackgroundNotification
{
    DLog(@"IN BACKGROUND");
    
    if([self.currentTrack.sourceKey isEqualToString:WDSourceYoutube]){
        [self pause];
        return;
    }
    
    if(self.currentState == WDPlayerStatePlay)
    {
        self.currentState = WDPlayerStatePause;
        
            [self performSelector:@selector(play) withObject:nil afterDelay:.1];
        
    }
    
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self.player.currentItem) {
        
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.player.currentItem.status == AVPlayerStatusFailed)
            {
                
                NSError *error = self.player.currentItem.error;
                NSLog(@"error %@",error);
                
                
               // [self playerItem:self.player.currentItem enableKVO:NO];
                [self handleError:error];
            } else if (self.player.currentItem.status == AVPlayerStatusReadyToPlay )
            {

                NSString *url = [[((AVURLAsset *)((AVPlayerItem *)object).asset) URL] absoluteString];
                if ([url isEqualToString: self.currentTrack.streamUrl]) {
                    
                    [self readyToPlayTrack];
                }

            }
 
            
        }
        /******************** PREVENT PAUSE TRACK *****************/
        
        else if ( [keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            if (!self.player.currentItem.playbackBufferEmpty && self.currentState == WDPlayerStatePlay)
            {
                [self.player play];
            }
        }else if ( [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
        {
            if (self.currentState == WDPlayerStatePlay && self.currentTrack.playerItem == self.player.currentItem)
            {
                [self.player play];
            }
            
            if (self.player.currentItem.playbackLikelyToKeepUp)
            {
                [self updateControlCenterTime];
                
            }
            
            
        }else if ( [keyPath isEqualToString:@"playbackBufferFull"])
        {
            // NSLog(@"BUFFFER FULL: %i", self.player.currentItem.playbackBufferFull);
            
            if (self.player.currentItem.playbackBufferFull)
            {
                if (self.currentState == WDPlayerStatePlay)
                {
                    [self.player play];
                }
            }
        }
    }
    
    
}

-(void)readyToPlayTrack
{
    
    if (!self.currentTrack.readyToPlay)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;

    self.currentTrack.totalDutation =  CMTimeGetSeconds(self.player.currentItem.asset.duration);

    

    //IF HAS VIDEO
    if (self.currentTrack.type == TrackTypeVideo) {
        self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.videoLayer.backgroundColor = UICOLOR_BLACK.CGColor;
        [self displayMovieInMovieContainer];
        
    }else if(self.videoLayer)
    {
        self.videoLayer.backgroundColor = UICOLOR_CLEAR.CGColor;
        
    }
    [self.player play];

    
    
    if (!self.timeObserver) {
        
        self.timeObserver = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            CGFloat currentTime;
    
            currentTime = CMTimeGetSeconds(weakSelf.player.currentTime);
            
            [weakSelf.delegate WDPlayerManagerUpdatePosition:currentTime];

        } repeats:YES];
        
    }
    
        
    self.currentTrack.readyToPlay = NO;
    
    if (self.currentTrack.id) {
        //TRACK PLAY LOG
        [[WDClient client] GET:API_PLAY_COUNT_INCR(self.currentTrack.id) parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        }];
    }
    

    [self updateControlCenterTime];

    self.currentState = WDPlayerStatePlay;
    self.currentTrack.state = TrackStatePlay;
    
   [self preloadTrackAtPIndex:self.playlist.currentPIndex + 1];
   
    
    
    
}


- (void)preloadTrackAtPIndex:(NSInteger)index
{
    /******************** PRELOAD NEXT TRACK *****************/
    if(self.playlist.tracks.count == 1 ) return;
    
    //SELECT NEXT TRACK
    NSInteger newIndex = [self.playlist indexNextForPreloadPIndex:index];

    
    WDTrack *nextTrack = [self.playlist.tracks objectAtIndex:newIndex];
    


    //LOAD NEXT TRACK URL
    __weak WDQueuePlayer *player = self.player;

    
    [nextTrack prepareTrack:^(AVPlayerItem *playerItem) {
        if (self.currentTrack.isPreview ) return; //NOT PRELOAD PREVIEWS CAUSE THEY ARE SKIPPED
        if (playerItem) {
            [player insertItem:playerItem afterItem:player.items.lastObject];
        }
        DLog(@"Preload %@", playerItem);
    } failure:^(NSError *error) {
        [self markAsUnavailable:nextTrack];
        // if (self.playlist.tracks.count > index) {
        [self preloadTrackAtPIndex:index+1];
        //}
    }];


    
}


- (void)handleError:(NSError *)error
{
    [self.delegate WDPlayerManagerHandleError:error];
    
    
    //IF HAS NETWORK
    if (error.code != ERROR_INTERNET_NO && error.code !=  ERROR_INTERNET_LOST) {
        [self markAsUnavailable:self.currentTrack];
        //THROW ERROR
        [[NSNotificationCenter defaultCenter] postNotificationName:WDPlayerManagerFailedToPlayNotification object:error.localizedDescription];
        self.lastTransitionSource = WDPlayerTransitionSourceError;
        
        if (error.code == ERROR_AVMEDIA_SERVISES_RESET) {
            [self initPlayer];
            
        }
        
        [self next];
        
    }else
    {
        [self stop];
    }
}

- (void)markAsUnavailable:(WDTrack*)track
{
    //MARK AS UNAVAILABLE
    dispatch_async(dispatch_get_main_queue(), ^ {
        self.playlist.unavailableCount ++;
        track.state = TrackStateUnavailable;
        DLog(@"UAVAILABLE !!!!! => %@", track.name);
    });
    
}




- (void)ItemDidPlayToEndTimeNotification
{
    self.lastTransitionSource = WDPlayerTransitionSourceEndMusic;
    [self next];
}


- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            DLog(@"Headphone/Line plugged in");
            if (self.player && self.currentState == WDPlayerStatePlay) {
                [self play];
            }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            DLog(@"Headphone/Line was pulled. Stopping player....");
            if (self.player ) {
                [self pause];
            }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            DLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}



#pragma -mark ACTIONS



- (void)playAtIndex:(NSUInteger)index inPlayList:(Playlist *)playlist
{
    
    [WDHelper playTrackForRatePopup];
    
    
    
    
    if(self.playlist != playlist || ![playlist.name isEqualToString: self.playlist.name] /*|| [self.playlist.tracks objectAtIndex:index] != self.currentTrack*/)
    {

        NSLog(@"CURRENT PLAYLIST %p", self.playlist);
        
        self.playlist = playlist;
        NSLog(@"NEW PLAYLIST %p", playlist);
        [self initPlayer];
        
        [self.player removeAllItems];
        self.currentIndex = -1;
        
    }
    self.lastTransitionSource = WDPlayerTransitionSourceUserInteraction;
    
    //Get Playlist INDEX IN CASE OF SHUFFLING
    [self playAtIndex:[self.playlist indexForStartingAtPIndex:index]];

    
}

- (void)initPlayer
{
    if (self.timeObserver) {
        [self.timeObserver invalidate];
        self.timeObserver = nil;
    }
    
    if (self.player) {
        [self pausePlayer];
    
        //REMOVE PRELOADED ITEMS IN PLAYER
        [self.player removeAllItems];
        self.player = nil;
    }
    
   
    self.player = [[WDQueuePlayer alloc] init];
    [self.player setAllowsExternalPlayback:YES];
    [self.player setUsesExternalPlaybackWhileExternalScreenIsActive:YES];
}



- (void) reset
{

    [self.player seekToTime:CMTimeMake(0, 1)];
    self.currentTrack.state = TrackStatePlay;

}



- (void)actionNext
{
    self.lastTransitionSource = WDPlayerTransitionSourceUserInteraction;
    [self next];
}

- (void)actionPrev
{
    self.lastTransitionSource = WDPlayerTransitionSourceUserInteraction;
    [self prev];
}

- (void)togglePlayPause
{
    if (self.currentState == WDPlayerStatePause) {
        [self play];
    }else if (self.currentState == WDPlayerStatePlay)
    {
        [self pause];
    }
}

- (void)pause
{
    
    if(self.currentState!=WDPlayerStatePause)
    {
        [self pausePlayer];
        self.currentState = WDPlayerStatePause;
        self.currentTrack.state = TrackStatePause;
    }
}

- (void)pausePlayer
{

    [self.player pause];
        
    
}

- (CGFloat)currentTimePlayer
{

    return CMTimeGetSeconds(self.player.currentTime);
    
}

- (void) play
{
    
    if(self.currentState!=WDPlayerStatePlay && !self.inInterruption)
    {
        

        [self.player play];

        
        //        [self.songInfo setValue:[NSNumber numberWithFloat:self.player.currentTrackTime ] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        //        self.infoCenter.nowPlayingInfo = self.songInfo;
        self.currentState = WDPlayerStatePlay;
        self.currentTrack.state = TrackStatePlay;
    }
}

- (void) stop
{
    
    DLog(@"STOPPPPP CLOSE PLAYER?");
    [self pausePlayer];
    self.currentState = WDPlayerStateStop;
    self.currentTrack.state = TrackStateStop;
    self.currentTrack = nil;
    
}

- (void) next
{
    
    self.currentState = WDPlayerStateNext;
    NSInteger newIndex = [self.playlist indexNext];
    [self playAtIndex:newIndex];

    
}

-(void) prev
{
    
    self.currentState = WDPlayerStatePrev;
    NSInteger newIndex = [self.playlist indexPrev];
    [self playAtIndex:newIndex];
    
    
}


- (void) seekTo:(float)time{
    CMTime newTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    self.currentState = WDPlayerStateLoading;
    self.currentTrack.state = TrackStateLoading;
    


    [self.player seekToTime:newTime completionHandler:^(BOOL finished) {
        self.currentState = WDPlayerStatePlay;
        self.currentTrack.state = TrackStatePlay;
        [self.player play];
    }];
    [self pausePlayer];
    
    

    
}

- (void) setFullscreen:(BOOL)fullscreen animated:(BOOL)animated
{
    //    if ([self.currentPlayer isKindOfClass:[WDPlayerVideo class]]) {
    //        [((WDPlayerVideo*)self.currentPlayer) setFullscreen:fullscreen animated:animated];
    //    }
}

- (CGFloat)currentPosition
{
    if (self.player) {
        return [self currentTimePlayer];
    }else
    {
        return 0;
    }
}
//
//- (void)setCurrentIndex:(NSInteger)currentIndex
//{
//    _currentIndex = currentIndex;
//    self.playlist.currentIndex = currentIndex;
//}

- (void)setCurrentState:(WDPlayerState)currentState
{
    _currentState = currentState;
    [[NSNotificationCenter defaultCenter] postNotificationName:WDPlayerStateDidChange object:nil];
}

#pragma -mark NOTIFICATIONS

- (void) WDPlayerItemInit:(NSNotification*)notification
{
    
    AVPlayerItem *item = [notification object];
    [item addObserver:self forKeyPath:@"status" options:0 context:nil];
    [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];

}

- (void) WDPlayerItemDealloc:(NSNotification*)notification
{
    
    AVPlayerItem *item = [notification object];
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];

    
}
- (void)notificationMediaServicesReset {
    
    DLog(@"notificationMediaServicesReset");
    // • No userInfo dictionary for this notification
    // • Audio streaming objects are invalidated (zombies)
    // • Handle this notification by fully reconfiguring audio
}

- (void)notificationAudioSessionInterruption:(NSNotification*)notification {
    
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            
            if (self.currentState == WDPlayerStatePlay) {
                [self pausePlayer];
                self.currentState = WDPlayerStatePlay;
                self.inInterruption = YES;
            }
            DLog(@"AVAudioSessionInterruptionTypeBegan");
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            DLog(@"AVAudioSessionInterruptionTypeEnded");
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                // Here you should continue playback.
                if (self.currentState == WDPlayerStatePlay) {
                    self.currentState = WDPlayerStatePause;
                    self.inInterruption = NO;
                    [self play];
                    
                }
            }
        } break;
        default:
            break;
    }
}



- (void)displayMovieInMovieContainer
{
         NSLog(@"CURRENT STATE => %lu",self.currentState);
    //&& self.currentState == WDPlayerStateLoading
    if (self.movieContainer && self.videoLayer ) {
        [self.videoLayer setFrame:self.movieContainer.bounds];
        
        [self.movieContainer.layer addSublayer:self.videoLayer];

 
        NSLog(@"self.videoLayer %p",self.videoLayer);

        [self.movieContainer.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"Layer %lui : %p (%@)",(unsigned long)idx, obj, [obj class]);
        }];
        
    }
}

- (void) initControlCenter
{
    
    if (!self.songInfo) {
        self.songInfo = [NSMutableDictionary dictionary];
    }
    [self.songInfo setValue:self.currentTrack.name forKey:MPMediaItemPropertyTitle];
    [self.songInfo setValue:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"ControlCenterVia", nil), self.currentTrack.user.name ] forKey:MPMediaItemPropertyAlbumTitle];
    self.infoCenter.nowPlayingInfo = self.songInfo;
    
    [self.songInfo setValue:nil forKey:MPMediaItemPropertyPlaybackDuration];
    [self.songInfo setValue:nil forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    [self.songInfo setValue:nil forKey:MPMediaItemPropertyArtwork];
    [self updateControlCenterImage];
    
    
}

- (void)updateControlCenterImage
{
    __weak NSMutableDictionary *songInfo = self.songInfo;
    __weak WDTrack *currentTrack = self.currentTrack;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (currentTrack && currentTrack.imageUrl) {
            UIImage *artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentTrack.imageUrl]]];
            if(artworkImage)
            {
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: artworkImage];
                [songInfo setValue:albumArt forKey:MPMediaItemPropertyArtwork];
            }
        }
        self.infoCenter.nowPlayingInfo = songInfo;
    });
}

- (void)updateControlCenterTime
{
    [self.delegate WDPlayerManagerUpdateTotalDuration:self.currentTrack.totalDutation];
    
    [self.songInfo setValue:[NSNumber numberWithFloat:self.currentTrack.totalDutation ] forKey:MPMediaItemPropertyPlaybackDuration];
    [self.songInfo setValue:[NSNumber numberWithFloat:1.0f ] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [self.songInfo setValue:[NSNumber numberWithFloat:[self currentTimePlayer] ] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    @try {
        self.infoCenter.nowPlayingInfo = self.songInfo;
    }
    @catch (NSException *exception) {
    }

}





@end
