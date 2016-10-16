//
//  WDPlayerButton.m
//  Whyd
//
//  Created by Damien Romito on 23/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerButton.h"
#import "UIImage+animatedGIF.h"


@interface WDPlayerButton()
@property (nonatomic, strong) UIImage *nowPlayingGif;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end
@implementation WDPlayerButton


- (instancetype)initWithOrigin:(CGPoint)origin
{
    return [self initWithType:WDPlayerButtonSizeDefault andOrigin:origin];
}

- (instancetype)initWithType:(WDPlayerButtonSize)size andOrigin:(CGPoint)origin
{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, 64, 64)];
    
    if (self) {
     
        
        [self setBackgroundImage:[UIImage imageNamed:@"PostBackgroundPlayNormal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"PostBackgroundPlayActive"] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"PostBackgroundPlayActive"] forState:UIControlStateSelected | UIControlStateHighlighted];
        
        self.contentMode = UIViewContentModeScaleAspectFit;
//        [self setImage:[UIImage imageNamed:@"PostButtonPlay"] forState:UIControlStateNormal];
//        [self setImage:[UIImage imageNamed:@"PostIconNowPlaying"] forState:UIControlStateSelected | UIControlStateHighlighted ];
//        
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.loadingView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.loadingView];

    }
    return self;
}

- (void)setCurrentState:(WDPlayerButtonState)currentState
{
    switch (currentState) {
        case WDPlayerButtonStateLoading:
        {
            [self.loadingView startAnimating];
            self.imageView.hidden = YES;
            [self setImage:[UIImage new] forState:UIControlStateNormal];

        }
            break;
        case WDPlayerButtonStatePause:
        {
            self.selected = NO;
            [self setImage:[UIImage imageNamed:@"PostIconNowPlaying"] forState:UIControlStateNormal];
        }
            break;
        case WDPlayerButtonStatePlay:
        {
            self.selected = YES;
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"PostIconNowPlayingAnimation" withExtension:@"gif"];
            self.imageEdgeInsets = UIEdgeInsetsMake(20, 21, 20, 21);

            self.nowPlayingGif = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
            [self setImage:self.nowPlayingGif forState:UIControlStateSelected ];
        }
            break;
        case WDPlayerButtonStateStop:
        {
            self.selected = NO;
            [self setImage:[UIImage imageNamed:@"PostButtonPlay"] forState:UIControlStateNormal];
        }
            break;
        case WDPlayerButtonStateUnavailable:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"StreamIconIndicationNoStream"] forState:UIControlStateNormal];
            self.selected = NO;
            [self setImage:[UIImage new] forState:UIControlStateNormal];
        }
            break;
    }
    
    if (currentState != WDPlayerButtonStateUnavailable) {
        [self setBackgroundImage:[UIImage imageNamed:@"PostBackgroundPlayNormal"] forState:UIControlStateNormal];
        
    }
    if (currentState != WDPlayerButtonStatePlay) {
        self.imageEdgeInsets = UIEdgeInsetsZero;
    }
    if (currentState != WDPlayerButtonStateLoading && [self.loadingView isAnimating]) {
        [self.loadingView stopAnimating];
        self.imageView.hidden = NO;
    }
 
}



@end
