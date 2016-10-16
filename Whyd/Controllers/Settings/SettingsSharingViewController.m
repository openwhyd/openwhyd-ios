//
//  SettingsSharingViewController.m
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsSharingViewController.h"
#import "WDActivityIndicatorView.h"
#import "SettingsSharingCell.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "WDClient.h"
#import "WDFacebookHelper.h"

#import "WDTwitterHelper.h"
#import "User.h"
#import "WDHelper.h"
#import <Social/Social.h>

@interface SettingsSharingViewController ()
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSArray *accountsArray;
@property (nonatomic, strong) NSString *fbName;
@property (nonatomic, strong) NSString *twName;
@end

@implementation SettingsSharingViewController


- (void)loadView
{
    [super loadView];
    
    self.title = [NSLocalizedString(@"SettingsShareTitle", nil) uppercaseString];
   
    
    self.accountsArray = @[
                                @{@"title" : NSLocalizedString(@"SettingsShareFacebook", nil),
                                  @"image" : @"SettingSharingIconFacebook",
                                  },
                                @{@"title" :  NSLocalizedString(@"SettingsShareTwitter", nil),
                                  @"image" : @"SettingSharingIconTwitter",
                                  },
                                ];

    ///FACEBOOK
    DLog(@"IS LOGGED %i", [WDFacebookHelper checkAccessToken]);
    
    if([WDFacebookHelper checkAccessToken] && [WDFacebookHelper checkPermissions:@[@"publish_actions"]]) {
        self.fbName = @"...";
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 self.fbName = result[@"name"];
                 [self.tableView reloadData];
             }
         }];
    

    }
  

    //TWITTER
    BOOL isLogged = [WDTwitterHelper isLogged:^(ACAccount *account) {
        self.twName = account.username;
        [self.tableView reloadData];
    }];
    if (isLogged) {
        self.twName = @"...";
    }
    
    
    
    [self.tableView  reloadData];
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];


}



#pragma mark Default TableView Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accountsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier;
    if (indexPath.row == SharingTypeFacebook) {
        CellIdentifier = @"SettingsSharingCellF";
    }else if (indexPath.row == SharingTypeTwitter)
    {
        CellIdentifier = @"SettingsSharingCellT";

    }
    
    SettingsSharingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[SettingsSharingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withSharingType:indexPath.row];
    }


    switch (indexPath.row) {
        case SharingTypeFacebook:{
            
            if (self.fbName) {
                cell.detailTextLabel.text = self.fbName;
                cell.textLabel.text = @"Facebook";
                cell.accessoryView = nil;
            }else
            {
                cell.detailTextLabel.text = @"";
                cell.textLabel.text = NSLocalizedString(@"SettingsShareFacebook", nil);
            }
        }
            break;
            
        case SharingTypeTwitter:{
            
            if (self.twName) {
                cell.detailTextLabel.text = self.twName;
                cell.textLabel.text = @"Twitter";
                cell.accessoryView = nil;
                
            }else
            {
                cell.detailTextLabel.text = @"";
                cell.textLabel.text = NSLocalizedString(@"SettingsShareTwitter", nil);
            }
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case SharingTypeFacebook:{
            
            if(![WDFacebookHelper checkAccessToken]) {
                DLog(@"Facebook not connected");
                [self.loadingView startAnimating];
             
                [WDFacebookHelper linkAccount:^(NSString *username) {
                    self.fbName = username;
                    [self.tableView reloadData];
                    [self.loadingView stopAnimating];
                } failure:^(NSError *error) {
                    [self alertWithTitle:error.userInfo[@"Title"]  andMessage:error.localizedDescription];
                    [self.tableView reloadData];
                    [self.loadingView stopAnimating];
                }];
                
            }
            else if (![WDFacebookHelper checkPermissions:@[@"publish_actions"]])
            {
                
                FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
                manager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
                
                [manager logInWithReadPermissions:@[@"publish_actions"] fromViewController:[[[UIApplication sharedApplication]delegate] window].rootViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    
                    if (error) {
                    }
                    
                }];


    
            }else
            {
                DLog(@"Already Connected");
            }
            
        }break;
        case SharingTypeTwitter:{
            
            [self.loadingView startAnimating];
            [[WDTwitterHelper manager] selectAccountInView:self.view success:^(NSString* username) {
                self.twName = [NSString stringWithFormat:@"@%@", username ];
                [self.tableView reloadData];
                [self.loadingView stopAnimating];
            } failure:^(NSError *error) {
                if (error) {
                    [self alertWithTitle:error.userInfo[@"Title"]  andMessage:error.localizedDescription];
                    [self.tableView reloadData];
                }
                [self.loadingView stopAnimating];

            }];
        }
            
            break;
    }

}




- (void)alertWithTitle:(NSString*)title andMessage:(NSString*)message
{
    [self.loadingView stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    [alert show];
}

@end
