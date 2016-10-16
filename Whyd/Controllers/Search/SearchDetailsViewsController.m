//
//  SearchDetailsViewsController.m
//  Whyd
//
//  Created by Damien Romito on 22/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SearchDetailsViewsController.h"


@interface SearchDetailsViewsController()

@end

@implementation SearchDetailsViewsController


- (void)loadView
{
    [super loadView];
    
    [self.tableView reloadData];

 
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = 0;
    switch (self.searchType) {
        case SearchTypeTrack:
            height = 60;
            break;
        case SearchTypePlaylist:
            height = 60;
            break;
        case SearchTypeUser:
            height = 55;
            break;
        default:
            break;
            
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    return self.resultsArray.count;
    
}




@end