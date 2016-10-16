//
//  SettingsNotificationsViewController.m
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsNotificationsViewController.h"
#import "SettingsNotificationsCell.h"
#import "WDHelper.h"
#import "WDActivityIndicatorView.h"

@interface SettingsNotificationsViewController ()<SettingsNotificationCellDelegate>
@property (nonatomic, strong) NSArray *notificationsArray;
@property (nonatomic, strong) NSMutableDictionary *preferences;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;
@end

@implementation SettingsNotificationsViewController
- (void)loadView
{
    [super loadView];
    
    self.title = @"NOTIFICATIONS";
   
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SettingsSave", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionSave)];

    
    self.notificationsArray = @[
                           @{@"title" : NSLocalizedString(@"SettingsNotifSubscription", nil) ,
                             @"key_email" : APN_EMAIL_SUBSCRIPTION,
                             @"key_push" : APN_PUSH_SUBSCRIPTION
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifAdd", nil),
                             @"key_email" : APN_EMAIL_ADDYOURTRACK,
                             @"key_push" : APN_PUSH_ADDYOURTRACK
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifLike", nil),
                             @"key_email" : APN_EMAIL_LIKE,
                             @"key_push" : APN_PUSH_LIKE
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifMention", nil),
                             @"key_email" : APN_EMAIL_MENTION,
                             @"key_push" : APN_PUSH_MENTIONN
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifComment", nil),
                             @"key_email" : APN_EMAIL_COMMENT,
                             @"key_push" : APN_PUSH_COMMENT
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifFriend", nil),
                             @"key_email" : APN_EMAIL_FBFRIENDSUBCRIBED,
                             @"key_push" : APN_PUSH_FBFRIENDSUBCRIBED
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifAcceptation", nil),
                             @"key_email" : APN_EMAIL_ACCEPT,
                             @"key_push" : APN_PUSH_ACCEPT
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifReceiveTrack", nil),
                             @"key_push" : APN_PUSH_SEND_TRACK
                             },
                           @{@"title" :  NSLocalizedString(@"SettingsNotifReceivePlaylist", nil),
                             @"key_push" : APN_PUSH_SEND_PLAYLIST
                             },
                           
                           ];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    self.tableView.tableHeaderView = headerView;
    
    self.preferences = [[NSMutableDictionary alloc] init];
    
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];

}

- (void)actionSave
{
    if (self.preferences.count) {
        
        [self.loadingView startAnimating];
        
        NSData *pref = [NSJSONSerialization dataWithJSONObject:self.preferences options:0 error:nil];
        NSDictionary *parameters = @{@"pref" : [NSJSONSerialization JSONObjectWithData:pref options:0 error:nil]};
        
        [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.loadingView stopAnimating];
            //DLog(@"responseObject Error: %@", responseObject);
            
            if ([responseObject valueForKey:@"error"]) {
                //[self actionErrorWithText:[responseObject valueForKey:@"error"]];
            }else
            {

                User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:nil];
                [User saveAsCurrentUser:user];
                [self.navigationController popToRootViewControllerAnimated:YES];

            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Operation Error: %@", error);
            [self.loadingView stopAnimating];
            
            
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"SettingsNotifAlertTitle", nil)
                                                        message:NSLocalizedString(@"SettingsNotifAlertMessage", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark Default TableView Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notificationsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"SettingsNotificationsCell";
    
    SettingsNotificationsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[SettingsNotificationsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    cell.textLabel.text = [[self.notificationsArray objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.delegate = self;
    
    NSString *prefEmail = [[self.notificationsArray objectAtIndex:indexPath.row] valueForKey:@"key_email"];
    
    if(prefEmail)
    {
        BOOL hasEmail = ([[[WDHelper manager].currentUser.pref valueForKey:prefEmail] intValue] == -1)?NO:YES;
        [cell hasEmail:hasEmail forKey:prefEmail];
    }


    
    NSString *prefPush = [[self.notificationsArray objectAtIndex:indexPath.row] valueForKey:@"key_push"];
    BOOL hasPush = ([[[WDHelper manager].currentUser.pref valueForKey:prefPush] intValue] == -1)?NO:YES;
    [cell hasPush:hasPush forKey:prefPush];
    
    DLog(@"pref  %@ = %@  -  %@ = %@",prefEmail,[[WDHelper manager].currentUser.pref valueForKey:prefEmail], prefPush, [[WDHelper manager].currentUser.pref valueForKey:prefPush] );

    
    return cell;
}


- (void)notificationApnTokenUpdated
{
    [self.loadingView stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView reloadData];

}
#pragma SettingsNotificationCellDelegate


- (void)settingsNotifsKey:(NSString *)key isActive:(BOOL)isActive
{

    NSString *value = (isActive)?@"0":@"-1";
    [self.preferences setValue:value forKeyPath:key];
  
}

- (void)settingsActiveAPN
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationApnTokenUpdated) name:NOTIFICATION_APN_TOKEN_UPDATED object:nil];
    [WDHelper apnSet];
    [self.loadingView startAnimating];
}




@end
