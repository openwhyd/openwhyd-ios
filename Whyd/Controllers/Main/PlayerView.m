//
//  PlayerView.m
//  Whyd
//
//  Created by Damien Romito on 04/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PlayerView.h"
#import "WDTrack.h"
#import "UIImageView+WebCache.h"
#import "CommentCell.h"
#import "CommentsViewController.h"
#import "EditTrackViewController.h"
#import "WDHelper.h"
#import "UIImage+Additions.h"
#import "GHContextMenuView.h"
#import "MainViewController.h"
#import "WDMessage.h"
#import <objc/message.h>
#import "WDShareSheet.h"
#import "UIView+UpdateAutoLayoutConstraints.h"


@interface PlayerView()< GHContextOverlayViewDelegate>

@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) UIImageView *mediaContainer;
@property (nonatomic, strong) UIImageView *sourceImageView;

//@property (nonatomic, weak) UIView *mediaView;

@property (nonatomic, weak) WDTrack *track;

@property (nonatomic, strong) UIView *playerController;

@property (nonatomic,strong) UIButton *fullScreenButton;

@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIButton *playlistButton;


@property (nonatomic, strong) UIImageView *userAvatarImage;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *userTimeLabel;

@property (nonatomic, strong) UILabel *durationCurrentLabel;
@property (nonatomic, strong) UILabel *durationTotalLabel;
@property (nonatomic,strong) UISlider *seekBar;
@property(nonatomic) BOOL seekBarIsDragged;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *shuffleButton;

@property (nonatomic, strong) UIView *interactionsContainer;
@property (nonatomic, strong) UILabel *interactionsLikesLabel;
@property (nonatomic, strong) UILabel *interactionsAddsLabel;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property(nonatomic) BOOL isInFullScreen;
@property (nonatomic) BOOL orientationAccepted;
@property (nonatomic, strong) WDShareSheet *shareSheet;

@end
@implementation PlayerView


- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        
        //BACKGROUND
        /***************************************************************************************/
        /***************************************************************************************/
        self.backgroundColor = WDCOLOR_BLACK_TRANSPARENT;


        /*********************************** NAV BAR ***********************************/
        self.hideButton = [[UIButton alloc] init];
        self.hideButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.hideButton setImage:[UIImage imageNamed:@"PlayerHide"] forState:UIControlStateNormal];
        [self.hideButton addTarget:self action:@selector(actionHide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.hideButton];
        
        
        self.likeButton = [[UIButton alloc] init];
        self.likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.likeButton setImage:[UIImage imageNamed:@"PlayerButtonLoveDisable"] forState:UIControlStateNormal];
        [self.likeButton setImage:[UIImage imageNamed:@"TrackPageButtonLoveSelected"] forState:UIControlStateSelected];
        [self.likeButton addTarget:self action:@selector(actionLike) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.likeButton];
        
        self.shareButton = [[UIButton alloc] init];
        self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.shareButton setImage:[UIImage imageNamed:@"PlayerButtonShare"] forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(actionShare) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shareButton];
        
        
        self.addButton = [[UIButton alloc] init];
        self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.addButton setTitle:[NSLocalizedString(@"Add", nil) uppercaseString] forState:UIControlStateNormal];
        [self.addButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
        [self.addButton setImage:[UIImage imageNamed:@"PlayerButtonAdd"] forState:UIControlStateNormal];
        self.addButton.imageView.alpha = 1.;
        [self.addButton addTarget:self action:@selector(actionAddNavBar) forControlEvents:UIControlEventTouchUpInside];
        self.addButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_2];
        self.addButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 11);
        self.addButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16);
        self.addButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.addButton sizeToFit];
        [self.addButton setNeedsLayout];
        CGRect frame = self.addButton.frame;
        frame.size.width = self.addButton.frame.size.width + 26;
        self.addButton.frame = frame;
        [self addSubview:self.addButton];
        
        UIView * backgroundButton = [[UIView alloc] init];
        backgroundButton.backgroundColor = WDCOLOR_BLACK_TRANSPARENT;
        backgroundButton.layer.cornerRadius = CORNER_RADIUS;
        backgroundButton.userInteractionEnabled = NO;
        backgroundButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self.addButton addSubview:backgroundButton];
        [self.addButton sendSubviewToBack:backgroundButton];
        
        
        NSNumber *addSpaceSeparator = [NSNumber numberWithFloat:(self.frame.size.width - 162 - self.addButton.frame.size.width)];
        
        
        /*********************************** MEDIA CONTAINER ***********************************/

        self.mediaContainer = [UIImageView new];
        self.mediaContainer.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *tapGesture =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionGoToTrack)];
        [self.mediaContainer addGestureRecognizer:tapGesture];
        UISwipeGestureRecognizer *leftGesture =  [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionNext)];
        [self.mediaContainer addGestureRecognizer:leftGesture];
        leftGesture.direction =UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *rightGesture =  [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionPrev)];
        [self.mediaContainer addGestureRecognizer:rightGesture];
        rightGesture.direction = UISwipeGestureRecognizerDirectionRight;

        self.mediaContainer.userInteractionEnabled = YES;
        self.mediaContainer.contentMode = UIViewContentModeScaleAspectFit;
        [[WDPlayerManager manager] setMovieContainer:self.mediaContainer];

        [self addSubview:self.mediaContainer];
        

        /************** SOURCE ICON ****************/
        
        
        self.sourceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StreamCornerBackgroundSourceLeft"]];
        [self.mediaContainer addSubview:self.sourceImageView ];
        
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.color = UICOLOR_WHITE;
        self.spinner.frame = CGRectMake( 0, 0, self.frame.size.width, 0);
        self.spinner.autoresizingMask =UIViewAutoresizingFlexibleHeight;
        [self.mediaContainer addSubview:self.spinner];
        
        //FULL SCREEN BUTTON
//        self.fullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(275, 180, 30, 30)];
//        frame = CGRectZero;
//        frame.size.width = 30;
//        frame.size.height = 30;
//        frame.origin.x = 275;
//        frame.origin.y = self.mediaContainer.frame.size.height + self.mediaContainer.frame.origin.y - (frame.size.height+10);
//        self.fullScreenButton.frame = frame;
//        [self.fullScreenButton setImage:[UIImage imageNamed:@"player_button_fullscreen"] forState:UIControlStateNormal];
//        [self.fullScreenButton addTarget:self action:@selector(actionFullScreen) forControlEvents:UIControlEventTouchUpInside];
//        self.fullScreenButton.hidden = NO;
//        [self addSubview:self.fullScreenButton];
        
 
        
        //TITLE
        self.titleButton = [UIButton new];
        self.titleButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];

        self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.titleButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_5];
        self.titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleButton.titleLabel.numberOfLines = 2;
        [self.titleButton addTarget:self action:@selector(actionGoToTrack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.titleButton];

        //PLAYSLIST
        UIView *separator = [UIView new];
        separator.translatesAutoresizingMaskIntoConstraints = NO;
        separator.backgroundColor = WDCOLOR_BLACK_LIGHT;
        separator.alpha = 0.3;
        [self addSubview:separator];
        
        self.playlistButton = [[UIButton alloc]init];
        self.playlistButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.playlistButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
        [self.playlistButton setImage:[UIImage imageNamed:@"PlayerNowPlayingIcon"] forState:UIControlStateNormal];
        self.playlistButton.titleEdgeInsets = UIEdgeInsetsMake(4, 5, 0, 0);
        self.playlistButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        [self.playlistButton addTarget:self action:@selector(actionGoToTrack) forControlEvents:UIControlEventTouchUpInside];

        [self.playlistButton setTitleColor:WDCOLOR_BLACK_LIGHT forState:UIControlStateNormal];
        [self addSubview:self.playlistButton];


        /*********************************** SEEKBAR CONTROLLER ***********************************/
        
        self.durationCurrentLabel = [UILabel new];
        self.durationCurrentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.durationCurrentLabel.text = @"-:--";
        self.durationCurrentLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
        self.durationCurrentLabel.textColor = UICOLOR_WHITE;
        [self addSubview:self.durationCurrentLabel];
 
        
        self.seekBar = [[UISlider alloc] init];
        self.seekBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.seekBar setThumbImage:[UIImage imageNamed:@"PlayerSliderGrip"] forState:UIControlStateNormal];
        [self.seekBar setTintColor:UICOLOR_WHITE];
        [self.seekBar setMaximumTrackTintColor:RGBCOLOR(65, 69, 76)];
        [self.seekBar addTarget:self action:@selector(seekBarTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.seekBar addTarget:self action:@selector(seekBarTouchUp:) forControlEvents:UIControlEventTouchUpOutside];

        [self.seekBar addTarget:self action:@selector(seekBarIsDragged:) forControlEvents:UIControlEventTouchDown];
        [self.seekBar addTarget:self action:@selector(seekBarValueChanged:) forControlEvents:UIControlEventValueChanged];

        [self addSubview:self.seekBar];
        
        self.durationTotalLabel = [UILabel new];
        self.durationTotalLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.durationTotalLabel.text = @"-:--";
        self.durationTotalLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
        self.durationTotalLabel.textColor = UICOLOR_WHITE;
        [self addSubview:self.durationTotalLabel];
        
        
        /*********************************** PLAYER CONTROLLER ***********************************/
        self.shuffleButton = [[UIButton alloc] init];
        self.shuffleButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.shuffleButton setImage:[UIImage imageNamed:@"PlayerButtonShuffleDisable"] forState:UIControlStateNormal];
        [self.shuffleButton setImage:[UIImage imageNamed:@"PlayerButtonShuffleSelected"] forState:UIControlStateSelected];

        [self.shuffleButton addTarget:self action:@selector(actionShuffle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shuffleButton];
        
        UIButton* nextButton = [[UIButton alloc] init];
        nextButton.translatesAutoresizingMaskIntoConstraints = NO;
        [nextButton setImage:[UIImage imageNamed:@"PlayerButtonNext"] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextButton];
        
        UIButton* prevButton = [[UIButton alloc] init];
        prevButton.translatesAutoresizingMaskIntoConstraints = NO;
        [prevButton addTarget:self action:@selector(actionPrev) forControlEvents:UIControlEventTouchUpInside];
        [prevButton setImage:[UIImage imageNamed:@"PlayerButtonPrevious"] forState:UIControlStateNormal];
        [self addSubview:prevButton];
        
        
        self.playButton = [[UIButton alloc] init];
        self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.playButton setImage:[UIImage imageNamed:@"PlayerButtonPlay"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"PlayerButtonPlay"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"PlayerButtonPause"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"PlayerButtonPause"] forState:UIControlStateSelected];
        [self.playButton addTarget:self action:@selector(actionPlay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        UIView *spacerView = [UIView new];
        spacerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:spacerView];
        
        
        NSDictionary *views = @{ @"view": self,
                                 @"hideButton": self.hideButton,
                                 @"likeButton": self.likeButton,
                                 @"shareButton": self.shareButton,
                                 @"addButton": self.addButton,
                                 @"mediaContainer": self.mediaContainer,
                                 @"titleButton": self.titleButton,
                                 @"separator": separator,
                                 @"playlistButton": self.playlistButton,
                                 @"durationCurrentLabel": self.durationCurrentLabel,
                                 @"seekBar": self.seekBar,
                                 @"durationTotalLabel": self.durationTotalLabel,
                                 @"nextButton": nextButton,
                                 @"playButton": self.playButton,
                                 @"prevButton": prevButton,
                                 @"shuffleButtton": self.shuffleButton,
                                 @"spacerView": spacerView,
                                };
        
        
        NSNumber *height = [NSNumber numberWithFloat:[[UIScreen mainScreen ] bounds ].size.height - 340];
        
        NSDictionary *metrics = @{@"mediaHeight": height, @"controlWidth": [NSNumber numberWithFloat:self.frame.size.width / 5],
                                  @"paddingWidth": @11.0, @"seekBarPadding": @5.0, @"paddingHeight": @8.0, @"addSpaceSeparator": addSpaceSeparator};
        
        //NAVBAR

        [self addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|[hideButton(50)][shareButton(50)][likeButton(50)]-addSpaceSeparator-[addButton]-11-|"
                             options: NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                             metrics:metrics
                              views:views]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|[mediaContainer]|"
                              options: 0
                              metrics:0
                              views:views]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-paddingWidth-[titleButton]-paddingWidth-|"
                              options: 0
                              metrics:metrics
                              views:views]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-112-[separator]-112-|"
                              options: 0
                              metrics:metrics
                              views:views]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-paddingWidth-[playlistButton]-paddingWidth-|"
                              options: 0
                              metrics:metrics
                              views:views]];
 
        
        [self addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:|-[hideButton]-[mediaContainer(mediaHeight)]-paddingHeight-[titleButton(60)][separator(1)][playlistButton(32)]-paddingHeight-[durationCurrentLabel(25)][shuffleButtton(115)]|"
                             options: 0
                             metrics:metrics
                              views:views]];
        
        //seekbar
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-paddingWidth-[durationCurrentLabel]-seekBarPadding-[seekBar]-seekBarPadding-[durationTotalLabel]-paddingWidth-|"
                              options: NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                              metrics:metrics
                              views:views]];
        
        //Control Buttons
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|[shuffleButtton(controlWidth)][prevButton(controlWidth)][playButton(controlWidth)][nextButton(controlWidth)][spacerView(controlWidth)]|"
                              options: NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                              metrics:metrics
                              views:views]];
        
        //BG BUTTOn
        
        [self.addButton setNeedsLayout];
        [self.addButton layoutIfNeeded];
        frame.size.width = self.addButton.frame.size.width ;
        frame.size.height = 30;
        frame.origin.y = (self.addButton.frame.size.height - 30)/2;
        backgroundButton.frame = frame;

 
  
    }
    return self;
}

- (void)setTrack:(WDTrack *)track
{
    
    if(self.track && track == self.track )
    {
        [self updatePosition:[[WDPlayerManager manager] currentPosition]];
    }else
    {
        _track = track;
        
        GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
        overlay.delegate = self;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
        [self.mediaContainer addGestureRecognizer:longPress];
        self.mediaContainer.userInteractionEnabled = YES;
        
        NSURL* imageUrl = [NSURL URLWithString:self.track.imageUrl];
        [self.mediaContainer sd_setImageWithURL:imageUrl];
        
        

        self.sourceImageView.hidden = YES;

        
    
        
        //MOVIE
//        if (track.type == TrackTypeVideo) {
//            self.mediaContainer.backgroundColor = UICOLOR_BLACK;
//            [[WDPlayerManager manager] displayMovieInMovieContainer];
//        }else
//        {
//            self.mediaContainer.backgroundColor = UICOLOR_CLEAR;
//        }
        
        [self.titleButton setTitle:self.track.name forState:UIControlStateNormal];
        
        
        [self updateButtonLike];

//        //MEDIA CONTAINER
//        if (self.mediaView) {
//            [self.mediaView removeFromSuperview];
//            self.mediaView = nil;
//        }
        

        
        
        //PLAYLIST
        Playlist *currentPlaylist = [WDPlayerManager manager].playlist;
        [self.playlistButton setTitle:[currentPlaylist.name uppercaseString] forState:UIControlStateNormal];
        if (currentPlaylist.shuffleEnable) {
            self.shuffleButton.selected = IS_SHUFFLING;
        }else
        {
            //NO HIDE BUT DISABLE FOR STREAMS
            self.shuffleButton.selected = NO;
        }
        


       // [self displayMedia];
    }
    
    
    
}

- (void) displayMedia
{
//    
//    CALayer *videoLayer = [WDPlayerManager manager].videoLayer;
//    if (videoLayer) {
//        NSLog(@"FRAME %f %f %f %f", self.mediaContainer.frame.origin.x,self.mediaContainer.frame.origin.y,self.mediaContainer.frame.size.width, self.mediaContainer.frame.size.height);
//        [videoLayer setFrame:self.mediaContainer.bounds];
//        [self.mediaContainer.layer addSublayer:videoLayer];
//    }
//  
    
//    
//    if(self.track.mediaContainer)
//    {
//        if (self.mediaView) {
//            [self.mediaView removeFromSuperview];
//            self.mediaView = nil;
//        }
//        
//        if(self.track.sourceKey == WDSourceYoutubeWebView)
//        {
//            self.mediaView = [WDPlayerSourceYoutubeWebView player].movieContainer;
//        }else
//        {
//            self.mediaView = self.track.mediaContainer;
//        }
//        
//        [self.mediaContainer addSubview:self.mediaView];
//        self.fullScreenButton.hidden = NO;
//        
//    }
//    
//    self.mediaView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.mediaView.contentMode = UIViewContentModeScaleAspectFit;
//    NSDictionary *views = @{ @"mediaView": self.mediaView,
//                             };
//    [self.mediaContainer addConstraints:[NSLayoutConstraint
//                                         constraintsWithVisualFormat:@"H:|[mediaView]|"
//                                         options: NSLayoutFormatAlignAllCenterX | NSLayoutFormatAlignAllCenterY
//                                         metrics:0
//                                         views:views]];
//    [self.mediaContainer addConstraints:[NSLayoutConstraint
//                                         constraintsWithVisualFormat:@"V:|[mediaView]|"
//                                         options: NSLayoutFormatAlignAllCenterX | NSLayoutFormatAlignAllCenterY
//                                         metrics:0
//                                         views:views]];
//    //ORIENTATION
//    if (![self.mediaView isKindOfClass:[UIImageView class]])
//    {
//        
//        self.orientationAccepted = YES;
//        
//        if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft ||  [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight )
//        {
//            [self actionFullScreen];
//        }
//    }else
//    {
//        self.orientationAccepted = NO;
//
//       
//        if (self.isInFullScreen  && ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft ||  [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight ))
//        {
//            
//            UIDeviceOrientation saveOrientation = [[UIDevice currentDevice] orientation];
//            if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//                objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),   UIInterfaceOrientationPortrait );
//            }
//             [self actionFullScreenExit];
//       
//            
//            if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//                objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    saveOrientation );
//            }
//        }
//    }
}



#pragma mark ACTIONS

- (void) show
{
    self.hidden = NO;
    

    [self updateTrack];

  //  [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(notificationOrientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrack) name:WDPlayerManagerStartTrack object:nil];
    [self addObserver:self forKeyPath:@"track.state" options:NSKeyValueObservingOptionNew context:NULL];
    [self updateState];

}

- (void) actionHide
{
    
    if([[WDPlayerManager manager].currentTrack.sourceKey isEqualToString:WDSourceYoutube]){
        [self play:NO];
    }
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if([self.delegate respondsToSelector:@selector(playerViewDismissed)])
    {
        
        [self.delegate playerViewDismissed];
    }
    
    [self removeObserver:self forKeyPath:@"track.state"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)actionAddNavBar
{
    [Flurry logEvent:FLURRY_ADD_FROM_PLAYER_NAVBAR];
    [self actionAdd];
}

- (void)actionAdd
{

    EditTrackViewController* vc = [[EditTrackViewController alloc] initWithTrack:self.track fromPLaylist:[WDPlayerManager manager].playlist];
    vc.delegate = self;
    vc.isNew = YES;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [[MainViewController manager].navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)actionLikeNavBar
{
    [Flurry logEvent:FLURRY_LIKE_FROM_PLAYER_NABARBUTTON];
    [self actionLike];
}

- (void)actionLike
{
    if(self.track.id)
    {
        NSDictionary *parameters = @{@"pId": self.track.id};
        
        //CREATE SYSTEM TO AVOID A LOT OF REQUEST
        self.track.isLiked = !self.track.isLiked;
        [self updateButtonLike];
        
        [[WDClient client] GET:@"/api/post?action=toggleLovePost" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
   
}

- (void) actionShare
{
    self.shareSheet = [WDShareSheet showInController:[MainViewController manager] withTrack:self.track dismiss:^(NSString *message) {
        self.shareSheet = nil;
        if (message) {
            [WDMessage showMessage:message inView:self withTopMargin:NO withBackgroundColor:WDCOLOR_GREEN];
        }
    }];
}



- (void) actionGoToTrack
{
    if([self.delegate respondsToSelector:@selector(playerViewDismissedWithCurrentTrack:)])
    {
        [self.delegate playerViewDismissedWithCurrentTrack:self.track];
    }
}

- (void) actionShuffle
{
    Playlist *currentPlaylist = [WDPlayerManager manager].playlist;
    if (currentPlaylist.shuffleEnable) {
        Playlist *currentPlaylist = [WDPlayerManager manager].playlist;
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_SHUFFLE_MODE])
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_SHUFFLE_MODE];
            self.shuffleButton.selected = NO;
            currentPlaylist.currentPIndex = self.track.index;
        }else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:USERDEFAULT_SHUFFLE_MODE];
            self.shuffleButton.selected = YES;
            if (currentPlaylist.currentPIndex > -1) {
                [currentPlaylist shufflingTracks];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else
    {
        [WDMessage showMessage:NSLocalizedString(@"ShuffleOnlyInPlaylist", nil) inView:self withTopMargin:YES];
    }

    DLog(@"SHUFFLE");
}


- (void) actionNext
{
    [[WDPlayerManager manager] actionNext];
}

- (void) actionPrev
{
    [[WDPlayerManager manager] actionPrev];
}




- (void)actionFullScreen
{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    [[UIDevice currentDevice] orientation] );
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(notificationExitFullscreen)
//                                                 name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[WDPlayerManager manager] setFullscreen:YES animated:NO];
    self.isInFullScreen = YES;
 

}
- (void)actionFullScreenExit
{
    [[WDPlayerManager manager] setFullscreen:NO animated:NO];
    self.isInFullScreen = NO;

}


- (void) actionPlay
{
    if (self.track.state == TrackStatePause) {
        [self play:YES];
    }
    else{
        [self play:NO];
        
    }
}

- (void)play:(BOOL)isPlaying
{
    if (isPlaying) {
        [[WDPlayerManager manager] play];
    }else{
         [[WDPlayerManager manager] pause];
    }
}



- (IBAction)seekBarTouchUp:(UISlider *)sender {
    
    [self.seekBar setValue:sender.value animated:YES];
    [[WDPlayerManager manager] seekTo:sender.value];
    self.seekBarIsDragged = NO;
}

- (IBAction)seekBarIsDragged:(UISlider *)sender {
    self.seekBarIsDragged = YES;

}

- (IBAction)seekBarValueChanged:(UISlider *)sender
{
    self.durationCurrentLabel.text = [WDHelper stringDurationFromFloat:sender.value];
}

- (void)setIsInFullScreen:(BOOL)isInFullScreen
{
    _isInFullScreen = isInFullScreen;
    if (!isInFullScreen) {
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    }
}
#pragma -mark Notifications

//- (void) notificationExitFullscreen
//{
//    if (self.isInFullScreen) {
//       // [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
//        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationPortrait );
//        }
//        self.isInFullScreen = NO;
//    }
//
//    
//}

//- (void) notificationOrientationChanged:(NSNotification*)notification
//{
//    if ( self.orientationAccepted) {
//        if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
//            [self actionFullScreenExit];
//        }else if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft ||  [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight)
//        {
//            [self actionFullScreen];
//        }
//    }
//
//}

- (void)updatePosition:(float)position
{

    if (self.seekBar.maximumValue  == 1.0 || self.seekBar.maximumValue  == 0.0) {
        [self updateTotalDuration:self.track.totalDutation];
    }
    
    if (self.hidden) return;
    
    if (!self.seekBarIsDragged) {
     
        if(!self.seekBarIsDragged)
        {
            [self.seekBar setValue:position animated:YES];
        }
        self.durationCurrentLabel.text = [WDHelper stringDurationFromFloat:position];
    }

    
}

- (void)updateTotalDuration:(float)duration
{

    if (self.hidden) return;
    if(!isnan(duration) && duration > 0.)
    {
        [self.seekBar setMaximumValue:duration];
        self.durationTotalLabel.text = [WDHelper stringDurationFromFloat:duration];
    }
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    [self updateState];
    
}

- (void)updateTrack
{
    self.seekBar.value = 0;
    self.seekBar.maximumValue = 1.0;
    self.durationTotalLabel.text = @"-:--";
    self.durationCurrentLabel.text = @"-:--";
    
    self.track = [WDPlayerManager manager].currentTrack;
    if ([WDPlayerManager manager].sourceType == WDPlayerSourceTypeVideo) {
        self.orientationAccepted = YES;
    }else
    {
        self.orientationAccepted = NO;
    }
    
}

- (void)updateButtonLike
{
//    NSString *notifString;
//    if (self.track.isLiked) {
//        notifString = NSLocalizedString(@"TrackLiked", nil);
//    }else
//    {
//        notifString = NSLocalizedString(@"TrackUnliked", nil);
//    }
//    [WDMessage showMessage:notifString inView:self withTopMargin:YES];
    
    self.likeButton.selected = self.track.isLiked;

}

- (void)updateState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (self.track.state) {
            case TrackStateLoading:
            {
                
                [self.spinner startAnimating];
                [self.mediaContainer bringSubviewToFront:self.spinner];
                
                    self.playButton.selected = NO;
               
            }
                break;
            case TrackStateStop:
            {
                self.playButton.selected = NO;
                [self.seekBar setValue:0.];
                self.durationTotalLabel.text = self.durationCurrentLabel.text = @"-:--";
            
            }
                break;
            case TrackStatePlay:
            {
                if ([self.spinner isAnimating]) {
                    [self.spinner stopAnimating];
                }

                self.playButton.selected = YES;
              
            }
                break;
            case TrackStatePause:
            {

                    self.playButton.selected = NO;
          
                
            }
                break;
            case TrackStateUnavailable:
            {

            }
                break;
                
        }
        
    });

}



#pragma mark GHContextMenu Delegate


- (void)didSelectItemType:(MenuActionType)type
{
    
    switch (type) {
        case MenuActionTypeAdd:
            [self actionAdd];
            break;
        case MenuActionTypeLike:
            [Flurry logEvent:FLURRY_LIKE_FROM_PLAYER_LONGTAP];
            [self actionLike];
            
            break;

        case MenuActionTypeEdit:
//            if ([self.delegate respondsToSelector:@selector(trackCell:editTrack:)]) {
//                [self.delegate trackCell:self editTrack:self.track];
//            }
            break;
        case MenuActionTypeShare:
            [self actionShare];
            break;
            
        default:
            break;
    }
}




@end
