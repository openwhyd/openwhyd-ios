//
//  User.h
//  Whyd
//
//  Created by Damien Romito on 05/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Mantle.h"
#import "UserLinks.h"


@interface User : MTLModel <MTLJSONSerializing>

typedef NS_ENUM(NSInteger, UserImageSize) {
    UserImageSizeSmall = 1,
    UserImageSizeMedium = 2,
    UserImageSizeLarge = 3,
};

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *handle;

@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *fbId;
@property (nonatomic, strong) NSString *fbTok;
@property (nonatomic, strong) NSString *twId;
@property (nonatomic, strong) NSString *twSec;
@property (nonatomic, strong) NSString *twTok;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *loc;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSArray *pl;
@property (nonatomic, strong) NSDictionary *pref;
@property (nonatomic, strong) NSDictionary *tags;

@property (nonatomic, strong) UserLinks *lnk;
@property (nonatomic) NSInteger nbSubscribers;
@property (nonatomic) NSInteger nbSubscriptions;
@property (nonatomic) NSInteger nbLikes;
@property (nonatomic) NSInteger nbPosts;
@property (nonatomic) NSInteger isSubscribing;



+ (User *) retreiveUserSaved;
+ (void) saveAsCurrentUser:(User *)user;
+ (User *) saveAsCurrentUserFromDictionary:(NSDictionary *)userDictionary;
+ (NSString *)imageUrl:(UserImageSize)size ofUserId:(NSString *)userId;
+ (NSArray*)parseUsersArray:(NSArray*)userArray;
+ (void)updateDecodeScriptWithNewDate:(NSString*)newDateScript success:(void(^)(BOOL updated))success;
- (NSString *)imageUrl:(UserImageSize)size;
- (NSString *)imageCoverUrl;


@end
