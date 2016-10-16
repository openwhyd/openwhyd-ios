//
//  WDFollowButton.h
//  Whyd
//
//  Created by Damien Romito on 04/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDFollowButton : UIButton
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedHighlightedColor;
@property (nonatomic, strong) UIColor *normalHighlightedColor;

- (id)initWithPosition:(CGPoint)position;

@end
