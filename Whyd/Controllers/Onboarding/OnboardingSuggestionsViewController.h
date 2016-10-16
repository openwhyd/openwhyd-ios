//
//  OnboardingSuggestionsViewController.h
//  Whyd
//
//  Created by Damien Romito on 02/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingSuggestionsViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *uIdsToFollowed;

- (instancetype) initWithSuggestedUsers:(NSArray *)suggestedUsers;

@end
