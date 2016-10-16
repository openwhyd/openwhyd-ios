//
//  CommentsViewController.m
//  Whyd
//
//  Created by Damien Romito on 24/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "CommentsViewController.h"
#import "WDHelper.h"
#import "UserViewController.h"


@interface CommentsViewController ()
@property (nonatomic, strong) HPGrowingTextView *commentTextView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic) NSUInteger indexToDelete;

@end

static CGFloat const COMMENT_VIEW_HEIGHT = 44;

@implementation CommentsViewController

- (void)loadView
{
    [super loadView];

    self.urlString = API_TRACK_INFO(self.track.id);

    self.title = [NSLocalizedString(@"Comment", nil) uppercaseString];

    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = UICOLOR_WHITE;
    

    self.inputView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height - 44, self.view.frame.size.width + 2, COMMENT_VIEW_HEIGHT +1)];
    self.inputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.inputView.backgroundColor = WDCOLOR_GRAY_BG_LIGHT;
    self.inputView.layer.borderColor = WDCOLOR_GRAY_BORDER.CGColor;
    self.inputView.layer.borderWidth = 1;
    [self.view addSubview:self.inputView];
    
    UIButton *sendButton = [[UIButton alloc] init];
    [sendButton setTitle:[NSLocalizedString(@"Send", nil) uppercaseString] forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5];
    sendButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 7);
    [sendButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(actionSend) forControlEvents:UIControlEventTouchUpInside];
    [sendButton sizeToFit];
    CGRect frame = sendButton.frame;
    frame.size.height = 44;
    frame.size.width += 20;
    frame.origin.x = self.view.frame.size.width - frame.size.width;
    sendButton.frame = frame;
//    CGRectMake(250, 0 , 65, 44)
    [self.inputView addSubview:sendButton];
    
    self.commentTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(11, 6, self.view.frame.size.width - 20 - frame.size.width, 27)];
    self.commentTextView.placeholder = NSLocalizedString(@"Add a comment...", nil);
    self.commentTextView.placeholderColor = WDCOLOR_GRAY_PLACEHOLDER_TEXTVIEW;
    self.commentTextView.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    self.commentTextView.textColor = WDCOLOR_BLACK;
    self.commentTextView.backgroundColor = UICOLOR_WHITE;
    self.commentTextView.layer.borderWidth = 1.;
    self.commentTextView.layer.borderColor = WDCOLOR_GRAY_BORDER.CGColor;
    self.commentTextView.layer.cornerRadius = 1.;
    self.commentTextView.clipsToBounds = YES;
    self.commentTextView.delegate = self;
    [self.inputView addSubview:self.commentTextView];
    

    if(self.track && !self.track.comments.count)
    {
         self.tableView.backgroundColor = UICOLOR_WHITE;
        [self placeholderWithImageName:@"CommentIconNoComment" text:NSLocalizedString(@"No comments yet.", nil)];
    }

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = self.tableView.frame;
    frame.size.height -= COMMENT_VIEW_HEIGHT;
    self.tableView.frame = frame;
    if (self.editMode) {
        [self.commentTextView becomeFirstResponder];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [WDHelper runAfterDelay:0.1 block:^{
        [self scrollToBottom:NO];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)scrollToBottom:(BOOL)animated
{
    if (self.track.comments.count) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:self.track.comments.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionTop animated: animated];
    }
}


#pragma mark TableView Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment* comment = [self.track.comments objectAtIndex:indexPath.row];
    return [Comment heightForComment:comment];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.track.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CommentCell";
    
    
    
    CommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                               reuseIdentifier:CellIdentifier
                           containingTableView:self.tableView // Used for row height and selection
                            leftUtilityButtons:nil
                           rightUtilityButtons:[self rightButtons]];
    }
    cell.delegate = self;
    Comment * comment = [self.track.comments objectAtIndex:indexPath.row];
    cell.comment = comment;
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:WDCOLOR_GRAY_BG_LIGHT
                                                 icon:[UIImage imageNamed:@"CommentButtonDelete"]];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
//                                                title:@"Delete"];
    
    return rightUtilityButtons;
}
#pragma -mark textView Delegate

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
 
//    CGFloat translationValue = ([WDPlayerManager manager].currentTrack.state != TrackStateStop )?216-self.inputView.frame.size.height:216;
//    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        
//        CGAffineTransform t = CGAffineTransformIdentity;
//        self.inputView.transform = CGAffineTransformTranslate(t , 0, -translationValue  );
//        
//    } completion:^(BOOL finished) {
//        CGRect frame = self.tableView.frame;
//        frame.size.height -= translationValue;
//        self.tableView.frame = frame;
//        [self scrollToBottom:YES];
//    }];
    
    return YES;
}


- (void) growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    //input View
	CGRect frame = self.inputView.frame;
    frame.size.height -= diff;
    frame.origin.y += diff;
	self.inputView.frame = frame;
    
    //TableView
    frame = self.tableView.frame;
    frame.size.height += diff;
    self.tableView.frame = frame;
    
    [self scrollToBottom:NO];
    
}

#pragma mark action

- (void)actionSend
{
    if (self.commentTextView.text.length > 0) {
        Comment *newComment = [Comment new];
        newComment.user = [WDHelper manager].currentUser;
        newComment.text = self.commentTextView.text;
        newComment.trackId = self.track.id;
        newComment.isSending = YES;
        
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.track.comments];
        [mArray addObject:newComment];
        self.track.comments = mArray;
        
        [self.tableView reloadData];
        [self scrollToBottom:YES];
        [self sendComment:newComment];
        self.commentTextView.text = @"";
    }

}

- (void) sendComment:(Comment *)comment
{
    NSDictionary *parameters = @{@"pId": self.track.id,
                                 @"text": comment.text};
    
    
    [[WDClient client] GET:API_COMMENT_ADD parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [Flurry logEvent:FLURRY_COMMENT_SEND];
        
        NSString *id = [[responseObject valueForKey:@"_id"] objectAtIndex:0 ];
        comment.id = id;
        comment.isSending = NO;
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.track.comments];
        [mArray replaceObjectAtIndex:mArray.count-1 withObject:comment];
        self.track.comments = mArray;
        self.needToBeUpdated = YES;
        [self.tableView reloadData];
        [self scrollToBottom:NO];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.track.comments.count inSection:0];
        CommentCell *lastCell = (CommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [lastCell sendingFail];
    }];
}

- (void)successResponse:(id)responseObject
{
    WDTrack *track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:[responseObject valueForKey:@"data"] error:nil];
    self.track = track;
    
    [super successResponse:responseObject];
    [self placeholderWithImageName:@"CommentIconNoComment" text:NSLocalizedString(@"No comments yet.", nil)];
    


}

#pragma mark OHAttributed Delegate

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    [self.navigationController pushViewController:[WDHelper viewControllerToPushWithLinkInfo:linkInfo] animated:YES];
    return YES;
}

- (UIColor *)attributedLabel:(OHAttributedLabel *)attributedLabel colorForLink:(NSTextCheckingResult *)linkInfo underlineStyle:(int32_t *)underlineStyle
{
    return WDCOLOR_BLUE;
}


#pragma keyboard height

//Code from Brett Schumann
- (void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        
	// get a rect for the textView frame
    CGRect containerFrame = self.inputView.frame;
    containerFrame.origin.y = self.view.frame.size.height - (keyboardBounds.size.height + COMMENT_VIEW_HEIGHT);
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.view.frame.size.height - keyboardBounds.size.height - COMMENT_VIEW_HEIGHT;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
    self.inputView.frame = containerFrame;
    self.tableView.frame = frame;
//    if(mentionFriendsViewController.view.height==0)
//        mentionFriendsViewController.view.height =self.view.height - keyboardBounds.size.height - COMMENT_VIEW_HEIGHT;
//    
	// commit animations
	[UIView commitAnimations];
    
    [WDHelper runAfterDelay:.3 block:^{
        [self scrollToBottom:YES];
    }];
}


- (void) keyboardWillHide:(NSNotification *)note
{
//    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
//	
//	// get a rect for the textView frame
//    CGRect containerFrame = self.footerView.frame;
//    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
//	
//    self.tableView.height = self.view.bounds.size.height - containerFrame.size.height;
//    
//	// animations settings
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:[duration doubleValue]];
//    [UIView setAnimationCurve:[curve intValue]];
//    
//	// set views with new info
//	self.footerView.frame = containerFrame;
//	
//	// commit animations
//	[UIView commitAnimations];
}

#pragma mark SWTableViewCell delegate

- (void)commentCell:(CommentCell *)cell openUser:(User *)user
{
    UserViewController *vc = [[UserViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteThisComment", nil)
                                                            message:NSLocalizedString(@"AreYouSure", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Yes", nil)
                                                  otherButtonTitles:NSLocalizedString(@"No", nil), nil];
            [alert show];
            
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            self.indexToDelete = cellIndexPath.row ;
            return;
            
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:self.indexToDelete inSection:0];
    CommentCell *commentCell = (CommentCell*) [self.tableView cellForRowAtIndexPath:cellIndexPath];
    if([title isEqualToString:NSLocalizedString(@"No", nil)])
    {
        [commentCell hideUtilityButtonsAnimated:YES];
    }
    else if([title isEqualToString:NSLocalizedString(@"Yes", nil)])
    {
        //DELETE COMMENT
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.track.comments];
        [mArray removeObjectAtIndex:cellIndexPath.row];
        self.track.comments = mArray;
        
        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        Comment *comment = commentCell.comment;

        NSDictionary *parameters = @{@"_id": comment.id};
        self.needToBeUpdated = YES;

        //LEGEND OR COMMENT
        if ([comment.text isEqualToString:self.track.text]) {
            self.track.text = @"";
            [WDHelper insertTrack:self.track editing:YES success:nil failure:nil];
        }else
        {
            [[WDClient client] GET:API_COMMENT_DELETE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
            }];
        }

    }
}


- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    CommentCell *commenCell = (CommentCell*) cell;
    return [commenCell.comment.user.id isEqualToString:[WDHelper manager].currentUser.id];
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
