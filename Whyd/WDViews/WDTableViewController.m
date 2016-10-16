//
//  WDTableViewController.m
//  Whyd
//
//  Created by Damien Romito on 08/10/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTableViewController.h"

@implementation WDTableViewController


- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = WDCOLOR_WHITE;
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = WDCOLOR_GRAY_BORDER_LIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING WDTABLEVIEW");
    [super didReceiveMemoryWarning];
}

@end
