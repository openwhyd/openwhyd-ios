//
//  AddTrackViewController.m
//  Whyd
//
//  Created by Damien Romito on 12/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "EditTrackViewController.h"
#import "WDHelper.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Additions.h"
#import "MainViewController.h"
#import "WDNavigationController.h"
#import "WDTwitterHelper.h"
#import "WDFacebookHelper.h"
#import "WDMessage.h"
#import "WDPlayerButton.h"

static const NSInteger HEIGHT_HEADER = 122;


@interface EditTrackViewController ()
{
    NSString *PLACEHOLDER_STRING;
    NSString *PLAYLIST_SELECT_STRING;

}

@property(nonatomic,strong, readonly) WDTrack* track;
@property(nonatomic,strong) Playlist* playlist;
@property(nonatomic,strong) WDPlayerButton* playButton;

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *playlistButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, weak) Playlist *selectedPlaylist;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *shareLabel;


@end

@implementation EditTrackViewController



- (id)initWithTrack:(WDTrack*)track fromPLaylist:(Playlist *)playlist
{
    self = [super init];
    if (self) {
        _track = track;
        _playlist = playlist;
        PLACEHOLDER_STRING = NSLocalizedString(@"AddAComment", nil);
        PLAYLIST_SELECT_STRING = NSLocalizedString(@"EditTrackSelectPlaylist", nil);
        [self addObserver:self forKeyPath:@"track.state" options:NSKeyValueObservingOptionNew context:NULL];

    }
    return self;
}

- (void)loadView
{

    [super loadView];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

    if (self.isNew) {
        self.title = [NSLocalizedString(@"Add track",nil) uppercaseString];
        
        
    }else
    {
        self.title = [NSLocalizedString(@"Edit track",nil) uppercaseString];
    }
    
   
    
    self.view.backgroundColor = WDCOLOR_WHITE;
    [[UIBarButtonItem appearance] setTintColor:WDCOLOR_BLUE];
    
    UIBarButtonItem* close = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AddButtonClose"] style:UIBarButtonItemStyleDone target:self action:@selector(actionDismiss)];
    [close setTintColor:WDCOLOR_BLUE];
    self.navigationItem.leftBarButtonItem = close;

    [self.navigationController.navigationBar setTranslucent:NO];

    
    UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithTitle:(self.isNew)?NSLocalizedString(@"Add",nil):NSLocalizedString(@"Save",nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionDone)];
    self.navigationItem.rightBarButtonItem = done;

    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 336)];
    [self.view addSubview:self.container];
    
    //IMAGE
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, self.view.frame.size.width + 2, HEIGHT_HEADER)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.borderColor = WDCOLOR_GRAY_BORDER.CGColor;
    self.imageView.layer.borderWidth = 1.;
    self.imageView.clipsToBounds = YES;
    [self.container addSubview:self.imageView];

    //playerButton
    /*********************************** PLAY BUTTON ***********************************/
    DLog(@"self.view.frame.size.width %f",self.view.frame.size.width);
    
    self.playButton = [[WDPlayerButton alloc] initWithOrigin:CGPointMake(self.view.frame.size.width/2 - 32 , (HEIGHT_HEADER - 64)/5)];
    [self.playButton addTarget:self action:@selector(actionPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.playButton];
    [self updateState];

    
    UIImageView *gradientBackground = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    gradientBackground.image = [[UIImage imageNamed:@"AddBackgroundGradientBottomCover"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    [self.container addSubview:gradientBackground];
    
    //TITLE
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 65, self.view.frame.size.width - 22, 37)];
    self.titleLabel.text = self.track.name;
    self.titleLabel.textColor = UICOLOR_WHITE;
    self.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_5];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.container addSubview:self.titleLabel];
    
    //TEXTAREA COMMENT
    
    UIImageView *arrowCommentImage = [[UIImageView alloc] initWithFrame:CGRectMake(17, 115, 16, 7)];
    arrowCommentImage.image = [UIImage imageNamed:@"AddPlaylistBackgroundTopTriangle"];
    [self.container addSubview:arrowCommentImage];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 122, self.view.frame.size.width, 75)];
    self.textView.backgroundColor = UICOLOR_WHITE;
    self.textView.textContainerInset = UIEdgeInsetsMake(15, 11, 15, 11);
    self.textView.text = PLACEHOLDER_STRING;
    self.textView.textColor = WDCOLOR_GRAY_PLACEHOLDER_TEXTVIEW;
    self.textView.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeyDone;
    [self.container addSubview:self.textView];
    
    
    //PLAYLIST BUTTON
    self.playlistButton = [[UIButton alloc] initWithFrame:CGRectMake(-.5, 195, self.view.frame.size.width + 2, 50)];
    self.playlistButton.layer.borderColor = WDCOLOR_WHITE.CGColor;
    self.playlistButton.layer.borderWidth = .5;
    [self.playlistButton setTitle:PLAYLIST_SELECT_STRING forState:UIControlStateNormal];
    [self.playlistButton setTitleColor:WDCOLOR_BLUE_DARK forState:UIControlStateNormal];
    self.playlistButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    [self.playlistButton addTarget:self action:@selector(actionPlaylist) forControlEvents:UIControlEventTouchUpInside];
    [self.playlistButton setImage:[UIImage imageNamed:@"AddButtonPlaylistDisable"] forState:UIControlStateNormal];
    [self.playlistButton setImage:[UIImage imageNamed:@"AddButtonPlaylistSelected"] forState:UIControlStateSelected];
    [self.playlistButton setImage:[UIImage imageNamed:@"AddButtonPlaylistSelected"] forState:UIControlStateHighlighted];
    self.playlistButton.imageEdgeInsets = UIEdgeInsetsMake(0, 19, 0, 0);
    self.playlistButton.titleEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0);
    self.playlistButton.backgroundColor = UICOLOR_WHITE;
    self.playlistButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.container  addSubview:self.playlistButton];
    
    UIImageView *accessorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddIconNextViewPlaylist"]];
    accessorImage.frame = CGRectMake(self.view.frame.size.width - 20, 17, 9, 16);
    [self.playlistButton addSubview:accessorImage];
    
    
    //SHARE LABEL
    self.shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 265, self.view.frame.size.width - 22, 15)];
    self.shareLabel.textColor = RGBCOLOR(147, 152, 158);
    self.shareLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    self.shareLabel.text = @"SHARE";
    [self.container addSubview:self.shareLabel];
    
    
    //SHARE BUTTON
    self.facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 286, self.view.frame.size.width/2, 50)];
    self.facebookButton.layer.borderColor = WDCOLOR_WHITE.CGColor;
    self.facebookButton.layer.borderWidth = 1.;
    [self.facebookButton setImage:[UIImage imageNamed:@"AddButtonFacebookShareDisable"] forState:UIControlStateNormal];
    [self.facebookButton setImage:[UIImage imageNamed:@"AddButtonFacebookShareSelected"] forState:UIControlStateHighlighted];
    [self.facebookButton setImage:[UIImage imageNamed:@"AddButtonFacebookShareSelected"] forState:UIControlStateSelected];
    self.facebookButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    [self.facebookButton setTitleColor:WDCOLOR_BLUE_DARK forState:UIControlStateNormal];
    [self.facebookButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateHighlighted];
    [self.facebookButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateSelected];
    self.facebookButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
    self.facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 17, 0, 0);
    self.facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 31, 0, 0);
    self.facebookButton.backgroundColor = UICOLOR_WHITE;
    [self.facebookButton addTarget:self action:@selector(actionShareFacebook) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.facebookButton];

    self.twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 1, 286, self.view.frame.size.width/2 + 1, 50)];
    self.twitterButton.layer.borderColor = WDCOLOR_WHITE.CGColor;
    self.twitterButton.layer.borderWidth = 1.;
    [self.twitterButton setImage:[UIImage imageNamed:@"AddButtonTwitterShareDisable"] forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageNamed:@"AddButtonTwitterShareSelected"] forState:UIControlStateHighlighted];
    [self.twitterButton setImage:[UIImage imageNamed:@"AddButtonTwitterShareSelected"] forState:UIControlStateSelected];
    self.twitterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
    [self.twitterButton setTitleColor:WDCOLOR_BLUE_DARK forState:UIControlStateNormal];
    [self.twitterButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateHighlighted];
    [self.twitterButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateSelected];
    self.twitterButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
    self.twitterButton.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    self.twitterButton.titleEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0);
    self.twitterButton.backgroundColor = UICOLOR_WHITE;
    [self.twitterButton addTarget:self action:@selector(actionShareTwitter) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.twitterButton];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(-1, 280, self.view.frame.size.width + 2, 50)];
    [self.deleteButton setTitle:NSLocalizedString(@"DeleteThisTrack",nil) forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:WDCOLOR_GRAY_TEXT_DARK_MEDIUM forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    self.deleteButton.layer.borderColor = WDCOLOR_GRAY_LIGHT_BLUE.CGColor;
    self.deleteButton.layer.borderWidth = .5;
    [self.deleteButton addTarget:self action:@selector(actionDelete) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.deleteButton];
    
    //LOADER
    self.loadingView = [WDHelper WDActivityIndicator];
    CGRect frame = self.loadingView.frame;
    frame.origin.y = self.view.frame.size.height/2 - 40;
    self.loadingView.frame = frame;
    [self.view addSubview:self.loadingView ];
    
    
    [self loadTrack];
}


- (void)loadTrack
{
    [self setImageView];
    self.titleLabel.text = self.track.name;
    
    if (!self.isNew) {
        if (self.track.text.length > 0) {
            self.textView.text = self.track.text;
            self.textView.textColor = WDCOLOR_GRAY_TEXT_DARK;
        }
        if (self.track.playlist) {
            [self PlaylistSelect:self.track.playlist];
        }
        self.facebookButton.hidden = YES;
        self.twitterButton.hidden = YES;
        self.shareLabel.hidden = YES;
    }else
    {
        self.deleteButton.hidden = YES;
        [self updateTwitterPosition];
        [self updateFacebookPosition];
    }
    

}

- (void)setImageView
{
    
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.track.imageUrl ] placeholderImage:[UIImage imageWithColor:WDCOLOR_GRAY_PLACEHOLDER_IMAGE] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!error) {
            [weakSelf.imageView setImage:image];
            
        }else
        {
            if ([weakSelf.track updatedAvailableImageUrl] < 2) {
                [weakSelf setImageView];
            };
        }
    }];
}

#pragma mark Playlist Button


- (void)actionPlay
{
    switch (self.track.state) {
        case TrackStatePause:
            [[WDPlayerManager manager] play];
            break;
        case TrackStatePlay:
            [[WDPlayerManager manager] pause];
            
            break;
        case TrackStateStop:
            [[WDPlayerManager manager] playAtIndex:self.tag inPlayList:self.playlist];
            break;
        case TrackStateUnavailable:
            [WDMessage showMessage:NSLocalizedString(@"UnavailableTrack", nil) inView:self.view withTopMargin:NO];
            break;
        default:
            break;
            
    }
}


- (void) actionPlaylist
{
    PlaylistSelectViewController *vc = [[PlaylistSelectViewController alloc] init];
    vc.delegate = self;
    if (self.selectedPlaylist) {
        vc.selectedPlaylist = self.selectedPlaylist;
    }
    WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) actionDone
{
    [self.loadingView startAnimating];
    self.track.playlist = self.selectedPlaylist;
    self.track.text = ([self.textView.text isEqualToString:PLACEHOLDER_STRING])?@"":self.textView.text;
    
    
    [WDHelper insertTrack:self.track editing:!self.isNew success:^(NSURLSessionDataTask *task, id responseObject) {

        
//            if ([self.delegate respondsToSelector:@selector(editTrackWithSuccess:)]) {
//                [self.delegate editTrackWithSuccess:self.track];
//            }
    
        DLog(@"responce %@", responseObject);
        
        WDTrack *track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:responseObject error:nil];

        [WDHelper manager].currentUser.nbPosts += 1;
        [[MainViewController manager] track:track added:YES];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
           
            [[MainViewController manager] handleMessage:(self.isNew)? NSLocalizedString(@"TrackAdded", nil):NSLocalizedString(@"TrackEdited", nil) ];
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_AUTOSHARE_FB]) {
                [WDFacebookHelper shareTrack:track];
            }
            if ([[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_AUTOSHARE_TW]) {
                [WDTwitterHelper shareTrack:track];
            }
            

            
        }];

        [WDHelper runAfterDelay:2 block:^{
            [WDHelper apnAskAfterPost];
            if (self.isNew) {
                [WDHelper addTrackCountForRatePopup];
            }
        }];
        [self.loadingView stopAnimating];
    } failure:nil];
    

}

- (void)actionDelete
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteThisTrack",nil)
                                                    message:NSLocalizedString(@"AreYouSure",nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"No",nil)
                                          otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
    [alert show];
    
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    
    if([title isEqualToString:NSLocalizedString(@"No",nil)])
    {
        return;
    }
    else if([title isEqualToString:NSLocalizedString(@"Yes",nil)])
    {
        


        NSDictionary *parameters = @{@"_id":self.track.id};
        [self.loadingView startAnimating];
        
        [[WDClient client] GET:API_TRACK_DELETE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.loadingView stopAnimating];
            
            [WDHelper manager].currentUser.nbPosts --;
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.playlist.tracks ];
            [mArray removeObject:self.track];
            self.playlist.tracks = mArray;
          
            [self dismissViewControllerAnimated:YES completion:^{
                [[MainViewController manager] handleMessage:NSLocalizedString(@"TrackDeleted", nil)];
                
            }];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self.loadingView stopAnimating];
             DLog(@"ERROR %@", error);
        }];
    }
}

- (void)actionDismiss
{

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) actionShareTwitter
{
    
    if (self.twitterButton.selected) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_AUTOSHARE_TW];

    }else
    {
        if (![WDHelper manager].currentUser.twId) {
            [self.loadingView startAnimating];
            [[WDTwitterHelper manager] selectAccountInView:self.view success:^(NSString *username) {
                [self.loadingView stopAnimating];
                [self updateTwitterPosition];

            } failure:^(NSError *error) {
                [self.loadingView stopAnimating];
                if (error) {
                    [self alertWithTitle:error.userInfo[@"Title"]  andMessage:error.localizedDescription];
                }

            }];
            return;
        }else
        {
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_AUTOSHARE_TW];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateTwitterPosition];
    
    
}


- (void) actionShareFacebook
{
    
    if (self.facebookButton.selected) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_AUTOSHARE_FB];
    }else
    {
        if(![WDFacebookHelper checkAccessToken]){
                [self.loadingView startAnimating];
                [WDFacebookHelper linkAccount:^(NSString *username) {
                    [self.loadingView stopAnimating];
                    [self updateFacebookPosition];
                } failure:^(NSError *error) {
                    [self.loadingView stopAnimating];
                    [self alertWithTitle:error.userInfo[@"Title"]  andMessage:error.localizedDescription];
                }];
        }else{
             [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_AUTOSHARE_FB];
        }
//        if (!FBSession.activeSession.isOpen) {
//            [self.loadingView startAnimating];
//            [WDFacebookHelper linkAccount:^(NSString *username) {
//                [self.loadingView stopAnimating];
//                [self updateFacebookPosition];
//            } failure:^(NSError *error) {
//                [self.loadingView stopAnimating];
//                [self alertWithTitle:error.userInfo[@"Title"]  andMessage:error.localizedDescription];
//            }];
//            
//          
//        }else
//        {
//            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_AUTOSHARE_FB];
//        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateFacebookPosition];
}


#pragma - mark UPDATE UI

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateState];
    
}


- (void)updateState
{
    switch (self.track.state) {
        case TrackStateLoading:
        {
            self.playButton.currentState = WDPlayerButtonStateLoading;
        }
            break;
        case TrackStateStop:
        {
            self.playButton.currentState = WDPlayerButtonStateStop;
        }
            break;
        case TrackStatePlay:
        {
            self.playButton.currentState = WDPlayerButtonStatePlay;
        }
            break;
        case TrackStatePause:
        {
            self.playButton.currentState = WDPlayerButtonStatePause;
        }
            break;
        case TrackStateUnavailable:
        {
            self.playButton.currentState = WDPlayerButtonStateUnavailable;
            
           // self.backgroundUnavailable.hidden = NO;
        }
            break;
            
    }
//    
//    if (self.track.state != TrackStateUnavailable) {
//        
//        self.backgroundUnavailable.hidden = YES;
//    }
    
}



- (void)updateTwitterPosition
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_AUTOSHARE_TW]) {
        self.twitterButton.selected = YES;
    }else
    {
        self.twitterButton.selected = NO;
    }

}

- (void)updateFacebookPosition
{
    NSLog(@" FACEBOOK %@",[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_AUTOSHARE_FB]);

    if ([[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_AUTOSHARE_FB]) {
        self.facebookButton.selected = YES;
    }else
    {
        self.facebookButton.selected = NO;
    }
}


- (void)alertWithTitle:(NSString*)title andMessage:(NSString*)message
{
    [self.loadingView stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    [alert show];
}

#pragma mark TextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PLACEHOLDER_STRING])
    {
        textView.text = @"";
        textView.textColor = WDCOLOR_GRAY_TEXT_DARK;
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.textView.text isEqualToString:@""])
    {
        self.textView.text = PLACEHOLDER_STRING;
        self.textView.textColor = WDCOLOR_GRAY_PLACEHOLDER_TEXTVIEW;
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            
            CGAffineTransform t = CGAffineTransformIdentity;
            self.view.transform = CGAffineTransformTranslate(t , 0, 0 );
            
        } completion:^(BOOL finished) {
            
        }];
        return NO;
    }
    
    return YES;
}

- (void)PlaylistSelect:(Playlist *)playlist
{
    self.selectedPlaylist = playlist;
    if (playlist) {
        [self.playlistButton setTitle:playlist.name forState:UIControlStateSelected];
        [self.playlistButton setTitle:playlist.name forState:UIControlStateSelected | UIControlStateHighlighted];
        self.playlistButton.selected = YES;

    }else
    {
        self.playlistButton.selected = NO;
    }
    
    
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"track.state"];
    
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING EDIT TRACK");
    [super didReceiveMemoryWarning];
}

@end
