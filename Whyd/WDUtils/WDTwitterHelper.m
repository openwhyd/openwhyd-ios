//
//  WDTwitterHelper.m
//  Whyd
//
//  Created by Damien Romito on 02/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTwitterHelper.h"

#import "WDHelper.h"
#import "TWSignedRequest.h"
#import "OAuth+Additions.h"
#import <Accounts/Accounts.h>

typedef void(^TWAPIHandler)(NSData *data, NSError *error);

@interface WDTwitterHelper()<UIActionSheetDelegate>
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;
@property (copy)void (^accountSelected)();
@property (copy)void (^accountSelectedFailure)();
@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *authTokenSecret;
@end

@implementation WDTwitterHelper

+ (instancetype)manager
{
    static WDTwitterHelper *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)shareTrack:(WDTrack*)track
{
    NSString *tweetMessage;
    if (![track.text isEqualToString:@""]) {
        tweetMessage  = [NSString stringWithFormat:NSLocalizedString(@"ShareTwitterShareMessageWithComment", nil), track.text, [track url]];
    }else
    {
        tweetMessage  = [NSString stringWithFormat:NSLocalizedString(@"ShareTwitterShareMessage", nil), track.name, [track url]];
    }
    
    NSDictionary *parameters = @{@"status":tweetMessage};
    
    TWSignedRequest *step1Request = [[TWSignedRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"] parameters:parameters requestMethod:TWSignedRequestMethodPOST];
    
    step1Request.authToken = [WDHelper manager].currentUser.twTok;
    step1Request.authTokenSecret = [WDHelper manager].currentUser.twSec;
    [step1Request performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];

}



- (void)selectAccountInView:(UIView*)pickerContainer success:(void(^)(NSString *username))result failure:(void(^)(NSError *error))failure
{
    self.accountSelected = result;
    self.accountSelectedFailure = failure;

    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        
        if (!granted)
        {
            NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"ErrorFacebookNErrorTwitterNotConnectedotLinked", nil) ,
                                         @"Title" : NSLocalizedString(@"ErrorTwitterNotConnectedTitle", nil)};
            NSError *error = [NSError errorWithDomain:API_BASE_URL code:0 userInfo:userInfo];
              [self failureBlockWithError:error];
        }
        else
        {
            self.accounts = [self.accountStore accountsWithAccountType:[self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
            
            if (self.accounts.count > 1)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"TwitterChooseAnAccount", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                    for (ACAccount *acct in self.accounts) {
                        [sheet addButtonWithTitle:acct.username];
                    }
                    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
                    [sheet showInView:pickerContainer];
                    
                });
            }
            else
            {
                [self addTwitterAccount:[self.accounts objectAtIndex:0]];
            }
        }

    }];
}


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self failureBlockWithError:nil];
}

- (void)failureBlockWithError:(NSError*)error
{
    if (!self.accountSelectedFailure) return;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.accountSelectedFailure(error);
        self.accountSelectedFailure = nil;
    });
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self addTwitterAccount:[self.accounts objectAtIndex:buttonIndex]];
    }
}


- (void) addTwitterAccount:(ACAccount*) account
{
    
    [self performReverseAuthForAccount:account withHandler:^(NSData *responseData, NSError *error) {

        if (responseData) {

            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            
            NSDictionary *dict = [NSURL ab_parseURLQueryString:responseStr];
            
            NSString *name =  [dict objectForKey:@"screen_name"];
            
            if (!name)
            {
                NSDictionary * userInfo = @{ NSLocalizedDescriptionKey :[NSString stringWithFormat:NSLocalizedString(@"ErrorTwitterAccountNoRecognize", nil), account.username ],
                                             @"Title" : NSLocalizedString(@"ErrorTwitterAccountNoRecognizeTitle", nil)};
                NSError *error = [NSError errorWithDomain:API_BASE_URL code:0 userInfo:userInfo];
                [self failureBlockWithError:error];

                return ;
            }
            
            NSDictionary *parameters = @{@"twId"  : [dict objectForKey:@"user_id"],
                                         @"twTok" : [dict objectForKey:@"oauth_token"],
                                         @"twSec" : [dict objectForKey:@"oauth_token_secret"]};
            
            DLog(@"_____parameters %@",parameters );


            
            [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                DLog(@"User %@",responseObject);

                if ([responseObject valueForKey:@"error"]) {
                    
                    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"ErrorTwitterAlreadyUse", nil) ,
                                                 @"Title" : NSLocalizedString(@"ErrorTwitterAlreadyUseTitle", nil)};
                    NSError *error = [NSError errorWithDomain:API_BASE_URL code:0 userInfo:userInfo];
                     [self failureBlockWithError:error];
                    return;
                    
                }else if([responseObject valueForKey:@"twId"])
                {
                    
                    [User saveAsCurrentUserFromDictionary:responseObject];
                    [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_AUTOSHARE_TW];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.accountSelected(account.username);
                         self.accountSelected = nil;
                     });
                }
                
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DLog(@"TOKEN SAVED Error: %@", error);
            }];
            
        }
        else {
            DLog(@"error");
        }
        
        
    }];
    
}


+ (void)unlinkAccount
{
    
     NSDictionary *parameters = @{@"twId"  : @""};
    
    [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"Unlinked %@",responseObject);
        if ([responseObject valueForKey:@"ok"]) {
            [WDHelper manager].currentUser.twId = @"";
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_AUTOSHARE_TW];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}



+ (BOOL)isLogged:(void(^)(ACAccount *account))success
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        if ([WDHelper manager].currentUser.twId) {
            
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSArray *accounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
                    for (ACAccount *a in accounts) {
                        if ([[WDHelper manager].currentUser.twId isEqualToString:[a valueForKeyPath:@"properties.user_id"]]) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                success(a);
                                
                            });
                            
                            
                        }
                    }
                    
                }
            }];
            return YES;
        }
        else
        {
            return NO;
        }
        
    }else
    {
        return NO;
    }
}


/**
 *  Returns a generic self-signing request that can be used to perform Twitter
 *  API requests.
 *
 *  @param  url             The URL of the endpoint to retrieve
 *  @param  dict            The API parameters to include with the request
 *  @param  requestMethod   The HTTP method to use
 */
- (SLRequest *)requestWithUrl:(NSURL *)url parameters:(NSDictionary *)dict requestMethod:(SLRequestMethod )requestMethod
{
    NSParameterAssert(url);
    NSParameterAssert(dict);
    
    return [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:requestMethod URL:url parameters:dict];
}

/**
 *  Performs Reverse Auth for the given account.
 *
 *  Responsible for dispatching the result of the call, either sucess or error.
 *
 *  @param account  The local account for which we wish to exchange tokens
 *  @param handler  The block to call upon completion. Will be called on the
 *                  main thread.
 */
- (void)performReverseAuthForAccount:(ACAccount *)account withHandler:(TWAPIHandler)handler
{
    NSParameterAssert(account);
    [self _step1WithCompletion:^(NSData *data, NSError *error) {
        
        if (!data) {

            dispatch_async(dispatch_get_main_queue(), ^{

                handler(nil, error);
            });
        }
        else {

            NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self _step2WithAccount:account signature:signedReverseAuthSignature andHandler:^(NSData *responseData, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    handler(responseData, error);
                });
            }];
        }
    }];
}

#define TW_API_ROOT                  @"https://api.twitter.com"
#define TW_X_AUTH_MODE_KEY           @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH  @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH   @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS      @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET     @"x_reverse_auth_target"
#define TW_OAUTH_URL_REQUEST_TOKEN   TW_API_ROOT "/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN      TW_API_ROOT "/oauth/access_token"

/**
 *  The second stage of Reverse Auth.
 *
 *  In this step, we send our signed authorization header to Twitter in a
 *  request that is signed by iOS.
 *
 *  @param account                      The local account for which we wish to exchange tokens
 *  @param signedReverseAuthSignature   The Authorization: header returned from
 *                                      a successful step 1
 *  @param completion                   The block to call when finished. Can be called on any
 *                                      thread.
 */
- (void)_step2WithAccount:(ACAccount *)account signature:(NSString *)signedReverseAuthSignature andHandler:(TWAPIHandler)completion
{
    NSParameterAssert(account);
    NSParameterAssert(signedReverseAuthSignature);
    
    NSDictionary *step2Params = @{TW_X_AUTH_REVERSE_TARGET: [TWSignedRequest consumerKey], TW_X_AUTH_REVERSE_PARMS: signedReverseAuthSignature};
    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
    SLRequest *step2Request = [self requestWithUrl:authTokenURL parameters:step2Params requestMethod:SLRequestMethodPOST];
    
    
    [step2Request setAccount:account];
    [step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(responseData, error);
            
            
            
            
        });
    }];
}

/**
 *  The first stage of Reverse Auth.
 *
 *  In this step, we sign and send a request to Twitter to obtain an
 *  Authorization: header which we will use in Step 2.
 *
 *  @param completion   The block to call when finished. Can be called on any thread.
 */
- (void)_step1WithCompletion:(TWAPIHandler)completion
{
    NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
    NSDictionary *dict = @{TW_X_AUTH_MODE_KEY: TW_X_AUTH_MODE_REVERSE_AUTH};
    TWSignedRequest *step1Request = [[TWSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TWSignedRequestMethodPOST];
    
    
    [step1Request performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(data, error);
        });
    }];
}




@end
