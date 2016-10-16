//
//  WDUserPickerViewController.h
//  Whyd
//
//  Created by Damien Romito on 08/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//


#import "THContactPickerView.h"
#import "WDTrack.h"

@interface WDUserPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, readonly) NSArray *selectedContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredContacts;


+ (instancetype)pickerWithTrack:(WDTrack*)track;
+ (instancetype)pickerWithPlaylist:(Playlist*)playlist;
- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
