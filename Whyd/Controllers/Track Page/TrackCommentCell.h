//
//  CommentCell.h
//  Whyd
//
//  Created by Damien Romito on 24/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "OHAttributedLabel.h"


@interface TrackCommentCell : UITableViewCell

@property (nonatomic, strong) Comment *comment;
@property (nonatomic, weak) id delegate;

@end

@protocol TrackCommentCellDelegate <NSObject>

-(void)trackCommentCell:(TrackCommentCell *)cell openUser:(User *)user;

@end