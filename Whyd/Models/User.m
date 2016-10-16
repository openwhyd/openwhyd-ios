//
//  User.m
//  Whyd
//
//  Created by Damien Romito on 05/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "User.h"
#import "WDHelper.h"
#import "NSDictionary+Additions.h"
#import "Playlist.h"

@interface User()
@property (nonatomic, readonly) NSString*tempId;
@property (nonatomic, readonly) NSString*tempTNm;
@property (nonatomic, readonly) NSString*tempUNm;
@property (nonatomic, readonly) NSString*tempUId;
@property (nonatomic, readonly) NSString*tempTId;

@property (nonatomic, readonly) BOOL tempSubscribed;
@property (nonatomic, readonly) BOOL tempIsSubscribed;

@end

@implementation User

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isSubscribing = -1; 
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"id",
             @"tempTId": @"tId", //api doublon
             @"tempUId": @"uId", //api doublon
             @"tempId": @"_id", //api doublon
             @"email": @"email",
             @"fbId": @"fbId",
             @"fbTok": @"fbTok",
             @"twId": @"twId",
             @"twSec": @"twSec",
             @"twTok": @"twTok",
             @"name": @"name",
             @"tempTNm": @"tNm",
             @"tempUNm": @"uNm",
             @"handle": @"handle",
             @"tags": @"tags",
             @"mid": @"mid",
             @"bio": @"bio",
             @"loc": @"loc",
             @"pref": @"pref",
             @"tempSubscribed" : @"subscribed", //api doublon
             @"tempIsSubscribed": @"isSubscribed", //api doublon
             @"isSubscribing": @"isSubscribing",
             @"nbSubscriptions": @"nbSubscriptions",
             @"nbSubscribers": @"nbSubscribers",
             @"nbPosts": @"nbPosts",
             @"nbLikes": @"nbLikes",
             };
}


- (NSString *)imageCoverUrl
{
    return [NSString stringWithFormat:@"%@/img/userCover/%@",API_BASE_URL,self.id];
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    
    self = [super initWithDictionary:dictionaryValue error:error];

    for (Playlist *p in self.pl) {
        p.userId = self.id;
        p.userName = self.name;
    }
    
    
    return self;
    
}


+ (NSValueTransformer *)lnkJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[UserLinks class]];
}


+ (NSValueTransformer *)plJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[Playlist class]];
}


#pragma mark SETTER

- (void)setTempId:(NSString *)tempId
{
    _id = tempId;
}


- (void)setTempTId:(NSString *)tempTId
{
    _id = tempTId;
}


- (void)setTempUId:(NSString *)tempUId
{
    _id = tempUId;
}


- (void)setTempTNm:(NSString *)tempTNm
{
    _name = tempTNm;
}


- (void)setTempUNm:(NSString *)tempUNm
{
    _name = tempUNm;
}




- (void)setTempSubscribed:(BOOL)tempSubscribed
{
    _isSubscribing = tempSubscribed;
}

- (void)setTempIsSubscribed:(BOOL)tempIsSubscribed
{
    _isSubscribing = tempIsSubscribed;
}


-(void)setTwSec:(NSString *)twSec
{
    [[NSUserDefaults standardUserDefaults] setValue:twSec forKey:USERDEFAULT_TWITTER_SEC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTwTok:(NSString *)twTok
{
    [[NSUserDefaults standardUserDefaults] setValue:twTok forKey:USERDEFAULT_TWITTER_TOK];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPref:(NSDictionary *)pref
{
    if (pref) {
        [[NSUserDefaults standardUserDefaults] setObject:pref forKey:USERDEFAULT_PREFERENCES_NOTIFICATIONS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark GETTER

- (NSDictionary *)pref
{
    NSDictionary *pref;
    if ([self.id isEqualToString:[WDHelper manager].currentUser.id]) {
        pref = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_PREFERENCES_NOTIFICATIONS];
    }
    return pref;
}

- (NSString *)imageUrl:(UserImageSize)size
{
    return [User imageUrl:size ofUserId:self.id];
}

+(NSString *)imageUrl:(UserImageSize)size ofUserId:(NSString *)userId
{
    NSUInteger s = 0;
    switch (size) {
        case UserImageSizeSmall:
            s = 70;
            break;
        case UserImageSizeMedium:
            s=200;
            break;
        case UserImageSizeLarge:
            s=400;
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@/img/user/%@?width=%d&height=%d",API_BASE_URL, userId, (int)s, (int)s ];
}

- (NSString *)twTok
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_TWITTER_TOK];
}

- (NSString *)twSec
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_TWITTER_SEC];
}

#pragma mark STATIC METHOD
+ (void)updateDecodeScriptWithNewDate:(NSString*)newDateScript success:(void(^)(BOOL updated))success
{
    NSString * currentDateScript = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_DECODE_HTML_DATE];

    if (!currentDateScript) {
        currentDateScript = DEFAULT_DECODE_HTML_DATE;
    }
    
    if(([currentDateScript doubleValue] < [newDateScript doubleValue]))
    {
        [[NSUserDefaults standardUserDefaults] setValue:newDateScript forKey:USERDEFAULT_DECODE_HTML_DATE];
        [[NSUserDefaults standardUserDefaults] synchronize];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:API_DECODE_SCRIPT_URL]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[NSUserDefaults standardUserDefaults] setObject:htmlString forKey:USERDEFAULT_DECODE_HTML_CODE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setValue:newDateScript forKey:USERDEFAULT_DECODE_HTML_DATE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (success) success(YES);
        }];
        
    }else if (success)
    {
       success(NO);
    }

}

+ (User *)saveAsCurrentUserFromDictionary:(NSDictionary *)userDictionary
{
    //DECODE VEVO SCRIPT
    [User updateDecodeScriptWithNewDate:[userDictionary valueForKey:@"decodeVer"] success:nil];
    
    User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:userDictionary error:nil];
    [WDHelper manager].currentUser = user;
        
    [[NSUserDefaults standardUserDefaults] setObject:userDictionary forKey:USERDEFAULT_CURRENT_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
  
    
    return user;
    
}

+ (void)saveAsCurrentUser:(User *)user
{
    
    [WDHelper manager].currentUser = user;
   // DLog(@"USER %@", user);
    NSDictionary* userDict = [NSDictionary dictionaryWithPropertiesOfObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:USERDEFAULT_CURRENT_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

+ (User *)retreiveUserSaved
{
    
    NSDictionary* userDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USERDEFAULT_CURRENT_USER];
    NSLog(@"USERRRR R %@", userDict);
    return [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:userDict error:nil];

}

+ (NSArray*)parseUsersArray:(NSArray*)userArray
{
    NSMutableArray *users = [[NSMutableArray alloc] init];//WithCapacity:[responseObject count]
    
    for (NSDictionary *u in userArray) {
        User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:u error:nil];
        [users addObject:user];
    }
    
    return users;
}




@end
