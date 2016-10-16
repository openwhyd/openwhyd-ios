//
//  CommentDetailCell.h
//  Whyd
//
//  Created by Damien Romito on 19/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "OHAttributedLabel.h"
#import "SWTableViewCell.h"

@interface CommentCell : SWTableViewCell<OHAttributedLabelDelegate>

@property (nonatomic, strong) Comment *comment;
@property (nonatomic, weak) id commentDelegate;


- (void)sendingFail;

@end


@protocol CommentCellDelegate <NSObject>

- (void) sendComment:(Comment *)comment;
- (void)commentCell:(CommentCell *)cell openUser:(User *)user;
@end
