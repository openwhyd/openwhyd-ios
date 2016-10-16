//
//  WDLabel.m
//  Whyd
//
//  Created by Damien Romito on 18/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDLabel.h"

@interface WDLabel()
@end

@implementation WDLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}




@end
