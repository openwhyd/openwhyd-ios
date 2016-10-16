//
//  Playlist.h
//  Whyd
//
//  Created by Damien Romito on 06/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Mantle.h"

@class WDTrack;


@interface Playlist :  MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *nbTracks;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSArray *tracks;


@property (nonatomic, strong) NSMutableArray *unAvailableTracks;

@property (nonatomic) NSUInteger unavailableCount;
@property (nonatomic) BOOL unavailable;
//@property (nonatomic) BOOL shuffleMode;

@property (nonatomic) BOOL fromHotTracks;
//@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL allowLoadMore;
@property (nonatomic) BOOL shuffleEnable;
@property (nonatomic) NSInteger currentPIndex; //!\ in shuffle mode, is not the same index than the wdplayermanager current index



+ (instancetype)playlistFromHref:(NSString*)hrefString;
+ (instancetype)playlistFromHref:(NSString*)hrefString success:(void(^)(Playlist *playlist))success;
- (void)reloadPlaylist:(void(^)(Playlist *playlist))success failure:(void(^)(NSError *error))failure;
- (void)reloadPlaylist;
- (void)loadMore;
- (NSString*)urlLink;
- (void)shufflingTracks;
- (NSInteger)indexForStartingAtPIndex:(NSInteger)index;
- (NSInteger)indexNext;
- (NSInteger)indexNextForPreloadPIndex:(NSInteger)index;
- (NSInteger)indexPrev;
- (NSInteger)indexForPIndex:(NSInteger)index;

@end


@protocol PlaylistDelegate <NSObject>
- (void)PlaylistLoadMore:(Playlist *)playlist;
//- (void)PlaylistTrackLoadedWithError:(NSError*)error;
@end

