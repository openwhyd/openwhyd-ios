//
//  SearchViewController.h
//  Whyd
//
//  Created by Damien Romito on 11/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDSearchEngines.h"
#import "TrackSearchCell.h"
#import "SearchTableViewController.h"

@interface SearchViewController : SearchTableViewController<UISearchBarDelegate, WDSearchEnginesDelegate, UIScrollViewDelegate>


@end