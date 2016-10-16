//
//  SettingsViewController.m
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsViewController.h"
#import "WDLabel.h"
#import "SettingsEmailViewController.h"
#import "SettingsPasswordViewController.h"
#import "MainViewController.h"
#import "SettingsCell.h"
#import "WDHelper.h"

@interface SettingsViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) NSArray *settingsArray;


@end

@implementation SettingsViewController


- (void)loadView
{
    [super loadView];
    
    self.title = NSLocalizedString(@"SettingsTitle", nil);
    self.view.backgroundColor = WDCOLOR_WHITE;
    
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingsIconClose"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss)];

    
    
    self.settingsArray = @[
                           @{@"title" : NSLocalizedString(@"SettingsSectionInformation", nil),
                             @"rows" :
                               @[
                                   @{@"title" : NSLocalizedString(@"SettingsChangeEmail", nil),
                                     @"className" : @"SettingsEmailViewController"},
                                   @{@"title" : NSLocalizedString(@"SettingsChangePassword", nil),
                                     @"className" : @"SettingsPasswordViewController"},
                                   ]
                              },
                           
                              @{@"title" : NSLocalizedString(@"SettingsSectionPreferences", nil),
                                   @"rows" :
                                       @[
                                           @{@"title" : NSLocalizedString(@"SettingsSectionNotifications", nil),
                                             @"className" : @"SettingsNotificationsViewController"},
                                           @{@"title" : NSLocalizedString(@"SettingsSectionSharing", nil),
                                             @"className" : @"SettingsSharingViewController"},
                                           ]
                                }
                            ];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = WDCOLOR_GRAY_BORDER_LIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 75)];
    UIButton* logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 46)];
    [logoutButton setTitle:NSLocalizedString(@"SettingsSignout", nil) forState:UIControlStateNormal];
    logoutButton.backgroundColor = UICOLOR_WHITE;
    logoutButton.titleEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    logoutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [logoutButton setTitleColor:WDCOLOR_BLUE_DARK forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_4];
    [logoutButton addTarget:self action:@selector(actionLogout) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutButton];
    self.tableView.tableFooterView = footerView;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.frame;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,300);
    
}

#pragma -mark ACITONS

- (void)actionLogout
{

    [self dismissViewControllerAnimated:YES completion:^{
        
        [[MainViewController manager] actionLogout];

        [WDHelper runAfterDelay:1 block:^{
            [[MainViewController manager].menuView actionClose];
            [[MainViewController manager] displayViewControllerAtIndex:0];
            [[MainViewController manager].menuView selectButtonAtIndex:0];
        }];

    }];


}

- (void)actionDismiss
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}

#pragma mark Default TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    WDLabel *headerView = [[WDLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.text = [[[self.settingsArray objectAtIndex:section] valueForKey:@"title"] uppercaseString];
    headerView.edgeInsets = UIEdgeInsetsMake(24, 11, 0, 0);
    headerView.textColor = WDCOLOR_GRAY_DARK;
    headerView.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = (NSArray *)[[self.settingsArray objectAtIndex:section] valueForKey:@"rows"];
    return sectionArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"SettingsCell";
    
    SettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[SettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *sectionArray = (NSArray *)[[self.settingsArray objectAtIndex:indexPath.section] valueForKey:@"rows"];

    cell.textLabel.text = [[sectionArray objectAtIndex:indexPath.row] valueForKey:@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *classString = [[[[self.settingsArray objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex:indexPath.row] valueForKey:@"className"];
    [self.navigationController pushViewController:[[NSClassFromString(classString) alloc] init] animated:YES];
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING SEARCH");
    [super didReceiveMemoryWarning];
}


@end
