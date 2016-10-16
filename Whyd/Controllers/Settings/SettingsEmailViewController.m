//
//  SettingsEmailViewController.m
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsEmailViewController.h"
#import "WDHelper.h"
#import "WDActivityIndicatorView.h"

@interface SettingsEmailViewController ()
@property (nonatomic, strong) WDTextField *emailTextField;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;
@property (nonatomic) NSString *errorString;


@end

@implementation SettingsEmailViewController


- (void)loadView
{
    [super loadView];
    self.title = [NSLocalizedString(@"SettingsEmailTitle", nil) uppercaseString];
    self.view.backgroundColor = WDCOLOR_WHITE;
    
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    self.emailTextField = [[WDTextField alloc] initWithYPosition:30];
    self.emailTextField.labelString = NSLocalizedString(@"Email", nil);
    self.emailTextField.placeholder = NSLocalizedString(@"SettingsEmailPlaceholder", nil);

    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.errorString = NSLocalizedString(@"ThisIsNotAnEmail", nil);
    [self.view addSubview:self.emailTextField];
    
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];

    [self configureView];
}

- (void)configureView
{
    self.emailTextField.text = [WDHelper manager].currentUser.email;
}

- (void)actionSave
{
    [self.view endEditing:YES];
    
    if ([self.emailTextField.text isEqualToString:[WDHelper manager].currentUser.email]) {
        [self actionErrorWithText:NSLocalizedString(@"SettingsEmailIdentical", nil)];
    }
    else if(![WDHelper emailIsValide:self.emailTextField.text])
    {
        [self actionErrorWithText:NSLocalizedString(@"ThisIsNotAnEmail", nil)];

    }else{
        NSDictionary *parameters = @{@"email": self.emailTextField.text};
        
        
        [WDHelper manager].currentUser.email = self.emailTextField.text;
        
        
        [self.loadingView startAnimating];
        [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [self.loadingView stopAnimating];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Operation Error: %@", error);
            [self.loadingView stopAnimating];
            
        }];
    }
    

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
   [self actionSave];
    
    return YES;
}

- (void)WDTextField:(WDTextField *)textField didChangeWithString:(NSString *)string
{
    
    
    //PASSWORD
    
    if([WDHelper emailIsValide:textField.text])
    {
        textField.textFieldState = WDTextFieldStateSuccess;
        self.errorString = nil;
    }else
    {
        textField.textFieldState = WDTextFieldStateFailed;
        self.errorString = textField.errorString;
    }
    
    
    
}

- (void)actionErrorWithText:(NSString*)errorString
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SettingsEmailErrorAlertTitle", nil)
                                                    message:errorString
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING SETTINGS EMAIL");
    [super didReceiveMemoryWarning];
}

@end
