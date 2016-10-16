//
//  GenresView.h
//  Whyd
//
//  Created by Damien Romito on 26/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Genre.h"
#import "WDBackgroundBlurView.h"

@interface GenresView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id delegate;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, weak) NSArray *genresArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WDBackgroundBlurView *backgroundView;

@end

@protocol GenresViewDelegate <NSObject>

- (void) pickGenre:(Genre *)genre;

@end
