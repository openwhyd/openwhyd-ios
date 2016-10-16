//
//  LoginViewController.m
//  Whyd
//
//  Created by Damien Romito on 05/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "LoginViewController.h"
#import "WDClient.h"
#import "User.h"
#import "WDHelper.h"
#import "UIImage+Additions.h"
#import "RegisterViewController.h"
#import "PasswordForgotViewController.h"
#import "WDMessage.h"
#import "WDFacebookHelper.h"

@interface LoginViewController ()
@property (nonatomic,strong) WDTextField *emailTextField;
@property (nonatomic,strong) WDTextField *passwordTextField;
@property (nonatomic,strong) UIButton *hideShowButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *infoUsername;
@property (nonatomic) NSString *errorString;

@property (nonatomic, strong) User *tempFacebookUser;
@end

@implementation LoginViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = [NSLocalizedString(@"Login", nil) uppercaseString];
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.backgroundColor = UICOLOR_WHITE;
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO ];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
}


- (void)loadView {

    [super loadView];
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    self.view.backgroundColor = WDCOLOR_WHITE;
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapView)];
    [self.view addGestureRecognizer:tapView];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionDone)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 77)];
    welcomeLabel.textColor = RGBCOLOR(50, 50, 50);
    welcomeLabel.text = [NSLocalizedString(@"WelcomeBack", nil) uppercaseString];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_5];
    [self.view addSubview:welcomeLabel];
    
    
    
    NSLog(@"WIDTH %f",self.view.frame.size.width);

    self.emailTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, welcomeLabel.frame.size.height, self.view.frame.size.width, 46)];
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.delegate = self;

    self.emailTextField.labelString = NSLocalizedString(@"Email", nil);
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.emailTextField.placeholder = NSLocalizedString(@"orYourUsername", nil);
    self.emailTextField.errorString = NSLocalizedString(@"EnterYourEmailOrYourUsername",nil);
    [self.view addSubview:self.emailTextField];

    
    self.passwordTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, self.emailTextField.frame.origin.y + 1 + self.emailTextField.frame.size.height, self.view.frame.size.width, 46)];
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.delegate = self;
    self.passwordTextField.labelString = NSLocalizedString(@"Password", nil);
    [self.passwordTextField setSecureTextEntry:YES];
    self.passwordTextField.isPassword = YES;
    self.passwordTextField.errorString = NSLocalizedString(@"PasswordFormatIncorrect", nil);
    [self.view addSubview:self.passwordTextField];

    
    UIButton *forgotButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.passwordTextField.frame.origin.y + 23 + self.passwordTextField.frame.size.height, self.view.frame.size.width, 20)];
    [forgotButton setTitle:NSLocalizedString(@"ForgotYourPassword", nil) forState:UIControlStateNormal];
    [forgotButton setTitleColor:WDCOLOR_BLACK_LIGHT forState:UIControlStateNormal];
    forgotButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    [forgotButton addTarget:self action:@selector(actionForgotPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgotButton];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 263, self.view.frame.size.width, 0.5)];
    separator.backgroundColor = WDCOLOR_GRAY_LIGHT_BLUE;
    [self.view addSubview:separator];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(11, 290, self.view.frame.size.width - 22, 44)];
    [facebookButton setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(60, 89, 155)] forState:UIControlStateNormal];
    [facebookButton setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(91, 122, 192)] forState:UIControlStateHighlighted];
    facebookButton.layer.cornerRadius = CORNER_RADIUS;
    facebookButton.clipsToBounds = YES;
    [facebookButton setImage:[UIImage imageNamed:@"LoginIconFacebook"] forState:UIControlStateNormal];
    facebookButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [facebookButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
    facebookButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    [facebookButton setTitle:[NSLocalizedString(@"SignUpWithFacebook", nil) uppercaseString] forState:UIControlStateNormal];
    [facebookButton.titleLabel sizeToFit];
    facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    facebookButton.titleEdgeInsets = UIEdgeInsetsMake(2,self.view.frame.size.width/2 - 11 - facebookButton.titleLabel.frame.size.width/2, 0, 0);
    [facebookButton addTarget:self action:@selector(actionFacebook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
    self.loadingView.layer.cornerRadius = 5;
    self.loadingView.frame = CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height/2 - 80, 80, 80);
    [self.view addSubview:self.loadingView];

}


#pragma mark Actions

- (void)actionTapView
{
    if (self.passwordTextField.isFirstResponder)
    {
        [self.passwordTextField resignFirstResponder];
    }else if (self.emailTextField.isFirstResponder)
    {
        [self.emailTextField resignFirstResponder];
    }
}


- (void)actionHideShowPassword
{
    UIButton *hideShow = (UIButton *)self.passwordTextField.rightView;
    if (!self.passwordTextField.secureTextEntry)
    {
        self.passwordTextField.secureTextEntry = YES;
        [hideShow setTitle:[NSLocalizedString(@"Show", nil) uppercaseString] forState:UIControlStateNormal];
    }
    else
    {
        self.passwordTextField.secureTextEntry = NO;
        [hideShow setTitle:[NSLocalizedString(@"Hide", nil) uppercaseString] forState:UIControlStateNormal];
    }
    [self.passwordTextField becomeFirstResponder];
}

- (void) actionForgotPassword
{
    PasswordForgotViewController *vc = [[PasswordForgotViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)actionFacebook
{
    [self.loadingView startAnimating];
    [WDFacebookHelper loginInViewController:self success:^{
        [self loginSuccess];
    } failure:^(NSError *error, User *user) {
            [self.loadingView stopAnimating];
            DLog(@"PAS INSCRIT");
            if (user) {
                self.tempFacebookUser = user;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YouAreNotYetAMember", nil)
                                                                message:error.localizedDescription
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
                [alert show];
            }else
            {
                [WDMessage showMessage:error.localizedDescription inView:self.view];
//                [WDMessage showMessage:[[error userInfo][FBErrorInnerErrorKey] userInfo][NSLocalizedDescriptionKey] inView:self.view];
            }
    }];
//    [WDFacebookHelper login:^{
//        [self loginSuccess];
//    } failure:^(NSError *error, NSDictionary<FBGraphUser> *user) {
//        [self.loadingView stopAnimating];
//        DLog(@"PAS INSCRIT");
//        if ([error.userInfo valueForKey:@"parameters"]) {
//            
//            NSDictionary *params = [error.userInfo valueForKey:@"parameters"];
//
//            User *newUser = [User new];
//            newUser.name = user.name;
//            newUser.handle = user.username;
//            newUser.email = [user valueForKey:@"email"];
//            newUser.fbId = [params valueForKeyPath:@"fbUid"];
//            newUser.fbTok = [params valueForKey:@"fbAccessToken"];
//            self.tempFacebookUser = newUser;
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YouAreNotYetAMember", nil)
//                                                            message:error.localizedDescription
//                                                           delegate:self
//                                                  cancelButtonTitle:NSLocalizedString(@"No", nil)
//                                                  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
//            [alert show];
//        }else
//        {
//            [WDMessage showMessage:[[error userInfo][FBErrorInnerErrorKey] userInfo][NSLocalizedDescriptionKey] inView:self.view];
//        }
//
//    }];
}

- (void)actionDone
{
    if (self.emailTextField.text.length==0 || ![WDHelper passwordIsValide:self.passwordTextField.text]) {
        [self actionErrorWithText:NSLocalizedString(@"AllFieldsMustBeFilledAndCorrect", nil)];
    }else
    {
        [self actionLoginWithEmail];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];


    if([title isEqualToString:NSLocalizedString(@"No", nil)])
    {
        return;
    }
    else if([title isEqualToString:NSLocalizedString(@"Yes", nil)])
    {
        RegisterViewController *vc = [[RegisterViewController alloc] initWithUser:self.tempFacebookUser];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}


- (void) actionLoginWithEmail {
    

    if(self.emailTextField.text.length > 0 && self.passwordTextField.text.length >0)
    {
        NSString *md5 = [WDHelper stringToMd5:self.passwordTextField.text];
        NSDictionary* parameters = @{@"email": self.emailTextField.text,
                                     @"md5":md5};
        
        [self.loadingView startAnimating];
        [WDHelper loginWithParameters:parameters success:^{
            
            [self loginSuccess];
            
        } failure:^(NSError *error) {
            [self.loadingView stopAnimating];
            [self actionErrorWithText:error.localizedDescription];
        }];
        
    }else
    {
        [self actionErrorWithText:NSLocalizedString(@"PleaseFillInAllFields", nil)];
    }
    



}

- (void) loginSuccess
{
    [self.loadingView stopAnimating];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGIN_SUCCESS object:self];
    

    
    
}



- (void)actionErrorWithText:(NSString*)errorString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginErrorAlertTitle", nil)
                                                    message:errorString
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}


#pragma -mark TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if(textField == self.passwordTextField){
        [self.passwordTextField resignFirstResponder];
        [self actionLoginWithEmail];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING LOGINVIEW");
    [super didReceiveMemoryWarning];
}



@end
