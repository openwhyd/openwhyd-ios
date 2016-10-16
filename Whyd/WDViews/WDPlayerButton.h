//
//  WDPlayerButton.h
//  Whyd
//
//  Created by Damien Romito on 23/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

typedef NS_ENUM(NSUInteger, WDPlayerButtonSize) {
    WDPlayerButtonSizeDefault = 0,
	WDPlayerButtonSizeSmall = 1,
};

typedef NS_ENUM(NSUInteger, WDPlayerButtonState) {
    WDPlayerButtonStateStop = 0,
	WDPlayerButtonStatePause = 1,
    WDPlayerButtonStatePlay = 2,
    WDPlayerButtonStateUnavailable = 3,
    WDPlayerButtonStateLoading = 4,
};

@interface WDPlayerButton : UIButton

@property (nonatomic) WDPlayerButtonState currentState;

- (instancetype)initWithOrigin:(CGPoint)origin;
- (instancetype)initWithType:(WDPlayerButtonSize)size andOrigin:(CGPoint)origin;

@end
