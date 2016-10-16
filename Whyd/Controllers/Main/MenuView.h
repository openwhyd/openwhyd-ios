//
//  MenuView.h
//  Whyd
//
//  Created by Damien Romito on 19/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuView : UIView

@property (nonatomic) NSUInteger notifsCount;

- (void)actionOpen;
- (void)actionClose;
- (void)selectButtonAtIndex:(NSUInteger)index;
@end
