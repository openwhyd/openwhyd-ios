//
//  UsersViewController.m
//  Whyd
//
//  Created by Damien Romito on 07/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "UsersViewController.h"
#import "UserCell.h"
#import "UserViewController.h"

static NSString * const NB_ITEMS_LIMIT = @"40";


@interface UsersViewController ()
@property (nonatomic, strong) NSArray *users;
@end

@implementation UsersViewController

- (void)loadView
{

    [super loadView];
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];

 
    self.hasFollowButtons = YES;
    [self.parameters setObject:NB_ITEMS_LIMIT forKey:@"limit"];
    
    self.tableView.separatorColor =  WDCOLOR_GRAY_BORDER_LIGHT;
    [self reload];
}

- (void)successResponse:(id)responseObject
{
    NSMutableArray *users = [[NSMutableArray alloc] init];//WithCapacity:[responseObject count]

    for (NSDictionary *u in responseObject) {
        User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:u error:nil];
        [users addObject:user];
    }

    
    
    //CREATION
    if (![self.parameters valueForKey:PARAMETER_SKIP]) {
        self.users =  users;
    }
    //LOAD MORE
    else
    {
        NSMutableArray *mArray= [NSMutableArray arrayWithArray:self.users];
        [mArray addObjectsFromArray:users];
        self.users = mArray;
    }
    
    ///LOAD MORE?
    if (users.count < [NB_ITEMS_LIMIT intValue]) {
        self.loadMoreEnable = NO;
        self.tableView.tableFooterView = [UIView new];
    }else
    {
        self.loadMoreEnable = YES;
    }
    
    
    [super successResponse:responseObject];
}

- (void)loadMore
{
    [self.parameters setValue:[NSNumber numberWithInt:(int)self.users.count] forKey:PARAMETER_SKIP];
    [super loadMore];
}


#pragma mark TableView Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //USERS
    static NSString* CellIdentifierUser = @"UserCell";
    UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierUser];
    
    if (cell == nil)
    {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierUser];
    }
    User *user = [self.users objectAtIndex:indexPath.row];
    cell.user = user;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserViewController *vc = [[UserViewController alloc] initWithUser:[self.users objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
