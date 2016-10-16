//
//  ProfileEditViewController.h
//  Whyd
//
//  Created by Damien Romito on 28/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "User.h"
#import "WDTextField.h"

@interface ProfileEditViewController : UIViewController<UIImagePickerControllerDelegate, WDTextFieldDelegate>
- (instancetype)initWithUser:(User *)user;
@end
