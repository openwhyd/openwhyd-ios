//
//  NotificationsViewController.m
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "NotificationsViewController.h"
#import "Activity.h"
#import "UIViewController+WD.h"
#import "OHAttributedLabel.h"
#import "WDHelper.h"
#import "TrackViewController.h"
#import "UserViewController.h"
#import "PlaylistViewController.h"

@interface NotificationsViewController ()<NotificationCellDelegate>
@property (nonatomic, strong) NSArray *notifications;
@end

@implementation NotificationsViewController


- (void)loadView
{
    
    [super loadView];

    self.title = [NSLocalizedString(@"Notifications", nil) uppercaseString];
    self.tableView.separatorColor = RGBCOLOR(237, 240, 243);
    self.tableView.tableFooterView = [UIView new];
    [self reload];
    [self makeAsMainViewController];
}


- (void)reload
{

    [Activity refreshNotificationsHistoryAndRead:YES success:^(NSArray *notifications) {
        
        self.notifications = notifications;
        [super successResponse:nil];
        
        if (self.notifications.count) {
            [self actionAskAPN];
        }else
        {
            [self placeholderWithImageName:@"NotificationIconNoNotification" text:NSLocalizedString(@"NoNotificationsYet", nil)];
            
        }
    }];
    [super reload];
}



#pragma -mark Actions

- (void)actionAskAPN
{
    if (![WDHelper apnIsAlreadyAsked] && [WDHelper manager].currentUser.nbPosts && ![[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_APN_LIKES_ASKED])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_APN_LIKES_ASKED];
        
        UIView *notifyView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 320, 196)];
        
        UIImageView *illustrationImage =  [[UIImageView alloc] initWithFrame:CGRectMake(144, 24, 29, 39)];
        illustrationImage.image = [UIImage imageNamed:@"NotificationMessageIconSmarphone"];
        [notifyView addSubview:illustrationImage];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 75, 240, 50)];
        label.text = NSLocalizedString(@"WouldYouLikeToBeAlertedWhenSomeoneLikesYourTrack", nil);
        label.textColor = WDCOLOR_BLUE_DARK;
        label.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_5];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [notifyView addSubview:label];
        
        UIButton *noButton = [[UIButton alloc] initWithFrame:CGRectMake(58, 140, 94, 34)];
        noButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        [noButton setTitleColor:WDCOLOR_GRAY_DARK forState:UIControlStateNormal];
        noButton.layer.borderColor = WDCOLOR_GRAY_LIGHT.CGColor;
        noButton.layer.borderWidth = 1;
        noButton.layer.cornerRadius = CORNER_RADIUS;
        [noButton setTitle:NSLocalizedString(@"NoThanks", nil) forState:UIControlStateNormal];
        [noButton addTarget:self action:@selector(actionRefuseAPN) forControlEvents:UIControlEventTouchUpInside];
        [notifyView addSubview:noButton];
        
        UIButton *yesButton = [[UIButton alloc] initWithFrame:CGRectMake(165, 140, 94, 34)];
        [yesButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
        yesButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        yesButton.backgroundColor = WDCOLOR_BLUE;
        yesButton.layer.cornerRadius = CORNER_RADIUS;
        yesButton.clipsToBounds = YES;
        [yesButton setTitle:NSLocalizedString(@"NotifyMe", nil) forState:UIControlStateNormal];
        [yesButton addTarget:self action:@selector(actionAcceptAPN) forControlEvents:UIControlEventTouchUpInside];
        [notifyView addSubview:yesButton];
        
        UIView *container = [UIView new];
        container.backgroundColor = WDCOLOR_WHITE;
        CGRect frame = notifyView.frame;
        frame.origin.x = 0 ;
        frame.size.width = self.view.frame.size.width;
        container.frame = frame;
        
        [container addSubview:notifyView];
        
        self.tableView.tableHeaderView = container;
    }
}
- (void)actionRefuseAPN
{
    [Flurry logEvent:FLURRY_ALLOWNOTIF_NOTIF_NO];
    self.tableView.tableHeaderView = nil;
    
}

- (void)actionAcceptAPN
{
    [WDHelper apnSet];
    self.tableView.tableHeaderView = nil;
}

#pragma mark TableView Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Activity* activity = [self.notifications objectAtIndex:indexPath.row];
    return [Activity heightForText:activity];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notifications.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //USERS
    static NSString* CellIdentifierUser = @"UserCell";
    NotificationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierUser];
    
    if (cell == nil)
    {
        cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierUser];
    }
    
    Activity *activity = [self.notifications objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell setActivity:activity];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell * cell = (NotificationCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    
    if (cell.activity.activityType == ActivityTypeReco) {

        [WDHelper openHref:cell.activity.href success:^(UIViewController *vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
    }else if ([cell.activity.href hasPrefix:@"/c"])
    {
        TrackViewController *vc = [[TrackViewController alloc] init];
        
        if (cell.activity.playlist) {
            vc.track = cell.activity.track;
            vc.playlist = cell.activity.playlist;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else
        {
            [self.loadingView startAnimating];
            
            [[WDClient client] GET:API_TRACK_INFO(cell.activity.track.id) parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                vc.track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:[responseObject objectForKey:@"data"]  error:nil];
                vc.playlist = [Playlist new];
                vc.playlist.name = NSLocalizedString(@"Notifications", nil);
                vc.playlist.tracks = [NSArray arrayWithObject:vc.track];
                cell.activity.track = vc.track;
                cell.activity.playlist = vc.playlist;
                
                [self.loadingView stopAnimating];
                [self.navigationController pushViewController:vc animated:YES];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
            }];
        }

    }else if ([cell.activity.href rangeOfString:@"playlist"].location != NSNotFound)
    {

        if (cell.activity.playlist) {
            PlaylistViewController *vc = [[PlaylistViewController alloc] initWithPlaylist:cell.activity.playlist];
            [self.navigationController pushViewController:vc animated:YES];
        }else
        {
            [self.loadingView startAnimating];
            
            [Playlist playlistFromHref:cell.activity.href success:^(Playlist *playlist) {
                cell.activity.playlist = playlist;
                PlaylistViewController *vc = [[PlaylistViewController alloc] initWithPlaylist:playlist];
                [self.loadingView stopAnimating];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }

        
    }else if([cell.activity.href hasPrefix:@"/u"])
    {
        UserViewController *vc = [[UserViewController alloc] initWithUser:cell.activity.lastAuthor success:^(User *user) {
            cell.activity.lastAuthor = user;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    

    
}

- (void)notificationCell:(NotificationCell *)cell openUser:(User *)user
{
    UserViewController *vc = [[UserViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
