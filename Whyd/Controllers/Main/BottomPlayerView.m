//
//  BottomPlayerView.m
//  Whyd
//
//  Created by Damien Romito on 13/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "BottomPlayerView.h"
#import "MainViewController.h"

@interface BottomPlayerView()
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UILabel *trackLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) WDTrack *track;

@end
@implementation BottomPlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:[MainViewController manager] action:@selector(actionOpenPlayer)];
        [self addGestureRecognizer:tap];
        self.backgroundColor = WDCOLOR_BLACK;

        UISwipeGestureRecognizer *leftGesture =  [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionNext)];
        [self addGestureRecognizer:leftGesture];
        leftGesture.direction =UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *rightGesture =  [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionPrev)];
        [self addGestureRecognizer:rightGesture];
        rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
        
        self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [self.playButton setImage:[UIImage imageNamed:@"BottomPlayerPlay"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"BottomPlayerPause"] forState:UIControlStateSelected];
        self.playButton.contentMode = UIViewContentModeCenter;
        [self.playButton addTarget:self action:@selector(actionPlay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.spinner.frame = self.playButton.frame;
        self.spinner.color = UICOLOR_WHITE;
        [self addSubview:self.spinner];
        
        self.trackLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 0 , 260, 45)];
        self.trackLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        [self.trackLabel setTextColor:UICOLOR_WHITE];
        [self addSubview:self.trackLabel];
        
        [self addObserver:self forKeyPath:@"track.state" options:NSKeyValueObservingOptionNew context:NULL];

    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateState];
}

- (void)updateTrack
{
    self.track = [WDPlayerManager manager].currentTrack;
    self.trackLabel.text = self.track.name;
}

- (void)updateState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch ([WDPlayerManager manager].currentTrack.state) {
            case TrackStateLoading:
            {
                if (!self.playButton.hidden) {
                    self.playButton.hidden = YES;
                    [self.spinner startAnimating];
                }
                
            }
                break;
            case TrackStateStop:
            {
                
                
            }
                break;
            case TrackStatePlay:
            {
                if (self.playButton.hidden) {
                    [self.spinner stopAnimating];
                    self.playButton.hidden = NO;
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

- (void) actionPlay
{
    if (self.track.state == TrackStatePause) {
        [[WDPlayerManager manager] play];
    }
    else{
        [[WDPlayerManager manager] pause];
        
    }
}

- (void)actionPrev
{
    [[WDPlayerManager manager] actionPrev];
}

- (void)actionNext
{
    [[WDPlayerManager manager] actionNext];
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"track.state"];
}


@end
