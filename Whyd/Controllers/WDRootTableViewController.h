//
//  WDRootTableViewController.h
//  Whyd
//
//  Created by Damien Romito on 10/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//
#import <UITableView+NXEmptyView.h>

static NSString * const PARAMETER_SKIP = @"skip";
static NSString * const PARAMETER_LIMIT = @"limit";

@interface WDRootTableViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate/*, UIGestureRecognizerDelegate*/>

@property (nonatomic) UITableViewStyle tableviewStyle;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSString *nbElem;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL lockReload;
@property (nonatomic) BOOL loadMoreEnable;
@property (nonatomic) BOOL hasLoadingView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;


- (void)placeholderWithImageName:(NSString *)imageName text:(NSString *)text andSubView:(UIView *)subView;
- (void)placeholderWithImageName:(NSString *)imageName text:(NSString *)text andSubText:(NSString *)subText;
- (void)placeholderWithImageName:(NSString *)imageName text:(NSString *)text;
- (void)successResponse:(id)responseObject;
- (void)failureResponse:(NSError *)error;
- (void)loadMore;
- (void)reload;
- (void)anyResponse;
- (void)controllerWillDisappear;
- (void)controllerWillAppear;
- (void)handleError:(NSError *)error;
- (void)stopRequests;

@end


@protocol WDRootTableViewController <NSObject>

- (UIView *)tableViewPlaceholder:(UITableView *)tableView;

@end


