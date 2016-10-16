//
//  WDActionSheet.h
//  Whyd
//
//  Created by Damien Romito on 09/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDActionSheetDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)clickedButtonWithTitle:(NSString *)titleString;

@end


@interface WDActionSheet : UIView


@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL autoClose;

- (instancetype)initWithTitle:(NSString*)title delegate:(id<WDActionSheetDelegate>)delegate cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles;
- (void) show;
- (void) close:(BOOL)animated;

@end

