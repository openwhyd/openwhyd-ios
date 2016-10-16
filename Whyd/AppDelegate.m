//
//  AppDelegate.m
//  Whyd
//
//  Created by Damien Romito on 21/01/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
//#import <FacebookSDK/FacebookSDK.h>


#import "AFNetworkActivityIndicatorManager.h"
#import "WDPlayerManager.h"
#import "OHAttributedLabel.h"
#import "UIImage+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "SDImageCache.h"
#import "WDHelper.h"
#import "Activity.h"
#import "WDMessage.h"
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"
#import "WDViews.h"
#import "WDNavigationController.h"
#import "WDAlertView.h"


@import AVFoundation;

@interface AppDelegate()<UIAlertViewDelegate>
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    


    [[Crashlytics sharedInstance] setDebugMode:YES];
    [Crashlytics startWithAPIKey:CRASHLYTICS_CLIENT_ID];
//
    [Flurry startSession:FLURRY_CLIENT_ID];
    /********************************* CACHE *********************************/

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                            diskCapacity:100 * 1024 * 1024
                                                                diskPath:nil];
    
    [NSURLCache setSharedURLCache:sharedCache];
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    /********************************* NAVIGATION *********************************/
    UINavigationController* nav = [[WDNavigationController alloc] initWithRootViewController:[MainViewController manager]];
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    /********************************* SETTINGS APPEARANCE *********************************/
    [ [OHAttributedLabel appearance] setLinkColor:WDCOLOR_BLUE ];
    [ [OHAttributedLabel appearance] setLinkUnderlineStyle:kCTUnderlineStyleNone ];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UINavigationBar appearance]  setBackgroundColor:UICOLOR_WHITE];
    [[UINavigationBar appearance]  setTitleTextAttributes:@{
                                                            NSFontAttributeName: [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_5],
                                                            NSForegroundColorAttributeName: WDCOLOR_BLACK_TITLE
                                                            }];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"NavBarShadow"]];
    UIImage *barBackBtnImg = [[UIImage imageNamed:@"NavBarPrevious"]  stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName : [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_5],
                                                           }];
    [[UINavigationBar appearance] setTintColor:WDCOLOR_BLUE];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5],
                                                           NSForegroundColorAttributeName: WDCOLOR_BLUE
                                                           } forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:WDCOLOR_BLUE];
    self.window.backgroundColor = WDCOLOR_BLACK;
    [self.window makeKeyAndVisible];
    
    /********************************* INIT *********************************/
    
    /********************************* INFO OPEN WHYD ******************************** TO REMOVE OT THE NEXT UPDATE*/
    //BOOL openWHydInfoDisplayed = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_OPENWHYD_INFO];
    //if(!openWHydInfoDisplayed){
    //    [WDAlertView showWithType:WDAlertTypeInfo title:NSLocalizedString(@"PopupOpenWhydTitle", nil) andInfoString:NSLocalizedString(@"PopupOpenWhydMessage", nil)];
    //   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULT_OPENWHYD_INFO];
    //   [[NSUserDefaults standardUserDefaults] synchronize];
    //}
    
    
    [[WDPlayerManager manager] setDelegate:[MainViewController manager]];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    
    //NOTIF IF APP CLOSED
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [WDHelper apnPushed:userInfo withApplicationState:application.applicationState];
    }
   
    if ([WDHelper manager].currentUser) {
        [Activity refreshNotificationsHistoryAndRead:NO success:nil];
         DLog(@"CURRENT USER %@", [WDHelper manager].currentUser);

    }
    
    //UPDATE
    
    [WDHelper checkIfNeedUpdate:^(NSString *version) {
        if (version) {
            [WDAlertView showWithType:WDAlertTypeUpdate andInfoString:version];
        }
    } failure:^(NSError *error) {
        
    }];

    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}


- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                [[WDPlayerManager manager] play];
                break;
            case UIEventSubtypeRemoteControlPause:
                //[self.player pause];
                [[WDPlayerManager manager] pause];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[WDPlayerManager manager] togglePlayPause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[WDPlayerManager manager] actionNext];
                
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[WDPlayerManager manager] actionPrev];
                
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                DLog(@"BEGIN BACK____UIEventSubtypeRemoteControlBeginSeekingBackward");
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                DLog(@"END BACK____UIEventSubtypeRemoteControlBeginSeekingBackward");
                
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                DLog(@"BEGIN FOWARD____UIEventSubtypeRemoteControlBeginSeekingBackward");
                
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
                DLog(@"BEGIN FOWARD ____UIEventSubtypeRemoteControlBeginSeekingBackward");
                
                break;
                
            default:
                break;
        }
    }
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    DLog(@"!!!!!!!!!!!!!!MEMORY WARNING!!!!!!!!!!!!!");
}




- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {  return NO; }
    
    NSLog(@"url %@", url);

    if ([[url scheme] hasPrefix:@"whyd"])
    {


        if ([WDHelper manager].currentUser) {
            NSString *href = [url.query substringFromIndex:5];
            if(href)
            {
                [WDHelper openHref:href success:^(UIViewController *vc) {
                    WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
                    [nav.navigationBar setTranslucent:NO];
                    [[MainViewController manager].navigationController presentViewController:nav animated:YES completion:nil];
                }];
                return YES;
            }
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"AlertNotConnectedTitle", nil)
                                                            message: NSLocalizedString(@"AlertNotConnected", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        return NO;

     
    }
    else{
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
        
    };
    
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];

   
//    DLog(@"CURRENT USER %@ FOR TOKEN %@",[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_UID], dt );
//    NSLog(@"[WDHelper manager].currentUser  %@",[WDHelper manager].currentUser.id);
//    NSLog(@"[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_UID] %@",[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_UID] );
//    
    if([WDHelper manager].currentUser &&
        (![[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_UID] ||
       ![[WDHelper manager].currentUser.id isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_UID]]))
    {
        [[NSUserDefaults standardUserDefaults] setValue:[WDHelper manager].currentUser.id  forKey:USERDEFAULT_APN_UID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DLog(@"Send token: %@", deviceToken);
        
        //INIT NOTIF PUSH VALUE - ALL ACTIVED
        NSDictionary *pref = @{APN_PUSH_SUBSCRIPTION : @"0",
                               APN_PUSH_ADDYOURTRACK : @"0",
                               APN_PUSH_LIKE : @"0",
                               APN_PUSH_MENTIONN : @"0",
                               APN_PUSH_COMMENT : @"0",
                               APN_PUSH_ACCEPT : @"0",
                               APN_PUSH_FBFRIENDSUBCRIBED : @"0",
                               APN_PUSH_SEND_TRACK : @"0",
                               APN_PUSH_SEND_PLAYLIST : @"0",
                               };
        
        NSData *prefData = [NSJSONSerialization dataWithJSONObject:pref options:0 error:nil];

        NSDictionary *parameters = @{@"apTok": dt,
                                     @"pref" : [NSJSONSerialization JSONObjectWithData:prefData options:0 error:nil]};
   
        [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"TOKEN SAVED ");
            [User saveAsCurrentUserFromDictionary:responseObject];

            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_APN_TOKEN_UPDATED object:nil];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"TOKEN SAVED Error: %@", error);
        }];
        

    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	DLog(@"Failed to get token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

    [Activity refreshNotificationsHistoryAndRead:NO success:nil];

    if(application.applicationState == UIApplicationStateActive)
    {
        NSString *message = [NSString stringWithFormat:@"%@",[userInfo valueForKeyPath:@"aps.alert"]];
        
        
        [WDMessage showMessage:message inView:[MainViewController manager].view withTopMargin:YES withBackgroundColor:WDCOLOR_BLACK callback:^{
            [WDHelper apnPushed:userInfo withApplicationState:application.applicationState];
        }];

    }
    else
    {
         [WDHelper apnPushed:userInfo withApplicationState:application.applicationState];
    }
            
    
}



@end
