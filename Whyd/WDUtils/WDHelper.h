//
//  WDHelper.h
//  Whyd
//
//  Created by Damien Romito on 31/01/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "User.h"
#import "WDTrack.h"
#import "WDClient.h"
#import "OHAttributedLabel.h"

typedef NS_ENUM(NSUInteger, DateFormatType) {
	DateFormatTypeMin = 1,
    DateFormatTypeNotifs = 2,
};
@interface WDHelper : NSObject

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) OHAttributedLabel *sizer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

+ (WDHelper *) manager;
- (BOOL) isAdmin;

+ (void)insertTrack:(WDTrack*)track editing:(BOOL)editing
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
+ (void)onBoardingEndinView:(UIViewController *)controller WithUIsdToFollow:(NSArray *)uIdsToFollow;
+ (BOOL)apnIsAlreadyAsked;
+ (void)apnSet;
+ (void)apnAskAfterPost;
+ (void)apnPushed:(NSDictionary *)userInfo withApplicationState:(UIApplicationState)applicationState;
+ (BOOL)openHref:(NSString*)hrefString success:(void(^)(UIViewController *vc))success;
//+ (BOOL)openHref:(NSString*)hrefString inNavController:(UINavigationController*)navController isModel:(BOOL)isModal;

+ (void)addTrackCountForRatePopup;
+ (void)playTrackForRatePopup;

+ (void)circleTransitioninView:(UIView *)container completion:(void (^)())completion;

+ (BOOL)isLogged;
+ (void)registerWithParameters:(NSMutableDictionary *)parameters success:(void (^)(User *user))success failure:(void (^)(NSError *error))failure;
+ (void)loginWithParameters:(NSDictionary*)parameters success:(void (^)())success failure:(void (^)(NSError *error))failure;
+ (void)logout;
+ (NSString *)stringDurationFromFloat:(float)duration;

//CRYPTO
+ (NSString*)stringToMd5:(NSString*)string;
+ (NSData *)hmacForKey:(NSString *)key andData:(NSString *)data;


+ (void)runAfterDelay:(CGFloat)delay block:(void (^)())block;
+ (NSString *)stringCountFromInteger:(NSInteger)count;
+ (UIViewController*)viewControllerToPushWithLinkInfo:(NSTextCheckingResult*)linkInfo;
+ (void)checkIfNeedUpdate:(void(^)(NSString *version))success failure:(void(^)(NSError *error))failure;

+ (NSString *)dateFromId:(NSString *)stringId;
+ (NSDate *)NSDateFromString:(NSString *)dateString;
+ (NSString *)dateFromString:(NSString *)dateString;
+ (UIActivityIndicatorView *) WDActivityIndicator;
+ (BOOL)usernameIsValide:(NSString*)username;
+ (BOOL)emailIsValide:(NSString *)email;
+ (BOOL)passwordIsValide:(NSString*)password;

+ (void)favoritesUsersSave:(NSArray*)users;
+ (NSArray*)favoritesUsers;
@end
