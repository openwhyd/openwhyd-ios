//
//  WDTrack.m
//  Whyd
//
//  Created by Damien Romito on 29/01/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTrack.h"
#import "WDPlayerConfig.h"
#import "WDHelper.h"
#import "NSAttributedString+Attributes.h"
#import "OHAttributedLabel.h"
#import "WDPlayerUrl.h"
#import "Playlist.h"
#import "Comment.h"
#import "WDClient.h"
#import "Openwhyd-Swift.h"
//#import "WDPlayerItem.h"
#import "NSString+Matcher.h"

@interface WDTrack()
@property (nonatomic, readonly) NSString* id2;
@property (nonatomic, readonly) NSString* pId;
@property (nonatomic, readonly) NSString* userId;
@property (nonatomic, readonly) NSString* userName;
@property (nonatomic, readwrite) NSUInteger likesCount;
@property (nonatomic) NSArray* likes;
@property (nonatomic, strong) WDPlayerUrl *playerUrl;

@end

@implementation WDTrack

- (id)init
{
    self = [super init];
    if (self) {
        _name = @"";
        _text = @"";
        _imageUrl = @"";
        
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"id": @"id",
             @"id2": @"_id",
             @"pId": @"pId",
             @"name": @"name",
             @"img": @"img",
             @"eId": @"eId",
             @"userId": @"uId",
             @"userName": @"uNm",
             @"likes": @"lov",
             @"playlist": @"pl",
             @"text": @"text",
             @"comments": @"comments",
             @"repost": @"repost",
             @"reposts": @"reposts",
             @"repostsCount": @"nbR",
             @"likesCount": @"nbL",
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    
    self = [super initWithDictionary:dictionaryValue error:error];
    
    //user
    User *user = [User new];
    user.id = [dictionaryValue valueForKey:@"userId"];
    if ([dictionaryValue valueForKey:@"userName"] != (id)[NSNull null])
    {
        user.name = [dictionaryValue valueForKey:@"userName"];
    }else
    {
        user.name = @"Anonyme";
    }
    self.user = user;
    
    self.playlist.userId = user.id;
    self.playlist.userName = user.name;
    //sourceKey and trackId
    [self parseSource];
    return self;
    
    
}

+ (NSValueTransformer *)commentsJSONTransformer
{
    
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[Comment class]];
}


+ (NSValueTransformer *)repostJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[WDTrack class]];
}


+ (NSValueTransformer *)playlistJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[Playlist class]];
}

- (BOOL)parseSource
{
    
    if (![self loadSource])
    {
        return NO;
    }
    [self textAsComment];
    
    return YES;
    
}

- (BOOL)loadSource
{
    if([self.eId hasPrefix:@"/yt"])
    {
        self.type = TrackTypeVideo;
        if (!self.sourceKey || ![self.sourceKey isEqualToString:WDSourceYoutube]) {
            self.sourceKey = WDSourceYoutube;
            self.trackId = [self.eId substringFromIndex: 4];
        }
        
        self.imageUrl = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/sddefault.jpg", self.trackId];
        
    }else if([self.eId hasPrefix:@"/sc"])
    {
        self.type = TrackTypeAudio;
        self.sourceKey = WDSourceSoundcloud;

        NSUInteger idPosition = [self.eId rangeOfString:@"/tracks/"].location + 8 ;
        if(idPosition> 1000)
        {
            return YES;
        }
        self.trackId = [self.eId firstMatchedGroupWithRegex:@"tracks\\/([\\d]+)" ];



//        NSInteger position = [self.eId rangeOfString:@"#http"].location  ;
//        if (position >= 0) {
//            self.trackId = [self.eId substringToIndex:position];
//        }

//        if (!self.sourceKey || ![self.sourceKey isEqualToString:WDSourceSoundcloud]) {
//            self.sourceKey = WDSourceSoundcloud;
//            if (position >= 0) {
//                self.eId = [self.eId substringToIndex:position-1];
//            }
//        }

        
        self.imageUrl = [self.imageUrl stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
        
        
        
    }
    else if([self.eId hasPrefix:@"/dz"])
    {
        self.type = TrackTypeAudio;
        self.sourceKey = WDSourceDeezer;
        self.trackId = [self.eId substringFromIndex: 4];
        self.imageUrl = self.img;
    }
    else if([self.eId hasPrefix:@"/vi"])
    {
        self.type = TrackTypeVideo;
        self.sourceKey = WDSourceVimeo;
        self.trackId = [self.eId substringFromIndex: 4];
        self.imageUrl = self.img;
    }
    else if([self.eId hasSuffix:@".mp3"])
    {
        self.type = TrackTypeAudio;
        self.sourceKey = WDSourceMp3;
        self.trackId = self.streamUrl = self.eId;
        self.imageUrl = self.img;
    }
    else if([self.eId hasPrefix:@"/dm"])
    {
        self.type = TrackTypeVideo;
        self.sourceKey = WDSourceDailymotion;
        self.trackId = [self.eId substringFromIndex: 4];
        self.imageUrl = self.img;
    }else if([self.eId hasPrefix:@"/bc"])
    {
        self.type = TrackTypeAudio;
        self.sourceKey = WDSourceBandcamp;
        // self.trackId = [self.eId substringFromIndex: 4];
        self.trackId = self.eId;
        self.imageUrl = self.img;
        
        DLog(@"self.eId %@", self.eId);
        DLog(@"self.trackId %@", self.trackId);

        
    }else if([self.eId hasPrefix:@"/ja"])
    {
        self.type = TrackTypeAudio;
        self.sourceKey = WDSourceJamendo;
        self.trackId = [self.eId substringFromIndex: 4];
        self.imageUrl = self.img;
        
    }else if(self.name.length > 0)
    {
        self.sourceKey =  WDSourceUnAvailable;
        return NO;
        DLog(@"Not find %@", self.name);
    }
    
    return YES;
}

- (void) textAsComment
{
    
    if (self.text.length) {
        
        Comment *comment = [Comment new];
        comment.text = self.text;
        comment.user = self.user;
        comment.id = self.id;
        NSMutableArray *mArray = [NSMutableArray arrayWithObject:comment];
        [mArray addObjectsFromArray:self.comments];
        self.comments = mArray;
    }
}


#pragma mark SETTERS


- (void)setId2:(NSString *)id2
{
    _id = id2;
}

- (void)setPId:(NSString *)pId
{
    _id = pId;
}

- (void) setEId:(NSString *)eId
{
    _eId = eId;
    
}

- (void)setText:(NSString *)text
{
    
    
    //UPDATE LEGEND
    if (self.comments.count) {
        Comment *firstComment = (Comment *)self.comments.firstObject;
        //IF FIRST COMMENT IS A TEXT OF AUTHOR TOO
        if ([firstComment.text isEqualToString:self.text]) {
            firstComment.text = text;
        }
        _text = text;
    }else
    {
        _text = text;
        //   [self textAsComment];
    }
    
    
}

- (void)setLikes:(NSArray *)likes
{
    self.likesCount = likes.count;
    //isLiked
    if (self.likesCount) {
        for (NSString* uId in likes) {
            if ([uId isEqualToString:[WDHelper manager].currentUser.id]) {
                _isLiked = YES;
                break;
            }
        }
    }
    
}

- (void)setIsLiked:(BOOL)isLiked
{
    
    _isLiked = isLiked;
    
    if (isLiked) {
        self.likesCount ++;
    }else
    {
        self.likesCount --;
    }
    
}

- (void)setImg:(NSString *)img
{
    _img = self.imageUrl = img;
}


#pragma mark GETTER

- (NSString *)date
{
    return [WDHelper dateFromId:self.id];
}


- (NSUInteger)repostsCount
{
    if(self.reposts)
    {
        return self.reposts.count;
    }else if (_repostsCount) {
        return _repostsCount;
    }
    return 0;
}

- (NSUInteger)updatedAvailableImageUrl
{
    
    if ([self.sourceKey isEqualToString:WDSourceYoutube]) {
        self.imageUrl = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", self.trackId];
    }else if ([self.sourceKey isEqualToString:WDSourceSoundcloud])
    {
        self.imageUrl = [_imageUrl stringByReplacingOccurrencesOfString:@"-t300x300" withString:@"-t300x300"];
    }
    
    _updatedAvailableImageUrl++;
    
    return _updatedAvailableImageUrl;
}


//FIND THE BEST SOURCE
- (void)prepareTrack:(void(^)(AVPlayerItem *playerItem))success failure:(void(^)(NSError *error))failure
{
    
        [self playerItem:^(AVPlayerItem *playerItem) {
            success(playerItem);
        } failure:^(NSError *error) {
            failure(error);
        }];

}

- (void)playerItem:(void(^)(AVPlayerItem *playerItem))success failure:(void(^)(NSError *error))failure
{
    
    DLog(@"Preparing %@", self.name);
    if (!self.playerItem) {
        
        if(!self.streamUrl)
        {
            NSString* className = [NSString stringWithFormat:@"WDPlayerUrl%@",[self.sourceKey capitalizedString]];
            self.playerUrl = [[NSClassFromString(className) alloc] init];
            DLog(@"Load url %@ = %@",self.sourceKey, self.name);
            __weak WDTrack *track = self;
            
            
            [self.playerUrl urlByTrackId:self.trackId success:^(NSString *url) {
                
                DLog(@"URl loaded => %@", url);

                if (url) {
                    track.streamUrl = url;
                    
                    WDPlayerItem *item = [[WDPlayerItem alloc] initWithURL:[NSURL URLWithString:self.streamUrl]];
                    // track.totalDutation = CMTimeGetSeconds(item.asset.duration);
                    track.playerItem = item;
                    track.readyToPlay = YES;

                    success(item);
                }else
                {
                    DLog(@"ERROR loaded => %@", url);

                }
           
            } failure:^(NSError *e) {
                failure(e);
            }];
        }else
        {
            self.readyToPlay = YES;

            WDPlayerItem *item = [[WDPlayerItem alloc] initWithURL:[NSURL URLWithString:self.streamUrl]];
            success(item);
        }
        
        
        
        
    }else
    {
        self.readyToPlay = YES;
        NSLog(@"ITEM ======> %p", self.playerItem);
        return success(self.playerItem);
    }
}


- (void)streamUrlCancelRequest
{
    if (!self.streamUrl && self.playerUrl) {
        self.playerUrl = nil;
    }
}

- (NSString *)url
{
    //    urlPrefix + (hasPostUrl ? "/post/" : "/c/") + post._id,
    return [NSString stringWithFormat:@"%@/c/%@", API_BASE_URL,self.id];
}



@end
