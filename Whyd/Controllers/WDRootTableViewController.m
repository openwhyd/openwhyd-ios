//
//  WDRootTableViewController.m
//  Whyd
//
//  Created by Damien Romito on 10/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDRootTableViewController.h"
#import "WDClient.h"
#import "MainViewController.h"
#import "WDHelper.h"
#import "WDMessage.h"

@interface WDRootTableViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreSpinner;
@property (nonatomic, strong) UITapGestureRecognizer *titleGesture;
@property (nonatomic, strong) UIView *noNetworkView;

@end


@implementation WDRootTableViewController




- (void)loadView
{
    [super loadView];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(self.tableviewStyle)?self.tableviewStyle:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delaysContentTouches = YES;
    self.tableView.backgroundColor = WDCOLOR_WHITE;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;



    [self.view addSubview:self.tableView];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;

    if (!self.lockReload) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        tableViewController.refreshControl = self.refreshControl;
    }

    /***************************** FOOTER ***********************************/

    self.loadMoreSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                            UIActivityIndicatorViewStyleWhiteLarge];
    
    self.loadMoreSpinner.frame = CGRectMake(0, 15, self.view.frame.size.width, 60);
    self.loadMoreSpinner.color = UICOLOR_BLACK;
    self.parameters = [[NSMutableDictionary alloc]init];
    
    self.hasLoadingView = YES;

    
    self.loadingView = [WDHelper WDActivityIndicator];
    [self.view addSubview:self.loadingView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.tableView.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)controllerWillDisappear
{
    self.tableView.scrollsToTop = NO;
    [[WDClient client].operationQueue cancelAllOperations];
    [self anyResponse];

}

-(void)controllerWillAppear
{
    self.tableView.scrollsToTop = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect frame = self.loadingView.frame;
    frame.origin.y = (self.view.bounds.size.height - self.tableView.tableHeaderView.frame.size.height)/2 - 40 + self.tableView.tableHeaderView.frame.size.height;
    self.loadingView.frame = frame;

}

- (void) reload
{
    
    if (self.hasLoadingView && ![self.loadMoreSpinner isAnimating] && ![self.refreshControl isRefreshing] ) {
        self.loadingView.alpha = 0;
        [self.loadingView startAnimating];
        [UIView animateWithDuration:.2 animations:^{
            self.loadingView.alpha = 1;
        }];
    }
        
    if(self.urlString)
    {
        [[WDClient client] GET:self.urlString parameters:self.parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject objectForKey:@"error"]) {
                
                NSString * response = [responseObject objectForKey:@"error"];
                
                NSError * error = [NSError errorWithDomain:response code:0 userInfo:nil];
                [self failureResponse:error];
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self successResponse:responseObject];
                });
            }

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self failureResponse:error];
        }];
  
    }
}

- (void)successResponse:(id)responseObject
{
    
    [self.tableView reloadData];
    [self anyResponse];
    
    if (self.tableView.backgroundColor == UICOLOR_CLEAR) return;
            
    if ([self.tableView numberOfRowsInSection:0] ) {
        self.tableView.backgroundColor = WDCOLOR_WHITE;
    }else
    {
        self.tableView.backgroundColor = UICOLOR_WHITE;

    }


}

- (void)anyResponse
{
    if ([self.loadMoreSpinner isAnimating]) {
        [self.loadMoreSpinner stopAnimating];
        [self.parameters removeObjectForKey:PARAMETER_SKIP];
        
    }
    else if([self.loadingView isAnimating])
    {
        [UIView animateWithDuration:.2 animations:^{
            self.loadingView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.loadingView stopAnimating];
             self.loadingView.alpha = 1;
        }];
    }else if([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }

}

- (void)failureResponse:(NSError *)error
{
    //[WDClient handleError:error];
    
    //NO NETWORK
    if (error.code == -1009) {
        [self displayNetworkError];
    }
    [self anyResponse];

}

- (void)handleError:(NSError *)error
{
    if (error.code == ERROR_INTERNET_NO || error.code == ERROR_INTERNET_LOST) {
        [self displayNetworkError];
    }else if (error.code == ERROR_PLAYLIST_UNAVAILABLE)
    {
        [WDMessage showMessage: NSLocalizedString(@"PlaylistUnavailable", nil) inView:self.view];
    }else if (error.code == ERROR_PLAYLIST_EMPTY)
    {
        [WDMessage showMessage:NSLocalizedString(@"PlaylistEmpty", nil) inView:self.view];
    }
}

- (void)displayNetworkError
{
    //CONTENT ALREADY LOAD
    if ([self tableView:self.tableView numberOfRowsInSection:0]) {
        [WDMessage showMessage:NSLocalizedString(@"ErrorNoInternet", nil) inView:self.view];
    }else
    {
        if (!self.noNetworkView) {
            
            self.noNetworkView = [[UIView alloc] initWithFrame:self.tableView.frame];
            self.noNetworkView.backgroundColor = RGBCOLOR(237, 240, 243);
            
            CGFloat positionY = self.tableView.frame.size.height * 0.36;
            
            UIImageView *iconeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StreamIconNoConnection"]];
            CGRect frame = iconeImage.frame;
            frame.origin.x = self.view.frame.size.width/2 - iconeImage.frame.size.width/2;
            frame.origin.y = positionY;
            iconeImage.frame = frame;
            [self.noNetworkView addSubview:iconeImage];
            
            UILabel *noNetworkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 58 + positionY, self.view.frame.size.width, 13)];
            noNetworkLabel.text = NSLocalizedString(@"ErrorNoInternet", nil);
            noNetworkLabel.textColor = RGBCOLOR(94, 97, 104);
            noNetworkLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
            noNetworkLabel.textAlignment = NSTextAlignmentCenter;
            [self.noNetworkView addSubview:noNetworkLabel];
            
            UIButton *retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 90 + positionY, self.view.frame.size.width, 17)];
            [retryButton setTitle:NSLocalizedString(@"ErrorNoInternetRetry", nil) forState:UIControlStateNormal];
            [retryButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
            retryButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
            [retryButton addTarget:self action:@selector(actionRetryNetwork) forControlEvents:UIControlEventTouchUpInside];
            [self.noNetworkView addSubview:retryButton];
            self.noNetworkView.alpha = 0;
            [self.view addSubview:self.noNetworkView];

            
        }
        
        [self.view addSubview:self.noNetworkView];
        [UIView animateWithDuration:.2 animations:^{
            self.noNetworkView.alpha = 1;
        }];
        
    }
}

- (void)stopRequests
{
    [[WDClient client].operationQueue cancelAllOperations];
    [self.loadingView stopAnimating];
}

#pragma -mark ACTIONS

- (void)actionRetryNetwork
{
    [UIView animateWithDuration:.2 animations:^{
        self.noNetworkView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.noNetworkView removeFromSuperview];
        [self reload];
    }];
   
}

#pragma -mark SETTER
- (void)setLoadMoreEnable:(BOOL)loadMoreEnable
{
    _loadMoreEnable = loadMoreEnable;
    
    if (loadMoreEnable) {
        self.tableView.tableFooterView = self.loadMoreSpinner;
    }else
    {
        self.tableView.tableFooterView = nil;
    }
}


#pragma mark Placeholder

- (void)placeholderWithImageName:(NSString *)imageName text:(NSString *)text
{
    [self placeholderWithImageName:imageName text:text andSubText:nil andSubView:nil];
}


- (void)placeholderWithImageName:(NSString *)imageName text:(NSString *)text andSubText:(NSString *)subText
{
    [self placeholderWithImageName:imageName text:text andSubText:subText andSubView:nil];
}


- (void) placeholderWithImageName:(NSString *)imageName text:(NSString *)text andSubView:(UIView *)subView{
    [self placeholderWithImageName:imageName text:text andSubText:nil andSubView:subView];
}


- (void) placeholderWithImageName:(NSString *)imageName text:(NSString *)text andSubText:(NSString *)subText andSubView:(UIView *)subView{


    UIView *placeholderView = [[UIView alloc] init];
    placeholderView.backgroundColor = UICOLOR_WHITE;
    
    UIImageView *placeholderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    placeholderImage.contentMode =UIViewContentModeScaleAspectFill;
    CGRect frame = placeholderImage.frame;
    frame.origin.x = self.view.frame.size.width/2 - frame.size.width/2;
    frame.origin.y = (IS_IPHONE_5)?50:15;
    placeholderImage.frame = frame;
    [placeholderView addSubview:placeholderImage];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, placeholderImage.frame.origin.y + 25, self.view.frame.size.width, 100)];
    textLabel.text = text;
    textLabel.textColor = WDCOLOR_BLUE_DARK;
    textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [placeholderView addSubview:textLabel];
    
    
    if (subText || subView) {
        UIView *view;
        if (subText)
        {
            UILabel *subLabel = [[UILabel alloc] init];
            subLabel.text = subText;
            [subLabel sizeToFit];
            subLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
            subLabel.textColor = WDCOLOR_GRAY_DARK;
            subLabel.textAlignment = NSTextAlignmentCenter;
            view = subLabel;
        }
        else if (subView) {
            view = subView;
        }
        frame = view.frame;
        frame.origin.y = textLabel.frame.origin.y + 60;
        frame.origin.x = self.view.frame.size.width/2 - frame.size.width/2;
        view.frame = frame;
        [placeholderView addSubview:view];
    }
    self.tableView.nxEV_emptyView = placeholderView;

}



#pragma mark Actions

- (void)actionScrollTop
{
    [self.tableView setContentOffset:CGPointMake(0,0) animated:YES];
}


#pragma mark Default TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"DefaultCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}


#pragma mark ScrollView Delegate



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //LOAD MORE
    if(self.loadMoreEnable && scrollView == self.tableView )
    {
        NSInteger currentOffset = scrollView.contentOffset.y;
        NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height ;
        if (maximumOffset - currentOffset <= 0)
        {
            if (!self.loadMoreSpinner.isAnimating) {
                [self.loadMoreSpinner startAnimating];
                [self loadMore];
            }
        }
    }
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {

    return YES;
}

- (void)loadMore
{
    [self reload];
}


-(void)refreshView:(UIRefreshControl *)refresh {
    
         [self reload];

   
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING WDROOTTABLEVIEW");
    [super didReceiveMemoryWarning];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    CGPoint touchLocation = [touch locationInView:self.view];
//    DLog(@"touch %f", touchLocation.x);
//    return (touchLocation.x > 70 && touchLocation.x< 250)?YES:NO;//(![[[touch view] class] isSubclassOfClass:[UIControl class]]);
//}

@end
