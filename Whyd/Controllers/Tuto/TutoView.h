//
//  TutoViewController.h
//  Whyd
//
//  Created by Damien Romito on 11/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//


@interface TutoView : UIView

@property (nonatomic, weak) id delegate;
- (void)show;

@end

@protocol TutoDelegate <NSObject>

- (void) TutoClosed;

@end