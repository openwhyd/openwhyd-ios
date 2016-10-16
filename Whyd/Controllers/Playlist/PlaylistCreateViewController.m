//
//  PlaylistCreateViewController.m
//  Whyd
//
//  Created by Damien Romito on 25/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PlaylistCreateViewController.h"
#import "WDClient.h"
#import "WDHelper.h"
#import "WDActivityIndicatorView.h"

@interface PlaylistCreateViewController (){
    NSString *PLACEHOLDER_STRING;
}
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;

@end


@implementation PlaylistCreateViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        PLACEHOLDER_STRING = NSLocalizedString(@"NameOfYourPlaylist", nil);
    }
    return self;
}
- (void)loadView
{
    [super loadView];
    
    self.title = [NSLocalizedString(@"CreateAPlaylist", nil) uppercaseString];
    self.view.backgroundColor = UICOLOR_WHITE;
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
   // [cancel setTintColor:WDCOLOR_BLUE];
    self.navigationItem.leftBarButtonItem = cancel;
    
    
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
    
//    UIBarButtonItem* create = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionCreate)];
//    [create setTintColor:WDCOLOR_BLUE];
    //self.navigationItem.rightBarButtonItem = create;
    
    UIImageView *playlistImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 15, 70, 70)];
    playlistImage.image = [UIImage imageNamed:@"AddPlaylistCoverEmpty"];
    [self.view addSubview:playlistImage];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(92, 15, 200, 70)];
    self.textField.placeholder = PLACEHOLDER_STRING;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    self.textField.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    [self.textField becomeFirstResponder];
    [self.view addSubview:self.textField];

}


- (void)actionCreate
{
    if (self.textField.text.length > 0) {
 
        [self.loadingView startAnimating];
        NSDictionary *parameters = @{@"name": self.textField.text,
                                     @"action": @"create"};
        
        [[WDClient client] POST:API_PLAYLIST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.loadingView stopAnimating];

            [self actionDismiss];
            Playlist * playlist = [MTLJSONAdapter modelOfClass:[Playlist class] fromJSONDictionary:responseObject error:nil];
            [self.delegate playlistCreated:playlist];
            

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"ERROR %@", error);
        }];
        
    }
}


- (void)actionDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self actionCreate];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING PLAYLSIT CREATE");
    [super didReceiveMemoryWarning];
}

@end
