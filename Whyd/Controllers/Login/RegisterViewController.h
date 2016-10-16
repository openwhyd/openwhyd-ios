//
//  RegisterViewController.h
//  Whyd
//
//  Created by Damien Romito on 08/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDTextField.h"
#import "User.h"

@interface RegisterViewController : UIViewController<WDTextFieldDelegate>

- (instancetype)initWithUser:(User *)user;

@end
