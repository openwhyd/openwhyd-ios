//
//  WDPlayerViewController.h
//  Whyd
//
//  Created by Damien Romito on 02/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerManager.h"
#import "PlayerView.h"
#import "SearchViewController.h"
#import "MenuView.h"
#import "BottomPlayerView.h"
#import "WDActivityIndicatorView.h"




@interface MainViewController : UIViewController<WDPlayerManagerDelegate, PlayerViewDelegate, SearchViewDelegate>

@property(nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic) BOOL hasNotifs;
@property (nonatomic, strong) MenuView* menuView;
@property (nonatomic, strong) UIViewController* profileViewController;
@property (nonatomic, strong) UIView* viewsContainer;
@property (nonatomic, strong) BottomPlayerView* bottomPlayer;
@property (nonatomic, strong) UIView* searchContainer;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;


+ (instancetype)manager;
- (void)actionOpenMenu;
- (void)actionOpenSearch;
- (void)actionLogout;
- (void)actionOpenPlayer;
- (UIViewController *) displayViewControllerAtIndex: (NSUInteger)index;
- (void)onboardingWithSuccess;
- (void)track:(WDTrack*)track added:(BOOL)added;
- (void)handleMessage:(NSString *)message;
- (void)handleMessage:(NSString *)message callback:(void (^)())callback;
- (void)handleError:(NSError*)error;

@end


@protocol MainViewDelegate <NSObject>

@optional
- (void)waitCurrentTrack;
- (void)highlightCurrentTrackAtIndex:(NSInteger)index;
- (void)actionScrollTop;

@end

