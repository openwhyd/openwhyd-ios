//
//  WDFacebookHelper.m
//  Whyd
//
//  Created by Damien Romito on 30/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDFacebookHelper.h"
#import "WDClient.h"
#import "WDHelper.h"

static const NSString *FACEBBOK_APP_NAME = @"whydapp";

@interface WDFacebookHelper()//<FBSDKSharingDelegate>
//@property (copy)void (^accountSelectedFailure)();
@property (nonatomic, weak) id delegate;
@end
@implementation WDFacebookHelper


+ (WDFacebookHelper *)manager {
    
    static WDFacebookHelper *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}


+(void)shareTrack:(WDTrack*)track
{

    [WDFacebookHelper isReadyToPost:^{
        
      
        
        FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
        action.actionType = @"whydapp:add";
        [action setString:[track url] forKey:@"track"];
        FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
        content.action = action;
        content.previewPropertyName = @"track";
        FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
        shareAPI.shareContent = content;
        [shareAPI share];

    }];
    
        
  


    
}




+ (void)loginInViewController:(UIViewController *)viewController success:(void (^)())success failure:(void (^)(NSError *error, User *user))failure
{
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    manager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    
    [manager logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error) {
             failure (error, nil);
        }else{
            
            if (result.isCancelled) {
                failure(nil,nil);
            }else{
                NSDictionary *parameters = @{@"fbUid": result.token.userID,
                                             @"fbAccessToken":[FBSDKAccessToken currentAccessToken].tokenString};
                [WDHelper loginWithParameters:parameters success:^{
                    success();
                } failure:^(NSError *error) {
                    
                    NSDictionary *fbUser = [error.userInfo valueForKey:@"fbUser"];

                    if (fbUser) {
                        User *newUser = [User new];
                        newUser.name = [fbUser valueForKey:@"name"];
                        newUser.handle = [fbUser valueForKey:@"first_name"];
                        newUser.email = [fbUser valueForKey:@"email"];
                        newUser.fbId = [parameters valueForKeyPath:@"fbUid"];
                        newUser.fbTok = [parameters valueForKey:@"fbAccessToken"];
                        failure (error, newUser);
                    }else{
                        [FBSDKAccessToken setCurrentAccessToken:nil];
                        [FBSDKProfile setCurrentProfile:nil];
                        failure(error,nil);
                    }
                                       
                }];
            }
     
            
        }
    }];
    
}

+ (BOOL)checkPermissions:(NSArray *)permissions
{
    for (NSString * permission in permissions) {
        if (![[FBSDKAccessToken currentAccessToken].permissions containsObject:permission])
        {
            return NO;
        }
    }
    return YES;
}

+ (void)isReadyToPost:(void (^)())success
{
    DLog(@"TOKEN %@",[FBSDKAccessToken currentAccessToken]);

    if ([WDFacebookHelper checkAccessToken]
        && [WDFacebookHelper checkPermissions:@[@"publish_actions"]]) {
        DLog(@"PERMISION %@",[FBSDKAccessToken currentAccessToken].permissions);
        dispatch_async(dispatch_get_main_queue(), ^{
           success();
        });
    }else{
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        manager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
        [manager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:[[[UIApplication sharedApplication]delegate] window].rootViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [[WDHelper manager].currentUser setFbTok:[FBSDKAccessToken currentAccessToken].tokenString];
            [[WDHelper manager].currentUser setFbId:[FBSDKAccessToken currentAccessToken].userID];
            success();
        }];
    }

    
}

//+(void)unlinkAccount
//{
//    
//      [[[FBSDKLoginManager alloc] init] logOut];
//    NSDictionary *parameters = @{@"fbId"  : @""};
//    
//    [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//        DLog(@"Unlinked %@",responseObject);
//        if ([responseObject valueForKey:@"ok"]) {
//            [WDHelper manager].currentUser.fbTok = @"";
//            [[[FBSDKLoginManager alloc] init] logOut];
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_AUTOSHARE_FB];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//    }];
//}
//


+ (void)linkAccount:(void (^)(NSString *username))success failure:(void(^)(NSError *error))failure
{
    
    
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    manager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [manager logInWithReadPermissions:@[@"public_profile"] fromViewController:[[[UIApplication sharedApplication]delegate] window].rootViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {


        if (!error) {
            
            [manager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:[[[UIApplication sharedApplication]delegate] window].rootViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
               
                
                if ([WDHelper manager].currentUser.fbId &&
                    [[WDHelper manager].currentUser.fbId isEqualToString:[FBSDKAccessToken currentAccessToken].userID]) {
                        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                             if (!error) {
                                  success(result[@"name"]);
                             }
                         }];
                }else{
                    NSDictionary *parameters = @{@"fbUid": [FBSDKAccessToken currentAccessToken].userID,
                                                 @"fbAccessToken":[FBSDKAccessToken currentAccessToken].tokenString};
                    
                    [[WDClient client] GET:API_LINK_FACEBOOK parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        
                        // DLog(@"responseObject %@", responseObject);
                        
                        if ([responseObject objectForKey:@"error"]) {
                            NSDictionary * userInfo = @{ NSLocalizedDescriptionKey :NSLocalizedString(@"ErrorFacebookAlreadyUse", nil),
                                                         @"Title" : NSLocalizedString(@"ErrorFacebookAlreadyUseTitle", nil)};
                            NSError *error = [NSError errorWithDomain:API_BASE_URL code:0 userInfo:userInfo];
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                failure(error);
                                [[[FBSDKLoginManager alloc] init] logOut];
                            });
                        }else
                        {
                            
                            User *user = [User saveAsCurrentUserFromDictionary:responseObject];
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                success(user.name);
                            });
                            
                        }
                        
                        
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        DLog(@"error %@", error);
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            failure(error);
                            [[[FBSDKLoginManager alloc] init] logOut];
                        });
                    }];
                }
              
                
            }];
            
        }else{
            
        }
        
       
    }];

    
}

+ (BOOL)checkAccessToken
{

    return ([FBSDKAccessToken currentAccessToken]
            && [[WDHelper manager].currentUser.fbId isEqualToString:[FBSDKAccessToken currentAccessToken].userID]);
}



@end
