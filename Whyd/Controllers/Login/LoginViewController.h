//
//  LoginViewController.h
//  Whyd
//
//  Created by Damien Romito on 05/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//
//#import <FacebookSDK/FBLoginView.h>
#import "WDTextField.h"



@interface LoginViewController : UIViewController<UITextFieldDelegate/*,FBLoginViewDelegate*/>
@property (nonatomic, weak) id delegate;
@end

@protocol LoginDelegate <NSObject>

- (void) loginWithSuccess;

@end
