//
//  WDShareSheet.m
//  Whyd
//
//  Created by Damien Romito on 30/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDShareSheet.h"
#import <Social/Social.h>
#import "UIImageView+WebCache.h"
#import <MessageUI/MessageUI.h>
#import "WDHelper.h"
#import "WDUserPickerViewController.h"
#import "WDNavigationController.h"
#import "UIImage+Additions.h"
#import "WDAlertView.h"
#import "WDPlayerConfig.h"
#import "WDActivityIndicatorView.h"




@interface WDShareSheet()<WDActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, WDAlertViewDelegate>
@property (nonatomic, strong) WDTrack *track;
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic, strong) UIViewController *controller;
@property (copy)void (^successBlock)(NSString *message);
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;


@end
@implementation WDShareSheet

+(WDShareSheet*)showInController:(UIViewController*)controller withPlaylist:(Playlist*)playlist dismiss:(void (^)(NSString *))dismiss
{
    [Flurry logEvent:FLURRY_SHARE_PLAYLIST];

    WDShareSheet *sheet = [[WDShareSheet alloc] initSheetWithTitle:NSLocalizedString(@"ShareSheetPlaylistTitle", nil)];
    sheet.playlist = playlist;
    sheet.url = [playlist urlLink];
    sheet.name = playlist.name;
    sheet.controller = controller;
    sheet.successBlock = dismiss;
    [sheet show];
    return  sheet;
}

+(WDShareSheet*)showInController:(UIViewController*)controller withTrack:(WDTrack*)track dismiss:(void (^)(NSString *))dismiss
{
    
    [Flurry logEvent:FLURRY_SHARE_TRACK];

    WDShareSheet *sheet = [[WDShareSheet alloc] initSheetWithTitle:NSLocalizedString(@"ShareSheetTrackTitle", nil)];
    sheet.track = track;
    sheet.name = track.name;
    sheet.url = [track url];
    sheet.controller = controller;
    sheet.successBlock = dismiss;
    sheet.autoClose = NO;
    [sheet show];
    
    
    return  sheet;
}

- (instancetype)initSheetWithTitle:(NSString*)title
{
    self = [super initWithTitle:title delegate:self
              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
              otherButtonTitles:@[NSLocalizedString(@"ShareSheetWhyd", nil),
                                 NSLocalizedString(@"ShareSheetFacebook", nil),
                                 NSLocalizedString(@"ShareSheetTwitter", nil),
                                 NSLocalizedString(@"ShareSheetEmail", nil),
                                 NSLocalizedString(@"ShareSheetMessages", nil),
                                 NSLocalizedString(@"ShareSheetCopyLink", nil)]];


    return self;
}


- (void)clickedButtonWithTitle:(NSString *)titleString
{
    self.titleString = titleString;
    

    [self openShare];
    
}


- (void)WDAlertViewClosed
{
    [self shareTrack];
}

- (void)shareTrack
{
    //NOT CLICKED
    if (!self.titleString ) return;
    
    //NOT YET MAPPED
    if (!self.track.multiSourced)
    {
        self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self];
        [self.loadingView startAnimating];
        
        return;
    }

    [self openShare];
    
}

-(void)openShare
{

    [self close:YES];
  
    if([self.titleString isEqualToString:NSLocalizedString(@"ShareSheetWhyd", nil)])
    {
        WDUserPickerViewController *vc;
        
        if (self.track) {
            vc = [WDUserPickerViewController pickerWithTrack:self.track];
        }else
        {
            vc = [WDUserPickerViewController pickerWithPlaylist:self.playlist];
        }
        
        //            WDUserPickerViewController *vc = [WDUserPickerViewController pickerWithTrack:self.streamViewController.playlist.tracks.firstObject];
        //            [vc.navigationController.navigationBar setTranslucent:NO];
        
        WDNavigationController *nav = [[WDNavigationController alloc] initWithRootViewController:vc];
        [self.controller.navigationController presentViewController:nav animated:YES completion:nil];
        
    }
    //FACEBOOK
    else if([self.titleString isEqualToString:NSLocalizedString(@"ShareSheetFacebook", nil)])
    {
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [vc setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *message;
             if (result == SLComposeViewControllerResultDone) {
                 message = [self textWithKey:@"FacebookSuccess"];
                 [Flurry logEvent:FLURRY_SHARE_FB];
                 
             }
             [self closeWithMessage:message];
             
         }];
        
        [vc addURL:[NSURL URLWithString:self.url]];
        
        NSString *shareText = [NSString stringWithFormat:[self textWithKey:@"FacebookInitialText"], self.name ];
        //            [self loadCoverImageWithUrl:self.track.imageUrl success:^(UIImage *image) {
        //                [vc addImage:image];
        //            }];
        [vc setInitialText:shareText];
        
        [self.controller.navigationController presentViewController:vc animated:YES completion:nil];
        
        
        //TWIITER
    }else if ([self.titleString isEqualToString:NSLocalizedString(@"ShareSheetTwitter", nil)])
    {
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [vc setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *message;
             if (result == SLComposeViewControllerResultDone) {
                 [Flurry logEvent:FLURRY_SHARE_TW];
                 
                 message = [self textWithKey:@"TwitterSuccess"];
             }
             [self closeWithMessage:message];
         }];
        NSString *shareText = [NSString stringWithFormat:[self textWithKey:@"TwitterInitialText"], self.name, self.url ];
        [vc setInitialText:shareText];
        [self.controller.navigationController presentViewController:vc animated:YES completion:nil];
        
    }else if ([self.titleString isEqualToString:NSLocalizedString(@"ShareSheetEmail", nil)])
    {
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            vc.mailComposeDelegate = self;
            [vc setSubject:[self textWithKey:@"EmailSubject"]];
            
            NSString *htmlLink = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", self.url, self.name ];
            NSString *htmlBody = [NSString stringWithFormat:[self textWithKey:@"EmailMessage"],htmlLink];
            [vc setMessageBody:htmlBody isHTML:YES];
            [self.controller presentViewController:vc animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                
            }];
        }
        
        
    }else if ([self.titleString isEqualToString:NSLocalizedString(@"ShareSheetMessages", nil)])
    {
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        vc.messageComposeDelegate = self;
        NSString *message = [NSString stringWithFormat:[self textWithKey:@"MessagesMessage"], self.name, self.url ];
        [vc setBody:message];
        
        
        [self.controller presentViewController:vc animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
        
    }else if ([self.titleString isEqualToString:NSLocalizedString(@"ShareSheetCopyLink", nil)])
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.url;
        [Flurry logEvent:FLURRY_SHARE_PASTE_LINK];
        [self closeWithMessage:[self textWithKey:@"CopyLinkSuccess"]];
        
        
        
    }
    self.titleString = nil;

    
}




- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *message;
    
    if (result == MFMailComposeResultSent) {
        [Flurry logEvent:FLURRY_SHARE_EMAIL];

        message = [self textWithKey:@"EmailSuccess"];
    }
    
    if (result != MFMailComposeResultFailed) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        [self closeWithMessage:message];
    }
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"NavBarShadow"]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *message;

    if (result== MessageComposeResultSent) {
        [Flurry logEvent:FLURRY_SHARE_MESSAGE];

        message = [self textWithKey:@"MessagesSuccess"];
    }
    
    if (result != MessageComposeResultFailed)
    {
        [controller dismissViewControllerAnimated:YES completion:nil];
        [self closeWithMessage:message];
    }
    

    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"NavBarShadow"]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

}

- (void)closeWithMessage:(NSString*)message
{
    self.successBlock(message);
}

- (NSString*)textWithKey:(NSString*)key
{
    key = [NSString stringWithFormat:@"%@%@", (self.track)?@"ShareSheetTrack":@"ShareSheetPlaylist" ,key ];
    return NSLocalizedString(key, nil);
}


- (void)loadCoverImageWithUrl:(NSString *)imageUrl success:(void(^)(UIImage *image))success
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (self.track.imageUrl) {
            UIImage *artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.track.imageUrl]]];
            if(artworkImage)
            {
                UIImage *bottomImage= [UIImage imageNamed:@"ProfileButtonPlayAllPlaylist"]; //foreground image
                
                UIGraphicsBeginImageContext( artworkImage.size );
                
                // Use existing opacity as is
                [bottomImage drawInRect:CGRectMake(artworkImage.size.width / 2 - bottomImage.size.width/2,
                                                   artworkImage.size.height/2 - bottomImage.size.height/2,
                                                   bottomImage.size.height,bottomImage.size.height)];
                
                // Apply supplied opacity if applicable
                [artworkImage drawInRect:CGRectMake(0, 0, artworkImage.size.width, artworkImage.size.height) blendMode:kCGBlendModeNormal alpha:0.8];
                
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

                UIGraphicsEndImageContext();
                success(newImage);
            }
            
            
        }
    });
    
}

@end
