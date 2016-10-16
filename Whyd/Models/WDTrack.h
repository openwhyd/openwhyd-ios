//
//  WDTrack.h
//  Whyd
//
//  Created by Damien Romito on 29/01/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//


#import "Mantle.h"
#import "User.h"
#import "Comment.h"
#import "Playlist.h"


@import AVFoundation;

typedef NS_ENUM(NSUInteger, TrackState) {
    TrackStateStop = 0,
    TrackStatePause = 1,
	TrackStatePlay = 2,
    TrackStateUnavailable= 3,
    TrackStateLoading = 4,
};

typedef NS_ENUM(NSUInteger, TrackType) {
    TrackTypeAudio = 0,
	TrackTypeVideo = 1,
};

static NSString* const WDSourceUnAvailable = @"unavailable";


@interface WDTrack : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* sourceKey;
@property (nonatomic, strong) NSString* eId;
@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* img;

@property (nonatomic, strong) NSString* imageUrl;

@property (nonatomic, strong) NSString* trackId;
@property (nonatomic, strong) NSString* streamUrl;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong, readonly) NSString* date;
@property (nonatomic) Playlist *playlist;

@property (nonatomic) float totalDutation;
@property (nonatomic, strong) UIView* mediaContainer;

@property (nonatomic, readonly) NSUInteger likesCount;
@property (nonatomic) BOOL isLiked;

@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) WDTrack *repost;
@property (nonatomic, strong) NSArray *reposts;
@property (nonatomic) NSUInteger repostsCount;
@property (nonatomic) NSUInteger doublonCount;


@property (nonatomic) NSUInteger updatedAvailableImageUrl;
@property (nonatomic) BOOL fromHotTracks;
@property (nonatomic) NSInteger topNumber;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL isParsed;
@property (nonatomic) NSInteger type;
@property (nonatomic) BOOL readyToPlay;
@property (nonatomic) BOOL isPreview;

@property (nonatomic, strong) AVPlayerItem* playerItem;

//MULTI SOURCE
@property (nonatomic, strong) NSDictionary *alt;
@property (nonatomic) BOOL multiSourced;

@property (nonatomic) TrackState state;

//- (void)availableSources:(SourceType)sourceType success:(void(^)())success failure:(void(^)())failure;
- (void)prepareTrack:(void(^)(AVPlayerItem *playerItem))success failure:(void(^)(NSError *error))failure;
- (void)playerItem:(void(^)(AVPlayerItem *playerItem))success failure:(void(^)(NSError *error))failure;
- (void)streamUrlCancelRequest;
- (BOOL)parseSource;
- (NSString*) url;

@end
