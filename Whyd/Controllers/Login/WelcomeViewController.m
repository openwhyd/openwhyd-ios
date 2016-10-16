//
//  WelcomeViewController.m
//  Whyd
//
//  Created by Damien Romito on 08/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "UIImage+Additions.h"
#import "WDHelper.h"
#import "RegisterViewController.h"
#import "WDActivityIndicatorView.h"
#import "WDMessage.h"
#import "WDFacebookHelper.h"
#import "MainViewController.h"

@interface WelcomeViewController ()
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;

@end

@implementation WelcomeViewController

- (void)loadView
{

    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [super loadView];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImage.image = [UIImage imageNamed:(IS_IPHONE_5)?@"LoginBackground4inch.jpg":@"LoginBackground3.5inch.jpg"];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFit  ;
    [self.view addSubview:backgroundImage];


    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HomeScreenLogoWhyd"]];
    logoImage.frame = CGRectMake(self.view.frame.size.width/2 - logoImage.frame.size.width/2, (IS_IPHONE_5)?110:90, logoImage.frame.size.width, logoImage.frame.size.height);
    [self.view addSubview:logoImage];
    
    UILabel *claimLabel = [[UILabel alloc]  initWithFrame:CGRectMake(0, logoImage.frame.origin.y + 90, self.view.frame.size.width, 45)];
    claimLabel.text = [NSLocalizedString(@"HomeSlogan", nil) uppercaseString];
    claimLabel.textAlignment = NSTextAlignmentCenter;
    claimLabel.numberOfLines = 2;
    claimLabel.textColor = UICOLOR_WHITE;
    claimLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    [self.view addSubview:claimLabel];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(11, self.view.frame.size.height - 175, self.view.frame.size.width - 22, 44)];
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
    
    UIButton *emailButton = [[UIButton alloc] initWithFrame:CGRectMake(11, self.view.frame.size.height - 120, self.view.frame.size.width - 22, 44)];
    [emailButton setBackgroundImage:[UIImage imageWithColor:[WDCOLOR_GRAY colorWithAlphaComponent:.38]] forState:UIControlStateNormal];
    [emailButton setBackgroundImage:[UIImage imageWithColor:[WDCOLOR_GRAY colorWithAlphaComponent:.68]] forState:UIControlStateHighlighted];

    emailButton.layer.cornerRadius = CORNER_RADIUS;
    emailButton.clipsToBounds = YES;
    [emailButton setTitleColor:UICOLOR_WHITE forState:UIControlStateNormal];
    emailButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    [emailButton setTitle:[NSLocalizedString(@"SignUpWithEmail", nil) uppercaseString] forState:UIControlStateNormal];
    emailButton.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [emailButton addTarget:self action:@selector(actionEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:emailButton];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(11, self.view.frame.size.height - 65,  self.view.frame.size.width - 22, 44)];
    loginButton.layer.borderColor = [WDCOLOR_GRAY colorWithAlphaComponent:.5].CGColor;
    loginButton.layer.borderWidth = 1;
    loginButton.layer.cornerRadius = CORNER_RADIUS;
    loginButton.clipsToBounds = YES;
    loginButton.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [loginButton setTitleColor:RGBCOLOR(159, 159, 160) forState:UIControlStateNormal];
    [loginButton setTitleColor:RGBACOLOR(159, 159, 160, .7)  forState:UIControlStateHighlighted];

    loginButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    [loginButton setTitle:[NSLocalizedString(@"Login", nil) uppercaseString] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(actionLogin) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:loginButton];


    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
    [self.view addSubview:self.loadingView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
   
    

    
}

- (void)viewDidLoad
{

    [super viewDidLoad];

}

- (void)actionLogin
{
    LoginViewController *vc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionFacebook
{
    
    [self.loadingView startAnimating];
    
  
    
    [WDFacebookHelper loginInViewController:self success:^{
        
        [self.loadingView stopAnimating];
        [[UIApplication sharedApplication] setStatusBarHidden:NO ];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGIN_SUCCESS object:self];

    } failure:^(NSError *error, User *user)
    {

        if (user) {
            [Flurry logEvent:FLURRY_REGISTER_FACEBOOK];
            RegisterViewController *vc = [[RegisterViewController alloc] initWithUser:user];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (error) 
        {
            [WDMessage showMessage: error.localizedDescription inView:self.view withTopMargin:NO];
        }
            
        [self.loadingView stopAnimating];

    }];


}

- (void)actionEmail
{
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [Flurry logEvent:FLURRY_REGISTER_EMAIL];

}

- (void)dealloc
{
    DLog(@"DEALLLLOOC");
}




@end
