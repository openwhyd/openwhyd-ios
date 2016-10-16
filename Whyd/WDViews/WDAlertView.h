//
//  WDAlertView.h
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//


typedef NS_ENUM(NSUInteger, WDAlertType) {
    WDAlertTypeAPN = 1,
	WDAlertTypeRate = 2,
    WDAlertTypeUpdate = 3,
    WDAlertTypeInfo = 4,

};

@interface WDAlertView : UIView

@property (nonatomic, weak) id delegate;

+ (WDAlertView *)showWithType:(WDAlertType)type;
+ (WDAlertView *)showWithType:(WDAlertType)type andInfoString:(NSString*)infoString;
+ (WDAlertView *)showWithType:(WDAlertType)type title:(NSString*)title andInfoString:(NSString*)infoString;

@end

@protocol WDAlertViewDelegate <NSObject>

- (void)WDAlertViewClosed;

@end