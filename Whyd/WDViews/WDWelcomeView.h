//
//  WDWelcomeView.h
//  Whyd
//
//  Created by Damien Romito on 13/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDWelcomeView : UIView

@property (nonatomic, weak) id delegate;
- (void)show;

@end
@protocol WDWelcomeViewDelegate <NSObject>

@optional
- (void) WDWelcomeViewWillDisappear;

@end
