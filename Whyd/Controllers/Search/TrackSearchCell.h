//
//  SearchTableViewCell.h
//  Whyd
//
//  Created by Damien Romito on 11/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTrack.h"

typedef NS_ENUM(NSUInteger, SearchCellType) {
    SearchCellTypeWhyd = 0,
    SearchCellTypeExternal = 1,
};

@interface TrackSearchCell : UITableViewCell

@property (nonatomic, strong) WDTrack* track;
@property (nonatomic, weak) id delegate;
@property (nonatomic) SearchCellType type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andType:(SearchCellType)searchCellType;

@end

@protocol TrackSearchCellDelegate <NSObject>

@optional

- (void)trackCellPlay:(TrackSearchCell *)cell;
- (void)trackCellAdd:(TrackSearchCell*)cell;
- (void)trackCellPlayUnaivailable;

@end