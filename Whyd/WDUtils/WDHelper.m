//
//  WDHelper.m
//  Whyd
//
//  Created by Damien Romito on 31/01/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDHelper.h"
#import "WDPlayerManager.h"
#import <CommonCrypto/CommonHMAC.h> //MD5
#import <Security/Security.h>
#import "UserViewController.h"
#import "SDImageCache.h"
#import "Activity.h"
#import "WDAlertView.h"
#import "WDWelcomeView.h"
#import "TrackViewController.h"
#import "PlaylistViewController.h"
#import "WDNavigationController.h"



static WDHelper* helper;

@implementation WDHelper

+ (WDHelper *) manager
{
    if(!helper)
    {
        helper = [[WDHelper alloc] init];
        helper.currentUser = [User retreiveUserSaved];
        helper.sizer = [[OHAttributedLabel alloc]init];
        helper.sizer.numberOfLines = 0;
        helper.dateFormatter = [[NSDateFormatter alloc] init];
        [helper.dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [helper.sizer setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3]];
    }
	return helper;
}

#pragma Public methods
- (BOOL) isAdmin
{
    NSArray *adminId = [NSArray arrayWithObjects:@"510ac91b7e91c862b2aa9b05",@"4d94501d1f78ac091dbc9b4d", nil];
    NSInteger ind = [adminId indexOfObject:self.currentUser.id];
    return (ind != NSNotFound);
}



- (void)setCurrentUser:(User *)currentUser
{
    _currentUser = currentUser;
}


#pragma -mark  Login Helper


+ (void)registerWithParameters:(NSMutableDictionary *)parameters success:(void (^)(User *user))success failure:(void (^)(NSError *error))failure
{
    [WDClient sTkParameter:^(NSString *sTk) {
        
        [parameters setValue:@1 forKeyPath:@"includeUser"];
        
        [parameters setValue:sTk forKey:@"sTk"];
        
        
        DLog(@"PARAAAAAAMS  %@",parameters);
        
        [[WDClient client] POST: API_REGISTER parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"response %@", responseObject);
            
            if ([responseObject valueForKey:@"error"]) {

                NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : [responseObject valueForKey:@"error"],
                                             @"parameters" : parameters};
                NSError *error = [NSError errorWithDomain:API_BASE_URL code:0 userInfo:userInfo];
                failure(error);
                
            }else
            {
                
                
                User *user = [User saveAsCurrentUserFromDictionary:[responseObject valueForKey:@"user"]];
                
                
                if ([parameters valueForKey:@"fbTok"]) {
                    [Flurry logEvent:FLURRY_REGISTER_ACTION];
                    
                    user.fbId = [parameters valueForKey:@"fbUid"];
                    user.fbTok = [parameters valueForKey:@"fbTok"];
                }else
                {
                    [Flurry logEvent:FLURRY_REGISTER_EMAIL];
                }
                
                
                //                //CIOKIES
                //                NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
                //                for (NSHTTPCookie *cookie in cookies)
                //                {
                //                    NSLog(@"cookies %@", cookie);
                //                }
                
                success(user);
                
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"error %@", error);
            failure(error);
        }];
    }];
    
    
}



+ (void) loginWithParameters:(NSDictionary*)parameters success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    
    //FB OR EMAIL?
    NSString *apiUrl = ([parameters valueForKey:@"fbUid"] && ![parameters valueForKey:@"update"])?API_LOGIN_FACEBOOK:API_LOGIN_EMAIL;
    

    [[WDClient client] GET:apiUrl parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {

        DLog(@"responseObject %@",responseObject);
        if ([responseObject valueForKey:@"error"]) {
            
            //ERROR
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[responseObject valueForKey:@"error"] forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:@"openwhyd.org" code:0 userInfo:userInfo];
            failure(error);
            
            DLog(@"ERROR LOG %@",responseObject);
            
        }else if([responseObject valueForKey:@"user"])
        {
            
             DLog(@"USER LOG!! %@",[responseObject valueForKey:@"user"]);
            //SAVE CURRENT USER
            
            if([parameters valueForKey:@"update"])
            {
                [responseObject setValue:[parameters valueForKey:@"fbTok"] forKey:@"fbTok"];
                [responseObject setValue:[parameters valueForKey:@"fbUid"] forKey:@"fbId"];
            }


            User *user = [User saveAsCurrentUserFromDictionary:[responseObject valueForKey:@"user"]];
            
            if ([FBSDKAccessToken currentAccessToken] && user.fbId &&  [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"publish_actions"]) {
                 DLog(@"PERMISSION %@",[FBSDKAccessToken currentAccessToken].permissions);
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_AUTOSHARE_FB];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (user.twId) {
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_AUTOSHARE_TW];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            success();
        }else if([responseObject valueForKey:@"fbUser"])
        {
            NSMutableDictionary *fbUser = [NSMutableDictionary dictionaryWithDictionary:[responseObject valueForKey:@"fbUser"]];
            [fbUser addEntriesFromDictionary:parameters];
            NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"ErrorFacebookNotLinked", nil) ,
                                         @"fbUser" : fbUser};
            DLog(@"USER INFOS %@", userInfo);
            NSError *error = [NSError errorWithDomain:API_BASE_URL code:0 userInfo:userInfo];
            failure(error);
      
        }else if ([responseObject valueForKey:@"result"])
        {
            NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"ErrorFacebookNotLinked", nil) ,
                                         @"parameters" : parameters};
            DLog(@"USER INFOS %@", userInfo);
            NSError *error = [NSError errorWithDomain:API_BASE_URL code:0 userInfo:userInfo];
            failure(error);
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"ERROR %@", error);
        failure(error);
    }];
}


+ (BOOL) isLogged
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSHTTPCookie *logCookie;

    for (NSHTTPCookie *cookie in cookies)
    {
        if([cookie.name isEqualToString:@"whydSid"])
        {
            logCookie = cookie;
        }
    }
    if(logCookie)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+ (void) logout
{
    //STOP PLAYER
    [[WDPlayerManager manager] stop];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_CURRENT_USER];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_TUTO_SEEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_NOTIFICATIONS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_AUTOSHARE_TW];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_AUTOSHARE_FB];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //FB
    if([FBSDKAccessToken currentAccessToken])
    {
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
    }
    
    //REMOVE COOKIES
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
}

#pragma -mark Client helper


+ (void)onBoardingEndinView:(UIViewController *)controller WithUIsdToFollow:(NSArray *)uIdsToFollow
{
    ///ANIM TRANSITION
    [[NSNotificationCenter defaultCenter] addObserver:[MainViewController manager] selector:@selector(onboardingWithSuccess) name:NOTIFICATION_ONBOARDING_SUCCESS object:nil];

    
    WDWelcomeView *welcomeView = [[WDWelcomeView alloc] initWithFrame:[MainViewController manager].view.frame];
    welcomeView.delegate = [MainViewController manager];
    [[MainViewController manager].view addSubview:welcomeView];

    [WDHelper circleTransitioninView:[[UIApplication sharedApplication] keyWindow] completion:^{
        [controller.navigationController dismissViewControllerAnimated:NO completion:nil];
        [welcomeView show];
    }];
    
    NSString *uIdsToFollowString = [uIdsToFollow componentsJoinedByString:@","];
    
    NSDictionary *parameters = @{@"ajax":@"follow",
                                 @"uids": uIdsToFollowString};
    
    
    
    [WDHelper manager].currentUser.nbSubscriptions = uIdsToFollow.count;
    
    [[WDClient client] POST:API_ONBOARDING parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSLog(@"RESPONDE SUBSCRIBE %@", responseObject);

        if ([responseObject valueForKey:@"error"]) {
            DLog(@"ERROR");
        }else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ONBOARDING_SUCCESS object:self];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"ERROR");
    }];



}


+ (void)insertTrack:(WDTrack*)track editing:(BOOL)editing
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:track.text forKey:@"text"];
    [parameters setObject:@"insert" forKey:@"action"];
    [parameters setObject:track.name forKey:@"name"];
   // [parameters setObject:@"/sp/382n05RtneO3ykQlFQrAd1" forKey:@"eId"];
    [parameters setObject:track.eId forKey:@"eId"];

    if(track.id)
    {
        if (editing) {
            [parameters setObject:track.id forKey:@"_id"];
            
        }else
        {
            [parameters setObject:track.id forKey:@"pId"];
        }
        
    }else
    {
        if (track.imageUrl) {
            [parameters setObject:track.imageUrl forKey:@"img"];

        }
    }
    
    if (track.playlist) {
        NSDictionary *playlist = @{@"id": track.playlist.id,
                                   @"name": track.playlist.name};
        [parameters setObject:playlist forKey:@"pl"];
    }
    
    
    if(track.fromHotTracks)
    {
        //to prevent too much virality
        [parameters setObject:@"hot" forKey:@"ctx"];
    }
    
    [[WDClient client] GET:@"/api/post" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"RESPONSE %@", responseObject);
        
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task,error);
        }
    }];
    
}



#pragma -mark Utils

+ (void) runAfterDelay:(CGFloat)delay block:(void (^)())block
{
    void (^block_)() = [block copy];
    [WDHelper performSelector:@selector(runBlock:) withObject:block_ afterDelay:delay];
    
}


+ (void) runBlock:(void (^)())block
{
    block();
}

#pragma -mark Date Helpers
+ (NSString *)dateFromString:(NSString *)dateString
{
    NSDate *date = [self NSDateFromString:dateString];
    return [WDHelper timeAgo:date withType:DateFormatTypeNotifs];
}

+ (NSDate *)NSDateFromString:(NSString *)dateString
{
    [[WDHelper manager].dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return [[WDHelper manager].dateFormatter dateFromString:dateString];

}

+ (NSString *)dateFromId:(NSString *)stringId;
{
    NSString* dateString = [stringId substringToIndex:8];
    unsigned int result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dateString];
    [scanner scanHexInt:&result];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:result];
    NSString *ago = [WDHelper timeAgo:date withType:DateFormatTypeMin];
    return ago;
}


+ (NSString *)timeAgo:(NSDate *)compareDate withType:(DateFormatType)type
{
    NSTimeInterval timeInterval = -[compareDate timeIntervalSinceNow];
    int temp = 0;
    NSString *result;
    
    
    if (timeInterval < 60)
    {
        result = (type == DateFormatTypeMin)? NSLocalizedString(@"DateNow", nil):[NSLocalizedString(@"DateNow", nil) uppercaseString] ;   //less than a minute
    }else if((temp = timeInterval/60) <60)
    {
        result = [NSString stringWithFormat:(type == DateFormatTypeMin)?NSLocalizedString(@"DateMinutes", nil):NSLocalizedString(@"DateMunitesNotifs", nil),temp];   //minutes ago
    }else if((temp = temp/60) <24)
    {
        result = [NSString stringWithFormat:(type == DateFormatTypeMin)?NSLocalizedString(@"DateHours", nil):NSLocalizedString(@"DateHoursNotifs", nil),temp];   //hours ago
    }else if((temp = temp / 24) < 30){
        result = [NSString stringWithFormat:(type == DateFormatTypeMin)?NSLocalizedString(@"DateDays", nil):NSLocalizedString(@"DateDaysNotifs", nil),temp];   //days ago
    }
    else{
        temp = temp / 30;
        if (temp<12) {
            [[WDHelper manager].dateFormatter setDateFormat: NSLocalizedString(@"DateInYearFormat", nil)];
        }else
        {
            [[WDHelper manager].dateFormatter setDateFormat:NSLocalizedString(@"DateFormat", nil)];
        }
        result = [[WDHelper manager].dateFormatter stringFromDate:compareDate];
        
    }
    return  result;
}

+ (NSString*) stringToMd5:(NSString*)string
{
    
    const char *cstr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
    
    
}


+ (NSData *)hmacForKey:(NSString *)key andData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}


+ (NSString *)stringDurationFromFloat:(float)duration
{
    int minutes = duration / 60;
    int seconds = (int)duration % 60;
    NSString *secondsString = [NSString stringWithFormat:@"%@%i", (seconds<10)?@"0":@"" , seconds];
    return [NSString stringWithFormat:@"%i:%@",minutes, secondsString];
}

+ (NSString *)stringCountFromInteger:(NSInteger)count
{
    if (count<10000) {
        return [NSString stringWithFormat:@"%li", (long)count ];
    }else
    {
        return [NSString stringWithFormat:@"%lik", (long)count/1000 ];
    }
}



#pragma -mark Graphic Helper

+ (void)circleTransitioninView:(UIView *)container completion:(void (^)())completion
{
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(container.frame.size.width/2, container.frame.size.height/2.5, 10, 10)];
    circle.backgroundColor = RGBCOLOR(24, 30, 34);
    circle.layer.cornerRadius = 5;
    [container addSubview:circle];
    
    [UIView animateWithDuration:0.8 animations:^{
        circle.transform = CGAffineTransformMakeScale(100, 100);
    } completion:^(BOOL finished) {
        completion();
        [circle removeFromSuperview];

    }];
    
}

+ (UIActivityIndicatorView *) WDActivityIndicator
{
    
    CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;

    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    ai.frame = CGRectMake(size.width / 2 - 40, 0, 80, 80);
    ai.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
    ai.layer.cornerRadius = 5;
    return ai;
}

+ (void)playTrackForRatePopup
{
    NSInteger playCount = [[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_PLAY_COUNT] integerValue];
    playCount = playCount +1;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:playCount] forKey:USERDEFAULT_PLAY_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *alreadyAsked = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_RATE_ASKED_SKIP];
    if ( (!alreadyAsked && playCount == SETTING_PLAY_COUNT_BEFORE_RATE_POPUP) || (playCount == SETTING_PLAY_COUNT_BEFORE_RATE_POPUP2 && alreadyAsked) ) {
        [WDHelper runAfterDelay:2 block:^{
           [WDAlertView showWithType:WDAlertTypeRate];
        }];
        
    }
}

+ (void)addTrackCountForRatePopup
{
    NSInteger addCount = [[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_ADD_COUNT] integerValue];
    addCount = addCount +1;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:addCount] forKey:USERDEFAULT_ADD_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *alreadyAsked = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_RATE_ASKED_SKIP];

    if ( (!alreadyAsked &&  addCount == SETTING_ADD_COUNT_BEFORE_RATE_POPUP) ||  (addCount == SETTING_PLAY_COUNT_BEFORE_RATE_POPUP2 && alreadyAsked)) {
        [WDAlertView showWithType:WDAlertTypeRate];
    }
}

+ (void)apnSet
{
    [Flurry logEvent:FLURRY_ALLOWNOTIF_YES];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    

    [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_APN_ASKED];
}

+ (BOOL)apnIsAlreadyAsked
{
    if ( [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_ASKED]) {
        return YES;
    }else
    {
        return NO;
    }
}

+ (void)apnAskAfterPost
{
    if (![WDHelper apnIsAlreadyAsked] && ![[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_POST_ASKED]) {
        [WDAlertView showWithType:WDAlertTypeAPN];
    }

}

+ (BOOL)openHref:(NSString*)hrefString success:(void(^)(UIViewController *vc))success
{
    NSString *urlId = [hrefString substringFromIndex:3];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    if ([hrefString hasPrefix:@"/c"])
    {
        [[MainViewController manager].loadingView startAnimating];
        [[WDClient client] GET:API_TRACK_INFO(urlId) parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [[MainViewController manager].loadingView stopAnimating];
            TrackViewController *vc = [[TrackViewController alloc] init];
            vc.track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:[responseObject objectForKey:@"data"]  error:nil];
            vc.playlist = [Playlist new];
            vc.playlist.tracks = [NSArray arrayWithObject:vc.track];
            success(vc);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[MainViewController manager].loadingView stopAnimating];
        }];
        
    }else if ([hrefString rangeOfString:@"playlist"].location != NSNotFound)
    {
        [[MainViewController manager].loadingView startAnimating];
        [Playlist playlistFromHref:hrefString success:^(Playlist *playlist) {
            [[MainViewController manager].loadingView stopAnimating];
            PlaylistViewController *vc = [[PlaylistViewController alloc] initWithPlaylist:playlist];
            success(vc);
        }];
        
    }else if([hrefString hasPrefix:@"/u"])
    {
        User *user = [User new];
        user.id = urlId;
        UserViewController *vc = [[UserViewController alloc] initWithUser:user];
        // [[MainViewController manager].navigationController presentViewController:nav animated:YES completion:nil];
        success(vc);
    }else
    {
        return NO;
    }
    return YES;
}
//
//+ (BOOL)openHref:(NSString*)hrefString inNavController:(UINavigationController*)navController isModel:(BOOL)isModal
//{
//    NSString *urlId = [hrefString substringFromIndex:3];
//    
//    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
//    
//    if ([hrefString hasPrefix:@"/c"])
//    {
//        [[MainViewController manager].loadingView startAnimating];
//        [[WDClient client] GET:API_TRACK_INFO(urlId) parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//            [[MainViewController manager].loadingView stopAnimating];
//            TrackViewController *vc = [[TrackViewController alloc] init];
//            vc.track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:[responseObject objectForKey:@"data"]  error:nil];
//            vc.playlist = [Playlist new];
//            vc.playlist.tracks = [NSArray arrayWithObject:vc.track];
//            [WDHelper pushVc:vc inNavController:navController isModel:isModal];
//        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//             [[MainViewController manager].loadingView stopAnimating];
//        }];
//        
//    }else if ([hrefString rangeOfString:@"playlist"].location != NSNotFound)
//    {
//        [[MainViewController manager].loadingView startAnimating];
//        [Playlist playlistFromHref:hrefString success:^(Playlist *playlist) {
//            [[MainViewController manager].loadingView stopAnimating];
//            PlaylistViewController *vc = [[PlaylistViewController alloc] initWithPlaylist:playlist];
//            [WDHelper pushVc:vc inNavController:navController isModel:isModal];
//        }];
//        
//    }else if([hrefString hasPrefix:@"/u"])
//    {
//        User *user = [User new];
//        user.id = urlId;
//        UserViewController *vc = [[UserViewController alloc] initWithUser:user];
//       // [[MainViewController manager].navigationController presentViewController:nav animated:YES completion:nil];
//        
//        [WDHelper pushVc:vc inNavController:navController isModel:isModal];
//    }else
//    {
//        return NO;
//    }
//    return YES;
//}
//
//+ (void)pushVc:(UIViewController*)vc inNavController:(UINavigationController*)navController isModel:(BOOL)isModal
//{
//    if (isModal) {
//        
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        [nav.navigationBar setTranslucent:NO];
//        [navController presentViewController:nav animated:YES completion:nil];
//    }else
//    {
//        [navController pushViewController:vc animated:YES];
//    }
//}
//


+ (void)apnPushed:(NSDictionary *)userInfo withApplicationState:(UIApplicationState)applicationState
{
    
    //IF LOG
    if ([WDHelper manager].currentUser) {
        
        DLog(@"userInfo %@",userInfo);
        if ([userInfo valueForKey:@"href"]) {
            
            [WDHelper openHref:[userInfo valueForKey:@"href"] success:^(UIViewController *vc) {
                
                WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
                [nav.navigationBar setTranslucent:NO];
                [[MainViewController manager].navigationController presentViewController:nav animated:YES completion:nil];
            }];
        }
        
        
    }else if(applicationState != UIApplicationStateActive)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"NotificationsAlertLogoutTitle", nil)
                                                        message: NSLocalizedString(@"NotificationsAlertLogout", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
}



#pragma -mark Navigation Helpers
+ (UIViewController*)viewControllerToPushWithLinkInfo:(NSTextCheckingResult*)linkInfo
{
    NSString *linkString = linkInfo.description;

    DLog(@"linkinfo %@", linkInfo.description);
    if ([linkString rangeOfString:@"http://"].location != NSNotFound || [linkString rangeOfString:@"https://"].location != NSNotFound) {
        NSURL *link = [NSURL URLWithString:linkString];
        [[UIApplication sharedApplication] openURL:link];
        return nil;
    }
    else
    {
        NSInteger position = [linkInfo.description rangeOfString:OPEN_URL_BASE].location + (OPEN_URL_BASE.length);
        NSString* pathString = [linkInfo.description substringFromIndex:position];
        pathString = [pathString substringToIndex:pathString.length-1];
        
        if ([pathString hasPrefix:@"user"]) {
            NSString* id = [pathString substringFromIndex:5];
            
            User *user = [User new];
            user.id = id;
            UserViewController* vc = [[UserViewController alloc] initWithUser:user];
            return vc;
        }
        else
        {
            return nil;
        }
    }

}



#pragma -mark Validation Helpers

+(void) checkIfNeedUpdate:(void(^)(NSString *version))success failure:(void(^)(NSError *error))failure
{
    [[WDClient client] GET:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", APP_STORE_APP_ID] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // compare version with your apps local version
        NSLog(@"%@",responseObject);
        if([[responseObject valueForKey:@"result"] count]){
            NSString *iTunesVersion = [[responseObject valueForKeyPath:@"results.version"] objectAtIndex:0];
            NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)@"CFBundleShortVersionString"];
            
            if (([appVersion compare:iTunesVersion options:NSNumericSearch] == NSOrderedAscending)) {
                
                NSString *skipVer = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_UPDATE_VER_SKIP];
                if ( !skipVer || (skipVer && ([skipVer compare:iTunesVersion options:NSNumericSearch] == NSOrderedAscending))) {
                    success(iTunesVersion);
                }else
                {
                    success(nil);
                }
            }else
            {
                success(nil);
            }

        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

+ (BOOL) usernameIsValide:(NSString*)username
{
    NSArray *USERNAME_RESERVED = @[@"index.html",@"null",@"undefined",
                                   @"whyd",@"blog",@"music",@"playlist",
                                   @"playlists",@"about",@"robots.txt",
                                   @"favicon.ico",@"favicon.png"];
    
    if ([USERNAME_RESERVED containsObject:[username lowercaseString]]) {
        return NO;
    }
    
    
    NSString *filter = @"^[a-z0-9_-]{3,18}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:filter options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match =[regex firstMatchInString:username options:0 range:NSMakeRange(0, [username length])];
    
    if(match)
        return YES;
    else
        return NO;
}

+ (BOOL) emailIsValide:(NSString *)email
{
    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
}

+ (BOOL) passwordIsValide:(NSString*)password
{
    NSString *filter = @".{4,32}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:filter options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match =[regex firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    
    if(match)
        return YES;
    else
        return NO;
}

#pragma mark - NSUSERDEFAULT 

+ (NSArray*)favoritesUsers
{
    NSArray *usersSaved = [[NSUserDefaults standardUserDefaults] arrayForKey:USERDEFAULT_FAVORITES_USERS];
    return [User parseUsersArray:usersSaved];
}

+ (void)favoritesUsersSave:(NSArray*)users
{
    
    NSArray *usersSaved = [[NSUserDefaults standardUserDefaults] arrayForKey:USERDEFAULT_FAVORITES_USERS];
    NSMutableArray *lastUsers = [[NSMutableArray alloc] init];
    
    for(User* u in users)
    {
        BOOL exist = NO;
        for (NSDictionary *oldUser in usersSaved) {
            if ([[oldUser valueForKey:@"id"] isEqualToString:u.id]) {
                exist = YES;
                break;
            }
        }
        if (!exist) {
            NSDictionary *user = @{@"name":u.name,
                                   @"id":u.id};
            [lastUsers addObject:user];
        }
    }
    
    NSInteger maxRange = SETTING_FAVORITES_USERS_MAX - lastUsers.count;
    if (maxRange) {

        if (maxRange - (int)usersSaved.count >= 0) {
            maxRange = usersSaved.count;
        }
        
        NSRange rangeSubArray = {0, maxRange};
        [lastUsers addObjectsFromArray:[usersSaved subarrayWithRange:rangeSubArray]];
    }




    
    [[NSUserDefaults standardUserDefaults] setValue:lastUsers forKey:USERDEFAULT_FAVORITES_USERS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
