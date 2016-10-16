//
//  RegisterViewController.m
//  Whyd
//
//  Created by Damien Romito on 08/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "RegisterViewController.h"
#import "WDHelper.h"
#import "WDActivityIndicatorView.h"
#import "OnboardingGenresViewController.h"

@interface RegisterViewController ()
@property (nonatomic,strong) WDTextField *fullnameTextField;
@property (nonatomic,strong) WDTextField *usernameTextField;
@property (nonatomic,strong) WDTextField *emailTextField;
@property (nonatomic,strong) WDTextField *passwordTextField;
@property (nonatomic) NSString *errorString;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSTimer *usernameCheckTimer;
@end

@implementation RegisterViewController

- (instancetype)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}



- (void)loadView
{
    [super loadView];
    
    
    self.view.backgroundColor = WDCOLOR_WHITE;

    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    self.title = [NSLocalizedString(@"SignUp", nil) uppercaseString];
    
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionNext)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    
    
    
    
    ////
    self.fullnameTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, 18, self.view.frame.size.width, 46)];
    self.fullnameTextField.returnKeyType = UIReturnKeyNext;
    self.fullnameTextField.delegate = self;
    self.fullnameTextField.labelString = NSLocalizedString(@"FullName", nil);
    if (self.user) {
        self.fullnameTextField.text = self.user.name;
        [self WDTextField:self.fullnameTextField didChangeWithString:self.fullnameTextField.text];
    }
    self.fullnameTextField.placeholder = NSLocalizedString(@"soYourFriendFindYou", nil);

    [self.view addSubview:self.fullnameTextField];
    
    self.usernameTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0,  self.fullnameTextField.frame.size.height + self.fullnameTextField.frame.origin.y + 1, self.view.frame.size.width, 46)];
    self.usernameTextField.returnKeyType = UIReturnKeyNext;
    self.usernameTextField.delegate = self;
    self.usernameTextField.labelString = NSLocalizedString(@"Username", nil);
    if (self.user) {
        self.usernameTextField.text = self.user.handle;
        [self WDTextField:self.usernameTextField didChangeWithString:self.user.handle];
    }
    self.usernameTextField.text =@"DAM";

    [self.view addSubview:self.usernameTextField];
    
    self.emailTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, self.fullnameTextField.frame.size.height + self.fullnameTextField.frame.origin.y + 1, self.view.frame.size.width, 46)];
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.delegate = self;
    self.emailTextField.labelString = NSLocalizedString(@"Email", nil);
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.emailTextField.placeholder = NSLocalizedString(@"WeDontSpam", nil);
    self.emailTextField.errorString = NSLocalizedString(@"ThisIsNotAnEmail", nil);
    if (self.user && self.user.email) {
        self.emailTextField.text = self.user.email;
        [self WDTextField:self.emailTextField didChangeWithString:self.user.email];
    }
    self.emailTextField.text =@"test@test.com";

    [self.view addSubview:self.emailTextField];
    
    self.passwordTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, self.emailTextField.frame.origin.y + 1 + self.emailTextField.frame.size.height, self.view.frame.size.width, 46)];
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.delegate = self;
    self.passwordTextField.labelString = NSLocalizedString(@"Password", nil);
    self.passwordTextField.placeholder = self.passwordTextField.errorString = NSLocalizedString(@"AtLeast4Characters", nil);
    self.passwordTextField.labelString = NSLocalizedString(@"Password", nil);
    [self.passwordTextField setSecureTextEntry:YES];
    self.passwordTextField.isPassword = YES;
    [self.view addSubview:self.passwordTextField];
    self.passwordTextField.text =@"azerty";
    
    
    UIButton *agreement = [[UIButton alloc] initWithFrame:CGRectMake(50, 230, self.view.frame.size.width - 100, 40)];
    agreement.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
    [agreement setTitleColor:RGBCOLOR(137, 141, 148) forState:UIControlStateNormal];
    agreement.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [agreement setTitle:NSLocalizedString(@"ByContinuingIAgree", nil) forState:UIControlStateNormal];
    agreement.titleLabel.textAlignment = NSTextAlignmentCenter;
    [agreement addTarget:self action:@selector(actionAgreement) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreement];
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.backgroundColor = UICOLOR_WHITE;
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO ];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
}

- (void)actionAgreement
{
    NSURL *link = [NSURL URLWithString:@"http://openwhyd.org/tos/"];
    [[UIApplication sharedApplication] openURL:link];
}

- (void)actionNext
{
    
    if (!self.fullnameTextField.text.length || !self.emailTextField.text.length || !self.passwordTextField.text.length) {
        self.errorString = NSLocalizedString(@"PleaseFillInAllFields", nil);
    }
    
    if (self.errorString) {
        [self actionErrorWithText:self.errorString];
    }else
    {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           self.fullnameTextField.text, @"name",
                                           self.emailTextField.text, @"email" ,
                                           self.passwordTextField.text,@"password",
//                                           self.usernameTextField.text,@"username",
                                           @1, @"ajax",
                                           @"iPhoneApp", @"iRf",
                                           nil];

        if (self.user) {
            [parameters setValue:self.user.fbId forKeyPath:@"fbUid"];
            [parameters setValue:self.user.fbTok forKeyPath:@"fbTok"];
        }

        DLog(@"PARAM %@", parameters);
        [self.loadingView startAnimating];
        [WDHelper registerWithParameters:parameters success:^(User *user) {
            [User saveAsCurrentUser:user];

            [self loginSuccess];
            
            

        } failure:^(NSError *error) {
            
            [self actionErrorWithText:error.localizedDescription];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
//                                                            message:NSLocalizedString(@"WantYouLinkeYourFacebookToThisExistingAccount", nil)
//                                                           delegate:self
//                                                  cancelButtonTitle:NSLocalizedString(@"No", nil)
//                                                  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
//            [alert show];
            [self.loadingView stopAnimating];
        }];
        
    }
}

- (void) loginSuccess
{
    
    OnboardingGenresViewController *onboardingGenre = [[OnboardingGenresViewController alloc] init];
    [self.navigationController pushViewController:onboardingGenre animated:YES];
    [self.loadingView stopAnimating];

}


- (void)actionErrorWithText:(NSString*)errorString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wait!", nil)
                                                    message:errorString
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    
//    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//
//    if([title isEqualToString:NSLocalizedString(@"No", nil)])
//    {
//       
//    }
//    else if([title isEqualToString:NSLocalizedString(@"Yes", nil)])
//    {
//        
//        [self linkFacebookAccountToExistingAccount];
//    }
//}
//
//- (void)linkFacebookAccountToExistingAccount
//{
//    NSString *md5 = [WDHelper stringToMd5:self.passwordTextField.text];
//    
//    NSDictionary* parameters = @{@"email": self.emailTextField.text,
//                                 @"md5":md5,
//                                 @"fbUid":self.user.fbId ,
//                                 @"fbTok": self.user.fbTok,
//                                 @"update":@1
//                                 };
//    
//    [self.loadingView startAnimating];
//    [WDHelper loginWithParameters:parameters success:^{
//        
//        [self.loadingView stopAnimating];
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGIN_SUCCESS object:self];
//        
//    } failure:^(NSError *error) {
//        [self.loadingView stopAnimating];
//        [self actionErrorWithText:error.localizedDescription];
//    }];
//}

#pragma -mark TextField Delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == self.fullnameTextField) {
        [self.emailTextField becomeFirstResponder];
//    }else if (textField == self.usernameTextField)
//    {
//        [self.emailTextField becomeFirstResponder];
    }else if (textField == self.usernameTextField)
    {
        [self.emailTextField becomeFirstResponder];
    }else if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }else if (textField == self.passwordTextField)
    {
        [self actionNext];
        [self.view endEditing:YES];
    }
    
    return YES;
}



- (void)WDTextField:(WDTextField *)textField didChangeWithString:(NSString *)string
{
    //FULLNAME
    if (textField == self.fullnameTextField) {
        
        [self textField:textField IsSuccess:(textField.text.length>0)];
        
    }
    
    //USERNAME
    if (textField == self.usernameTextField) {
        if (self.usernameCheckTimer) {
            [self.usernameCheckTimer invalidate];
        }
        
        
        if ([self textField:textField IsSuccess:[WDHelper usernameIsValide:textField.text]]) {
            self.errorString = nil;
        }else
        {
            self.errorString = NSLocalizedString(@"A least 2 char", nil);
        }
        
//        if (textField.state != WDTextFieldStateFailed )
//        {
//            self.usernameCheckTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(usernameCheck) userInfo:nil repeats:NO];
//            self.errorString = nil;
//        }else if(textField.textFieldState == WDTextFieldStateLoading)
//        {
//            self.errorString = @"Wait! We haven't valide your username";
//        }else{
//            self.errorString = nil;
//        }
        
    }
    
    //EMAIL
    if (textField == self.emailTextField) {
        [self textField:textField IsSuccess:[WDHelper emailIsValide:textField.text]];
    }
    
    
    //PASSWORD
    if (textField == self.passwordTextField) {
        [self textField:textField IsSuccess:[WDHelper passwordIsValide:textField.text]];
    }
    

}

- (BOOL) textField:(WDTextField *)textField IsSuccess:(BOOL)isSuccess
{
    if(isSuccess)
    {
        textField.textFieldState = WDTextFieldStateSuccess;
        self.errorString = nil;
    }else
    {
        textField.textFieldState = WDTextFieldStateFailed;
        self.errorString = textField.errorString;
    }
    return isSuccess;
}





- (void) usernameCheck
{
    DLog(@"CHECK");
    self.errorString = NSLocalizedString(@"WeHaventValidateYourUsername", nil);

}


- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING REGISTER");
    [super didReceiveMemoryWarning];
}

@end
