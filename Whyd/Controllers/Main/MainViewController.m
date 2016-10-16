//
//  WDPlayerViewController.m
//  Whyd
//
//  Created by Damien Romito on 02/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Config.h"

#import "MainViewController.h"
#import "WDHelper.h"
#import "WDClient.h"
#import "StreamViewController.h"
#import "ProfileViewController.h"
#import "HotTracksViewController.h"
#import "TrackViewController.h"
#import "AFHTTPSessionManager.h"
#import "WelcomeViewController.h"
#import "TutoView.h"
#import "PlaylistViewController.h"
#import "OnboardingGenresViewController.h"
#import "NotificationsViewController.h"
#import "WDAlertView.h"
#import "WDWelcomeView.h"
#import "WDMessage.h"
#import "WDBackgroundBlurView.h"
#import "WDNavigationController.h"
#import "WDFacebookHelper.h"
#import "WDUserPickerViewController.h"
#import "Activity.h"


static const float HEIGHT_MINIPLAYER = 45;

@interface MainViewController ()<WDWelcomeViewDelegate, TutoDelegate>
@property (nonatomic,strong) WDPlayerManager *player;

//PLAYER


@property (nonatomic) NSInteger currentControllerIndex;
@property (nonatomic, strong) UIViewController* trackNavigationController;

@property (nonatomic, strong) UINavigationController* searchViewController;
@property (nonatomic) BOOL animated;
@property (nonatomic) BOOL unvailableSourceEncountered;

@property (nonatomic, strong) PlayerView* playerView;
@property (nonatomic, strong) StreamViewController *streamViewController;
@property (nonatomic, strong) WDBackgroundBlurView *backgroundView;

@end

@implementation MainViewController

+ (instancetype)manager {
    static MainViewController *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}



-(void)loadView
{
    
 
    [[UINavigationBar appearance] setTintColor:UICOLOR_BLACK];
    [self.navigationController.navigationBar setBackgroundColor:UICOLOR_BLACK];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars=NO;
//    }
    
    [super loadView];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications:) name:NOTIFICATION_NOTIFICATIONS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentTrack) name:WDPlayerManagerStartTrack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayerState) name:WDPlayerStateDidChange object:nil];
    
    /*********************************** VIEWS CONTAINER ***********************************/
    
    //VIEWS CONTROLLER
    self.viewsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.viewsContainer.backgroundColor = WDCOLOR_WHITE;
    [self.view addSubview:self.viewsContainer];
    
    //PLAYLIST
    self.streamViewController = [[StreamViewController alloc] init];
    self.streamViewController.title = NSLocalizedString(@"StreamTitle", nil);
    
    
    self.profileViewController = [[ProfileViewController alloc] init];
    self.profileViewController.title = NSLocalizedString(@"ProfileTitle", nil);
    
    HotTracksViewController *hotTracksController = [[HotTracksViewController alloc] init];
    hotTracksController.title = NSLocalizedString(@"HotTracks", nil);
    
    NotificationsViewController *notificationsController = [[NotificationsViewController alloc] init];
    notificationsController.title = NSLocalizedString(@"Notifications", nil);
    
    
    self.viewControllers =  @[
             [[UINavigationController alloc] initWithRootViewController:self.streamViewController],
             [[UINavigationController alloc] initWithRootViewController:self.profileViewController],
             [[UINavigationController alloc] initWithRootViewController:hotTracksController],
             [[UINavigationController alloc] initWithRootViewController:notificationsController],
             ];
    
    
    /*********************************** SEARCH CONTROLLER **********************************/

    self.searchContainer = [[UIView alloc] initWithFrame:self.view.frame];
    self.searchContainer.hidden = YES;
    [self.view addSubview:self.searchContainer];

    
    /*********************************** BOTTOM PLAYER **********************************/
    
    self.bottomPlayer = [[BottomPlayerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - HEIGHT_MINIPLAYER, self.view.bounds.size.width, HEIGHT_MINIPLAYER)];
    self.bottomPlayer.hidden = YES;
    [self.view addSubview:self.bottomPlayer];

    
    /*********************************** PLAYER VIEW ***********************************/

    
    //TRACK VIEW
    self.playerView = [[PlayerView alloc] initWithFrame:self.view.bounds];
    self.playerView.hidden = YES;
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    
    
    /*********************************** MENU VIEW **********************************/
    self.menuView = [[MenuView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.menuView];
    [self displayViewControllerAtIndex:0];

    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
    

    
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.playerView.hidden) {
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    }else
    {
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    
    
   [self checkIsLogged:YES];
    [super viewDidAppear:animated];
    [self becomeFirstResponder];

}


#pragma mark Load Containers

- (UIViewController *) displayViewControllerAtIndex: (NSUInteger)index;
{
    
    UINavigationController* content = [self.viewControllers objectAtIndex:index];
    
    //APPEAR / DISAPPEAR
    [self navigationController:content willAppear:YES];
    [self navigationController:[self.viewControllers objectAtIndex:self.currentControllerIndex] willAppear:NO];

    //SWITCH
    self.currentControllerIndex = index;
    [self addChildViewController:content];
    content.view.frame = self.viewsContainer.frame;
    [self.viewsContainer addSubview:content.view];
    [content viewDidAppear:NO];
    if ([content isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*) content;
        self.delegate = [[nav viewControllers] lastObject];
    }
    
    [content didMoveToParentViewController:self];

    return content;
}

- (void)navigationController:(UINavigationController *)nav willAppear:(BOOL)willAppear
{
    WDRootTableViewController *vc = (WDRootTableViewController *)nav.visibleViewController;

    if (willAppear) {
        if ([vc respondsToSelector:@selector(controllerWillAppear)]) {
            [vc controllerWillAppear];
        }
    }else
    {
        if ([vc respondsToSelector:@selector(controllerWillDisappear)]) {
            [vc controllerWillDisappear];
        }

    }
    
}

- (UIViewController*)currentViewController
{
    UINavigationController *nav;
    if (self.searchViewController) {
        nav = self.searchViewController;
    }else
    {
        nav = [self.viewControllers objectAtIndex:self.currentControllerIndex];
    }
    return nav.visibleViewController;
}



#pragma mark Actions

- (void)actionOpenMiniPlayer:(BOOL)displayed
{

    CGRect frame;
    
    if (displayed) {
        self.bottomPlayer.hidden = NO;
        frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - HEIGHT_MINIPLAYER);
    }else
    {
        self.bottomPlayer.hidden = YES;
        frame = self.view.bounds;
    }
    
    
    self.viewsContainer.frame = frame;
    if (self.searchViewController) {
        self.searchContainer.frame = frame;
    }
}

- (void)track:(WDTrack*)track added:(BOOL)added
{
    
    DLog(@"track ACTIO  %@", track);
    if (added) {
        //UPDATE PROFILE
        NSMutableArray *mArray = [NSMutableArray arrayWithObject:track];
        [mArray addObjectsFromArray:((UserViewController*)self.profileViewController).tracksPlaylist.tracks];
        ((UserViewController*)self.profileViewController).tracksPlaylist.tracks = mArray;
        [((UserViewController*)self.profileViewController).tableView reloadData];
    }else
    {
        
    }
}

- (void)actionOpenPlayer
{
    

    [self.playerView show];

    
    self.playerView.backgroundView = [[WDBackgroundBlurView alloc] initWithFrame:self.view.frame];
    self.playerView.backgroundView.contentMode = UIViewContentModeBottom;
    if (self.searchContainer.hidden) {
        [self.playerView.backgroundView show];
    }else
    {
        [self.playerView.backgroundView showInView:self.searchContainer];
    }
    self.playerView.backgroundView.frame = CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 0);

    
    self.playerView.transform = CGAffineTransformMakeTranslation(0, self.playerView.frame.size.height);
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.playerView.transform = CGAffineTransformIdentity;
        self.playerView.backgroundView.frame = self.view.frame;
        self.bottomPlayer.alpha = 0;

    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    }];
    
}


- (void)actionLogout
{
    [self stopPlayer];
    [WDHelper logout];
    [self checkIsLogged:YES];
}


- (void)actionOpenSearch
{

    
    if (!self.animated) {
        

        SearchViewController *vc = [[SearchViewController alloc] init];

        
        
        vc.delegate = self;
        
        self.searchViewController = [[UINavigationController alloc] initWithRootViewController:vc];
        
        //for the scrolltotop
        [self navigationController:self.searchViewController willAppear:YES];
        [self navigationController:[self.viewControllers objectAtIndex:self.currentControllerIndex] willAppear:NO];
        
        
        UIViewController* content = self.searchViewController;
        [self addChildViewController:content];
        content.view.frame = self.viewsContainer.frame;
        [self.searchContainer addSubview:content.view];
        [content didMoveToParentViewController:self];
        self.searchContainer.hidden = YES;
   
        
        
        self.backgroundView = [[WDBackgroundBlurView alloc] initWithFrame:self.view.frame];
        self.backgroundView.contentMode = UIViewContentModeBottom;
        [self.backgroundView show];
        self.backgroundView.frame = CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 0);

        self.searchContainer.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);

        self.searchContainer.hidden = NO;
        self.animated = YES;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.searchContainer.transform = CGAffineTransformIdentity;
            self.backgroundView.frame = self.view.frame;

        } completion:^(BOOL finished) {
            self.animated = NO;            
        }];
        
    }
}



- (void)actionOpenMenu
{
    
    [self currentViewController];
    [self.menuView actionOpen];
}


- (void)checkIsLogged:(BOOL)animated
{
    if (![WDHelper isLogged]) {
        WelcomeViewController * vc = [[WelcomeViewController alloc]  init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginWithSuccess)
                                                     name:NOTIFICATION_LOGIN_SUCCESS
                                                   object:nil];
        
        WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:animated completion:nil];
    }
}

- (void)updateNotifications:(NSNotification *)notification
{
    self.hasNotifs = [[notification.userInfo valueForKey:NOTIFICATION_NOTIFICATIONS_UPDATE_COUNT_KEY] integerValue];
}


- (void)updatePlayerState
{
    WDPlayerState state = [WDPlayerManager manager].currentState;
    
    if (state == WDPlayerStatePlay
        && [[WDPlayerManager manager].currentTrack.sourceKey isEqualToString:WDSourceYoutube]){
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
            [[WDPlayerManager manager] pause];
        }
        if(self.playerView.hidden){
            [self actionOpenPlayer];
        }
    }
    
    
}


- (void)updateCurrentTrack
{
    [self.bottomPlayer updateTrack];
    if (self.bottomPlayer.hidden) {
        [self actionOpenMiniPlayer:YES];
    }
    
}

- (void)stopPlayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self actionOpenMiniPlayer:NO];
    });
}


/***************************************************************************************/
/*********************************** DELEGATION ************************************/
/***************************************************************************************/






#pragma mark PlayerView Delegate

- (void)playerViewDismissed
{
    [self playerViewDismissedWithCurrentTrack:nil];
}

- (void)playerViewDismissedWithCurrentTrack:(WDTrack *)currentTrack
{
    
    //VIEW APPEAR (UPDATE)

    [self.bottomPlayer setTitle:[WDPlayerManager manager].currentTrack.name];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.playerView.transform = CGAffineTransformMakeTranslation(0, self.playerView.frame.size.height);
        self.playerView.backgroundView.frame = CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 0);
        self.bottomPlayer.alpha = 1;
    } completion:^(BOOL finished) {
        self.playerView.hidden = YES;
        [self.playerView.backgroundView hide];

    }];
    
    if (currentTrack) {
        
        // IMPROVE NAV FROM PLAYER VIEW
        //SELECT CURRENT TRACK

        [WDHelper runAfterDelay:.3 block:^{
            if ([self.delegate respondsToSelector:@selector(highlightCurrentTrackAtIndex:)]) {
                [self.delegate highlightCurrentTrackAtIndex:[WDPlayerManager manager].currentIndex];
            }
        }];

     
    }
}

- (void)searchViewDismissed
{
    UINavigationController* content = [self.viewControllers objectAtIndex:self.currentControllerIndex];
    self.delegate = content.visibleViewController;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.searchContainer.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
        self.backgroundView.frame = CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 0);

    } completion:^(BOOL finished) {
        self.searchContainer.hidden = YES;
        [self.searchViewController willMoveToParentViewController:nil];  // 1
        [self.searchViewController.view removeFromSuperview];            // 2
        [self.searchViewController removeFromParentViewController];      // 3
        self.searchViewController = nil;
        [self.backgroundView hide];
        
    }];
    
    [self navigationController:content willAppear:YES];
    [self navigationController:self.searchViewController willAppear:NO];
}


#pragma mark Login Delegate

- (void)loginWithSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOGIN_SUCCESS object:nil];
    

    
    NSDictionary* tutoSeen = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_TUTO_SEEN];
    if([WDHelper manager].currentUser.nbSubscriptions == 0)
    {
        //ONBOARDING
        OnboardingGenresViewController *onboardingGenre = [[OnboardingGenresViewController alloc] init];
        WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:onboardingGenre];
        [self presentViewController:nav animated:YES completion:nil];
    }else if (!tutoSeen)
    {
        WDWelcomeView *welcomeView = [[WDWelcomeView alloc] initWithFrame:self.view.frame];
        welcomeView.delegate = self;
        [self.view addSubview:welcomeView];
        [welcomeView show];
        
    }
 
    UIApplication *application = [UIApplication sharedApplication];
    
    BOOL isRegister ;
    //PUSH IF ACCEPTED
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        isRegister = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        isRegister = (types != UIRemoteNotificationTypeNone)?YES:NO;
    }
    
    if (isRegister) {
        [WDHelper apnSet];
    }
    [Activity refreshNotificationsHistoryAndRead:NO success:nil];

    [self reloadApp];
}

- (void)onboardingWithSuccess
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ONBOARDING_SUCCESS object:nil];
    [self reloadApp];
}

- (void)reloadApp
{

    [self.streamViewController reload:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STREAM_LOADED object:nil];
    } failure:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STREAM_LOADED object:error];

    }];
    [(ProfileViewController *)self.profileViewController updateUser];
    
    if ([self.delegate respondsToSelector:@selector(actionScrollTop)]) {
        [self.delegate actionScrollTop];
    }
}

- (void)handleMessage:(NSString *)message callback:(void (^)())callback
{
    
    UIViewController *vc = [self currentViewController];
    UIView *displayingView;
    if ([vc isKindOfClass:[WDRootTableViewController class]]) {
        displayingView = ((WDRootTableViewController*)vc).view;
    }else
    {
        displayingView = self.view;
    }
    
    [WDMessage showMessage:message inView:displayingView withTopMargin:NO withBackgroundColor:WDCOLOR_GREEN callback:^{
        callback();
    }];
}

- (void)handleMessage:(NSString *)message
{
    UIView *view;
    if (self.playerView.hidden) {
        view = [self currentViewController].view;
    }else
    {
        view = self.playerView;
    }
    [WDMessage showMessage:message inView:view withTopMargin:!self.playerView.hidden withBackgroundColor:WDCOLOR_GREEN];
}

- (void)handleError:(NSError*)error{
    
    if (error.code == ERROR_INTERNET_NO || error.code == ERROR_INTERNET_NO || error.code == ERROR_PLAYLIST_UNAVAILABLE || error.code == ERROR_PLAYLIST_EMPTY ) {
        [self stopPlayer];
        [self displayError:error];
        
    }else if (error.code == ERROR_TRACK_UNAVAILABLE)
    {
        if (!self.unvailableSourceEncountered) {
            self.unvailableSourceEncountered = YES;
            [WDHelper checkIfNeedUpdate:^(NSString *version) {
                if (version) {
                    [WDAlertView showWithType:WDAlertTypeUpdate andInfoString:version];
                }else
                {
                    [self displayError:error];
                }
            } failure:^(NSError *error) {
                
            }];
        }

    
        
        
    }

}

- (void)displayError:(NSError *)error
{
    UIViewController *vc = [self currentViewController];
    if ([vc isKindOfClass:[WDRootTableViewController class]]) {
        [(WDRootTableViewController*)vc handleError:error];
    }else
    {
        [WDMessage showMessage:error.localizedDescription inView:self.view withTopMargin:YES];
    }
}
#pragma mark WDPlayerManager Delegate


- (void)WDPlayerManagerUpdatePosition:(float)position
{
    [self.playerView updatePosition:position];
}

- (void)WDPlayerManagerUpdateTotalDuration:(float)duration
{
    [self.playerView updateTotalDuration:duration];
}


//- (void)WDPlayerManagerReadyToPlay
//{
//    [self.playerView readyToPlay];
//}

- (void)WDPlayerManagerHandleError:(NSError *)error
{

    [self handleError:error];
        
}


#pragma -mark WDWelcomeVIew Delegate

- (void)WDWelcomeViewWillDisappear
{
    TutoView *tutoView = [[TutoView alloc] initWithFrame:self.view.frame];
    tutoView.delegate = self;
    self.streamViewController.view.userInteractionEnabled = NO;
    [self.view addSubview:tutoView];
    
}

- (void)TutoClosed
{
    self.streamViewController.view.userInteractionEnabled = YES;

}

- (void)didReceiveMemoryWarning
{
    DLog(@"!!!!!!!!!!!!!!MEMORY WARNING IN MAIN VIEW!!!!!!!!!!!!!");
    [super didReceiveMemoryWarning];
}


//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//
//- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (motion == UIEventSubtypeMotionShake)
//    {
//        if(YES)//[[WDHelper manager] isAdmin])
//        {
//            OnboardingGenresViewController *onboardingGenre = [[OnboardingGenresViewController alloc] init];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:onboardingGenre];
//            [self.navigationController presentViewController:nav animated:YES completion:nil];
//        }
//    }
//}
//


@end
