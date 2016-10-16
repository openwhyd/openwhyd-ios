//
//  HotTracksCell.h
//  Whyd
//
//  Created by Damien Romito on 26/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Genre.h"

@interface GenreCell : UITableViewCell

@property (nonatomic, strong) Genre *genre;

- (void)stateSelected:(BOOL)selected;

@end
