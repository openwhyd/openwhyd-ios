//
//  Playlist.m
//  Whyd
//
//  Created by Damien Romito on 06/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Playlist.h"
#import "WDClient.h"
#import "NSMutableArray+Shuffling.h"
#import "WDTrack.h"
#import "User.h"
#import "MainViewController.h"


static NSString * const PARAMETER_AFTER = @"after";
static NSString * const PARAMETER_SKIP_ = @"skip";
static NSString * const NB_ITEMS_LIMIT = @"20";

@interface Playlist()
@property (nonatomic, readonly) NSString *tempTitle;
@property (nonatomic, readonly) NSString *tempUNm;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic, strong) NSArray *tracksShuffled;


@end
@implementation Playlist



- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentPIndex = -1;
        self.shuffleEnable = YES;
        self.parameters = [NSMutableDictionary dictionaryWithObject:NB_ITEMS_LIMIT forKey:@"limit"];
    }
    return self;
}

+ (instancetype)playlistFromHref:(NSString*)hrefString
{
    Playlist *playlist = [[Playlist alloc] init];
    NSInteger playlistIdLocation =  [hrefString rangeOfString:@"playlist"].location;
    playlist.id = [hrefString substringFromIndex:playlistIdLocation + 9 ];
    playlist.userId = [[hrefString substringFromIndex:3] substringToIndex:playlistIdLocation - 4];

    return playlist;
}

+ (instancetype)playlistFromHref:(NSString*)hrefString success:(void(^)(Playlist *playlist))success
{
    Playlist *playlist = [Playlist playlistFromHref:hrefString];
    [playlist reloadPlaylist:^(Playlist *p) {
        WDTrack *firstTrack = playlist.tracks.firstObject;
        playlist.userName = firstTrack.user.name;
        playlist.name = firstTrack.playlist.name;
        dispatch_async(dispatch_get_main_queue(), ^{
            success(p);
        });
    } failure:^(NSError *error) {
        
    }];
    
    return playlist;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"id",
             @"name": @"name",
             @"tempUNm": @"uNm",
             @"url": @"url",
             @"nbTracks": @"nbTracks",
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    self = [super initWithDictionary:dictionaryValue error:error];

    
    if ([dictionaryValue objectForKey:@"url"] && ![[dictionaryValue objectForKey:@"url"] isEqualToString:@""] ) {
        _url = [NSString stringWithFormat:@"%@?format=json", [dictionaryValue objectForKey:@"url"] ];
    }
    self.id = [NSString stringWithFormat:@"%@", [dictionaryValue valueForKey:@"id"]];

    return self;
}

- (NSString*)urlLink
{
    return [NSString stringWithFormat:@"%@/u/%@/playlist/%@", API_BASE_URL,self.userId, self.id];
}

- (NSString *)url
{
    if (_url) {
        
        return _url;
    }
    else
    {
        return API_PLAYLIST(self.userId, self.id);
    }
}

- (NSString *)imageUrl
{
    NSString * playlistId;
    if (self.id.length > 4)
    {
        playlistId = self.id;
    }else
    {
        playlistId = [NSString stringWithFormat:@"%@_%@", self.userId, self.id];
    }

    return [NSString stringWithFormat:@"%@/img/playlist/%@?localOnly=true", API_BASE_URL, playlistId];
}

- (void)loadMore
{
    if (!self.isLoadingMore) {
        self.isLoadingMore = YES;
        WDTrack *lastTrack = self.tracks.lastObject;
        if (!self.fromHotTracks) {
            [self.parameters setValue:lastTrack.id forKey:PARAMETER_AFTER];
        }else
        {
            [self.parameters setValue:@(self.tracks.count) forKey:PARAMETER_SKIP_];
            
        }
    }

}



#pragma - mark SETTER

- (void)setTempUNm:(NSString *)tempUNm
{
    _name = tempUNm;
}

- (void)setUnavailableCount:(NSUInteger)unavailableCount
{
    _unavailableCount = unavailableCount;
    
    if (self.tracks.count == unavailableCount) {
        self.unavailable = YES;
    }
}

- (void)reloadPlaylist
{
    [self reloadPlaylist:nil failure:nil];
}

- (void)reloadPlaylist:(void(^)(Playlist *playlist))success failure:(void(^)(NSError *error))failure
{
    __weak Playlist *wSelf = self;

    [[WDClient client] GET:self.url parameters:self.parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        


        if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject objectForKey:@"error"]) {
            
            DLog(@"===> %@@", [responseObject objectForKey:@"errorCode"]);
            
            if([[responseObject objectForKey:@"errorCode"] isEqualToString:@"REQ_LOGIN"]){
                 [[MainViewController manager] actionLogout];
            }
//            NSString * response = [responseObject objectForKey:@"error"];
//            NSError * error = [NSError errorWithDomain:response code:0 userInfo:nil];
//            [WDClient handleError:error];
        }else
        {
            if (wSelf.fromHotTracks) {
                responseObject = [responseObject valueForKey:@"tracks"];
            }
            bool isNotLoadingMore = (![wSelf.parameters valueForKey:PARAMETER_AFTER] && ![wSelf.parameters valueForKey:PARAMETER_SKIP_]);
            
            
            NSMutableArray *tracks = [[NSMutableArray alloc] init];
            
            //NSString *oldTrackName = @"";
            for (int i = 0 ; i < [responseObject count] ; i++) {
                NSDictionary *t = [responseObject objectAtIndex:i];
                
                
//                //SAME DATA
//                if (i==0 &&  [responseObject count] == self.tracks.count && [[t objectForKey:@"name"] isEqualToString:((WDTrack *)self.tracks.firstObject).name]&&
//                    [self.tracks containsObject:[WDPlayerManager manager].currentTrack] ) {
//                    tracks = [[NSMutableArray alloc] initWithArray:self.tracks];
//                    break;
//                }

                
                WDTrack *track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:t error:nil];
                
                if(track)
                {
                    if(wSelf.fromHotTracks && isNotLoadingMore)
                    {
                        track.fromHotTracks = YES;
                        if (i<3) {
                            track.topNumber = i+1;
                        }
                    }
                   // track.playlist = self;
                    [tracks addObject:track];
                }
            }
            
          
            BOOL loadMoreEnable = NO;
            
            //CREATION
            if (isNotLoadingMore) {
                if (tracks.count >= [NB_ITEMS_LIMIT intValue]) {
                    loadMoreEnable = YES;
                }
                wSelf.tracks =  tracks;
            }
            //LOAD MORE
            else
            {
                NSMutableArray *mArray= [NSMutableArray arrayWithArray:self.tracks];
                [mArray addObjectsFromArray:tracks];
                
                //UPDATE CURRENT PLAYLIST
//                
//                if([WDPlayerManager manager].playlist == self.playlist)
//                {
//                    [WDPlayerManager manager].playlist.tracks = mArray;
//                }
//
                wSelf.tracks = [mArray mutableCopy];
                
                //STOP LOAD MORE / END OF FEED
                if (tracks.count >= [NB_ITEMS_LIMIT intValue]) {
                    loadMoreEnable = YES;
                }
                
            }
            
            if (!wSelf.fromHotTracks) {
                [wSelf.parameters removeObjectForKey:PARAMETER_AFTER];
            }else
            {
                [wSelf.parameters removeObjectForKey:PARAMETER_SKIP_];
            }
            
            wSelf.allowLoadMore = loadMoreEnable;
            wSelf.isLoadingMore = NO;
  
            if(success) success(wSelf);
//            if (loadMoreEnable && [self.delegate respondsToSelector:@selector(PlaylistLoadMore:)]) {
//                [self.delegate PlaylistLoadMore:wSelf];
//            }
//            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(failure) failure(error);

    }];
}

//- (void)setShuffleMode:(BOOL)shuffleMode
//{
//    if (shuffleMode) {
//        _shuffleMode = YES;
//       
//        [self shufflingTracks];
////        [self.tracksShuffled enumerateObjectsUsingBlock:^(WDTrack *t, NSUInteger idx, BOOL *stop) {
////            NSLog(@"- %@", t.name);
////        }];
//    }
//    else
//    {
//        _shuffleMode = NO;
//        self.tracksShuffled = nil;
//    }
//}

- (void)setTracks:(NSArray *)tracks
{
    _tracks = tracks;
    //self.currentPIndex = -1; //remove for laod more

}

- (void)shufflingTracks
{
    
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.tracks];
    WDTrack *t = [self.tracks objectAtIndex:self.currentPIndex];

    [mArray shuffle];
    if (self.currentPIndex >=0)
    {
        [mArray removeObject:t];
        [mArray insertObject:t atIndex:0];
    }
    
    self.tracksShuffled = mArray;
     self.currentPIndex = 0;
        [self.tracksShuffled enumerateObjectsUsingBlock:^(WDTrack *t, NSUInteger idx, BOOL *stop) {
            NSLog(@"- %@", t.name);
        }];
}


#pragma - mark PLAY







- (NSInteger)indexNext
{
    NSLog(@"self.currentPIndex %ld",(long)self.currentPIndex);
    self.currentPIndex ++;
    
    if(self.currentPIndex >= self.tracks.count )
    {
        self.currentPIndex=0;
    }
    
    return [self indexForPIndex:self.currentPIndex];
}


- (NSInteger)indexPrev
{
    self.currentPIndex --;
    
    if( self.currentPIndex < 0)
    {
        self.currentPIndex = self.tracks.count - 1;
    }
    return [self indexForPIndex:self.currentPIndex];
}



- (NSInteger)indexForStartingAtPIndex:(NSInteger)index
{
    self.currentPIndex = index;
    if (self.shuffleEnable && IS_SHUFFLING && !self.tracksShuffled) {
        [self shufflingTracks];
    }
    
    return [self indexForPIndex:self.currentPIndex];
    
}

- (NSInteger)indexNextForPreloadPIndex:(NSInteger)index
{
    
    if(index >= self.tracks.count )
    {
        index = 0;
    }
    
    return [self indexForPIndex:index];
}

//PRIVATE METHODE
- (NSInteger)indexForPIndex:(NSInteger)index
{
    if (self.shuffleEnable && IS_SHUFFLING)
    {
        WDTrack *t = [self.tracksShuffled objectAtIndex:index];
        NSInteger newIndex = [self.tracks indexOfObject:t];
        //If Datas of playlist reloaded
        if (newIndex == NSNotFound) {
            return [self indexForStartingAtPIndex:0];
        }else
        {
            return  [self.tracks indexOfObject:t];
        }
    }else
    {
        return index;
    }
}


@end
