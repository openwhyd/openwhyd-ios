//
//  SettingsPasswordViewController.m
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsPasswordViewController.h"
#import "WDHelper.h"
#import "WDActivityIndicatorView.h"

@interface SettingsPasswordViewController ()
@property (nonatomic,strong) WDTextField *currentTextField;
@property (nonatomic,strong) WDTextField *passwordTextField;
@property (nonatomic,strong) WDTextField *confirmTextField;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;
@property (nonatomic) NSString *errorString;

@end

@implementation SettingsPasswordViewController


- (void)loadView
{
    [super loadView];
    self.title = [NSLocalizedString(@"SettingsPasswordTitle", nil) uppercaseString];
    self.view.backgroundColor = WDCOLOR_WHITE;
    
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    
    
    self.currentTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 46)];
    self.currentTextField.returnKeyType = UIReturnKeyDone;
    self.currentTextField.delegate = self;
    self.currentTextField.labelString = NSLocalizedString(@"SettingsPasswordCurrent", nil);
    self.currentTextField.placeholder = NSLocalizedString(@"SettingsPasswordCurrentPlaceholder", nil);
    [self.currentTextField setSecureTextEntry:YES];
    self.currentTextField.isPassword = YES;
    self.currentTextField.returnKeyType = UIReturnKeyNext;

    self.currentTextField.errorString = NSLocalizedString(@"SettingsPasswordCurrentError", nil);
    [self.view addSubview:self.currentTextField];
    
    self.passwordTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, self.currentTextField.frame.origin.y + 1 + self.currentTextField.frame.size.height, self.view.frame.size.width, 46)];
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.delegate = self;
    self.passwordTextField.labelString = NSLocalizedString(@"SettingsPasswordNew", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"SettingsPasswordNewPlaceholder", nil);
    [self.passwordTextField setSecureTextEntry:YES];
    self.passwordTextField.isPassword = YES;
    self.passwordTextField.errorString = NSLocalizedString(@"SettingsPasswordNewError", nil);
    self.passwordTextField.returnKeyType = UIReturnKeyNext;

    [self.view addSubview:self.passwordTextField];
    
    self.confirmTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0, self.passwordTextField.frame.origin.y + 1 + self.passwordTextField.frame.size.height, self.view.frame.size.width, 46)];
    self.confirmTextField.returnKeyType = UIReturnKeyDone;
    self.confirmTextField.delegate = self;
    self.confirmTextField.labelString = NSLocalizedString(@"SettingsPasswordConfirm", nil);;
    self.confirmTextField.placeholder = NSLocalizedString(@"SettingsPasswordConfirmPlaceholder", nil);
    [self.confirmTextField setSecureTextEntry:YES];
    self.confirmTextField.isPassword = YES;
    self.confirmTextField.errorString = NSLocalizedString(@"SettingsPasswordConfirmError", nil);
    self.confirmTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.confirmTextField];
    
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
    
 
}


#pragma mark ACTIONS

- (void)actionSave
{
    if (!self.currentTextField.text.length || !self.passwordTextField.text.length || !self.confirmTextField.text.length) {
        self.errorString = NSLocalizedString(@"SettingsPasswordFieldsMissing", nil);
    }
    
    if([self.currentTextField.text isEqualToString:self.passwordTextField.text])
    {
        self.errorString = NSLocalizedString(@"SettingsPasswordIdentical", nil);
    }
    
    if(![self.confirmTextField.text isEqualToString:self.passwordTextField.text])
    {
        self.errorString = NSLocalizedString(@"SettingsPasswordConfirmNotIdentical", nil);
    }
    
    
    
    if (self.errorString) {
        [self actionErrorWithText:self.errorString];
    }else
    {
        [self.view endEditing:YES];
        NSDictionary *parameters = @{@"pwd": self.passwordTextField.text,
                                     @"oldPwd" : self.currentTextField.text};

        DLog(@"PARAMETERS %@", parameters);
        [self.loadingView startAnimating];
        [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.loadingView stopAnimating];
            //DLog(@"responseObject Error: %@", responseObject);

            if ([responseObject valueForKey:@"error"]) {
                [self actionErrorWithText:[responseObject valueForKey:@"error"]];
            }else
            {
               [self.navigationController popToRootViewControllerAnimated:YES];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Operation Error: %@", error);
            [self.loadingView stopAnimating];
            
            
        }];
    }
    

}

- (void)actionErrorWithText:(NSString*)errorString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SettingsPasswordErrorAlertTitle", nil)
                                                    message:errorString
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma -mark TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.currentTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if(textField == self.passwordTextField){
        [self.confirmTextField becomeFirstResponder];
    }else if(textField == self.confirmTextField){
        [self actionSave];
        [self.confirmTextField resignFirstResponder];
    }
    
    return YES;
}


- (void)WDTextField:(WDTextField *)textField didChangeWithString:(NSString *)string
{
    
    
    //PASSWORD

    if([WDHelper passwordIsValide:textField.text])
    {
        textField.textFieldState = WDTextFieldStateSuccess;
        self.errorString = nil;
    }else
    {
        textField.textFieldState = WDTextFieldStateFailed;
        self.errorString = textField.errorString;
    }

    
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING PASSWORD");
    [super didReceiveMemoryWarning];
}

@end
