//
//  PasswordForgotViewController.m
//  Whyd
//
//  Created by Damien Romito on 08/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PasswordForgotViewController.h"
#import "WDClient.h"

@interface PasswordForgotViewController ()
@property (nonatomic,strong) WDTextField *emailTextField;

@end

@implementation PasswordForgotViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = WDCOLOR_WHITE;
    
  
    
    self.title = [NSLocalizedString(@"ForgotPassword", nil) uppercaseString];
    UIBarButtonItem* sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SEND", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionSendEmail)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    UILabel *infosLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 25, self.view.frame.size.width - 22, 40)];
    infosLabel.textColor = RGBCOLOR(50, 50, 50);
    infosLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    infosLabel.text = NSLocalizedString(@"ForgotPasswordInfo", nil);
    infosLabel.numberOfLines = 0;
    [self.view addSubview:infosLabel];
    
    self.emailTextField = [[WDTextField alloc] initWithFrame:CGRectMake(0,  77, self.view.frame.size.width, 46)];
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.delegate = self;
    self.emailTextField.labelString = NSLocalizedString(@"Email", nil);
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.emailTextField.placeholder = NSLocalizedString(@"orYourUsername", nil);
    self.emailTextField.errorString = NSLocalizedString(@"EnterYourEmailOrYourUsername",nil);
    [self.view addSubview:self.emailTextField];
}

- (void)actionSendEmail
{
    
    
    if(self.emailTextField.text.length )
    {
        
        NSDictionary* parameters = @{@"email": self.emailTextField.text};
        
        [[WDClient client] GET:API_FORGOT_PASSWORD parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {

            if ([responseObject valueForKey:@"error"]) {
                [self actionErrorWithText:[responseObject valueForKey:@"error"]];
            }else
            {
                
                [self actionErrorWithText:[responseObject valueForKey:@"ok"]];
                [self.navigationController popViewControllerAnimated:YES];
            }


        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        }];
        
    }else
    {
        [self actionErrorWithText:NSLocalizedString(@"PleaseFillInAllFields", nil)];
    }
    

}

#pragma -mark TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [self actionSendEmail];
    [textField resignFirstResponder];
    
    
    return YES;
}


- (void)actionErrorWithText:(NSString*)errorString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorString
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING PASSWORD");
    [super didReceiveMemoryWarning];
}

@end
