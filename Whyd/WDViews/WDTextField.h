//
//  WDTextField.h
//  Whyd
//
//  Created by Damien Romito on 08/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum NSUInteger {

    WDTextFieldStateFailed = 0,
    WDTextFieldStateSuccess = 1,
    WDTextFieldStateDefault = 2,
    WDTextFieldStateLoading = 3,
}WDTextFieldState;



@interface WDTextField : UITextField

@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic) BOOL isPassword;
@property (nonatomic) WDTextFieldState textFieldState;
@property (nonatomic) NSString *errorString;
@property (nonatomic) NSString *labelString;

- (instancetype) initWithYPosition:(CGFloat)yPosition;
@end

@protocol WDTextFieldDelegate <UITextFieldDelegate>

@optional
- (void)WDTextField:(WDTextField *)textField didChangeWithString:(NSString *)string;

@end