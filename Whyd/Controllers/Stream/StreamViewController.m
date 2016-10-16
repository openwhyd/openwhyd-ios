//
//  StreamViewController.m
//  Whyd
//
//  Created by Damien Romito on 06/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "StreamViewController.h"
#import "WDPlayerManager.h"
#import "UIViewController+WD.h"
#import "UIImage+Additions.h"
#import "Playlist.h"
#import "WDHelper.h"
#import "Activity.h"
@interface StreamViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (copy)void (^readyBlock)();
@property (copy)void (^failureBlock)();

@end

@implementation StreamViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.playlist = [[Playlist alloc] init];
        self.playlist.name = NSLocalizedString(@"StreamTitle", nil);
        self.playlist.url = API_STREAM;
        self.playlist.shuffleEnable = NO;
    }
    return self;
}

- (void)loadView
{    
    
    [super loadView];
    self.title = [NSLocalizedString(@"StreamTitle", nil) uppercaseString];
    [self makeAsMainViewController];
    
    if (!self.readyBlock && [WDHelper isLogged]) {
        [self reload];
    }


}

- (void)reload:(void (^)())success failure:(void (^)(NSError *error))failure
{
    self.readyBlock = success;
    self.failureBlock = failure;
    [self reload];
}
- (void)reload
{
    [super reload];

}

- (void)actionPlayAll
{
    [Flurry logEvent:FLURRY_PLAYALL_STREAM];

    [super actionPlayAll];
}


- (void)successResponse:(id)responseObject
{
    [super successResponse:responseObject];
    [self placeholderWithImageName:@"ProfileIconNoTrack" text:NSLocalizedString(@"StreamPlaceholder", nil) andSubText: NSLocalizedString(@"StreamPlaceholderSub", nil)];
    
    if (self.readyBlock) {
        self.readyBlock();
        self.readyBlock = nil;
    }
}

- (void)failureResponse:(NSError *)error
{
    if (self.failureBlock) {
        self.failureBlock(error);
        self.failureBlock = nil;
    }
}
@end
