//
//  CommentsViewController.h
//  Whyd
//
//  Created by Damien Romito on 24/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTrack.h"
#import "WDRootTableViewController.h"
#import "HPGrowingTextView.h"
#import "CommentCell.h"
#import "SWTableViewCell.h"


@interface CommentsViewController : WDRootTableViewController<HPGrowingTextViewDelegate, UITextViewDelegate, CommentCellDelegate, SWTableViewCellDelegate>

@property (nonatomic, strong) WDTrack *track;
@property (nonatomic) BOOL needToBeUpdated;
@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL editMode;

@end

