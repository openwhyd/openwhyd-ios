//
//  GHContextOverlayView.h
//  GHContextMenu
//
//  Created by Tapasya on 27/01/14.
//  Copyright (c) 2014 Tapasya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GHContextMenuActionType){
    // Default
    GHContextMenuActionTypePan,
    // Allows tap action in order to trigger an action
    GHContextMenuActionTypeTap
};

typedef NS_ENUM(NSUInteger, MenuActionType) {
    MenuActionTypeAdd = 0,
	MenuActionTypeLike = 1,
    MenuActionTypeEdit = 2,
    MenuActionTypeShare= 3,
};

@protocol GHContextOverlayViewDataSource;
@protocol GHContextOverlayViewDelegate;

@interface GHContextMenuView : UIView

@property (nonatomic, assign) id<GHContextOverlayViewDelegate> delegate;

@property (nonatomic, assign) GHContextMenuActionType menuActionType;
@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL byCurrentUser;
- (void) longPressDetected:(UIGestureRecognizer*) gestureRecognizer;

@end



@protocol GHContextOverlayViewDelegate <NSObject>

@optional
- (void) didSelectItemType:(MenuActionType)type;
- (void) overlayViewIsOpen;
- (void) overlayViewIsClose;
@end
