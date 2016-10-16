//
//  WDFacebookHelper.h
//  Whyd
//
//  Created by Damien Romito on 30/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTrack.h"


@interface WDFacebookHelper : NSObject

+(void)shareTrack:(WDTrack*)track;

+ (void)linkAccount:(void (^)(NSString *username))success failure:(void(^)(NSError *error))failure;
+ (void)loginInViewController:(UIViewController *)viewController success:(void (^)())success failure:(void (^)(NSError *error, User *user))failure;
+ (BOOL)checkAccessToken;
+ (BOOL)checkPermissions:(NSArray *)permissions;


@end
