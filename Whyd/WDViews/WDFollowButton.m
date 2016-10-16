//
//  WDFollowButton.m
//  Whyd
//
//  Created by Damien Romito on 04/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDFollowButton.h" 

@implementation WDFollowButton

- (id)initWithPosition:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, 82, 32)];
    if (self) {
        [self setTitle:NSLocalizedString(@"FollowButtonOff", nil) forState:UIControlStateNormal];
        [self setTitle: NSLocalizedString(@"FollowButtonOn", nil) forState:UIControlStateSelected];
        self.layer.borderWidth = 1.;
        self.layer.cornerRadius = CORNER_RADIUS;
        self.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        self.normalColor = UICOLOR_WHITE;
        self.normalHighlightedColor = RGBCOLOR(206, 207, 208);
        self.selectedColor = WDCOLOR_BLACK_LIGHT2;
        self.selectedHighlightedColor = WDCOLOR_GRAY_DARK2;
        [self addTarget:self action:@selector(actionHightlight) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(actionUnHightlight) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(actionUnHightlight) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

- (void)actionHightlight
{
    if (self.selected) {
        self.layer.borderColor = self.selectedHighlightedColor.CGColor;
    }else
    {
        self.layer.borderColor = self.normalHighlightedColor.CGColor;
    }
}


- (void) actionUnHightlight
{
    if (!self.selected) {
        self.layer.borderColor = self.normalColor.CGColor;
    }else
    {
        self.layer.borderColor = self.selectedColor.CGColor;
    }
}


- (void)setSelected:(BOOL)selected
{
    
    [super setSelected:selected];

    if (selected) {
        self.layer.borderColor = self.selectedColor.CGColor;
    }else
    {
        self.layer.borderColor = self.normalColor.CGColor;
    }
    
}

- (void)setNormalHighlightedColor:(UIColor *)normalHighlightedColor
{
    _normalHighlightedColor = normalHighlightedColor;
    [self setTitleColor:normalHighlightedColor forState:UIControlStateNormal | UIControlStateHighlighted];

}

- (void)setSelectedHighlightedColor:(UIColor *)selectedHighlightedColor
{
    _selectedHighlightedColor = selectedHighlightedColor;
    [self setTitleColor:selectedHighlightedColor forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    self.layer.borderColor = normalColor.CGColor;
    [self setTitleColor:normalColor forState:UIControlStateNormal];

}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
}


@end
