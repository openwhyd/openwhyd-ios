//
//  WDWelcomeView.m
//  Whyd
//
//  Created by Damien Romito on 13/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDWelcomeView.h"
#import "WDHelper.h"
#import "UIImageView+WebCache.h"

@interface WDWelcomeView()
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end
@implementation WDWelcomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionClose:) name:NOTIFICATION_STREAM_LOADED object:nil];
        
        self.backgroundColor = RGBCOLOR(24, 30, 34);
        
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2 - 100 , self.frame.size.width, 0)];
        self.container.alpha = 0;
        [self addSubview:self.container];
        
        
        UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        welcomeLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_6];
        welcomeLabel.text = [NSLocalizedString(@"OnboardingWelcome", nil) uppercaseString];
        welcomeLabel.textColor = UICOLOR_WHITE;
        welcomeLabel.textAlignment = NSTextAlignmentCenter;
        [self.container addSubview:welcomeLabel];
        
        UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-17.5, 50, 35, 35)];
        NSURL *imageURL =[NSURL URLWithString:[[WDHelper manager].currentUser imageUrl:UserImageSizeSmall]];
        [avatarView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
        avatarView.layer.cornerRadius = 17.5;
        avatarView.clipsToBounds = YES;
        [self.container addSubview:avatarView];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, self.frame.size.width, 30)];
        usernameLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
        usernameLabel.text = [WDHelper manager].currentUser.name;
        usernameLabel.textColor = RGBCOLOR(186, 205, 221);
        usernameLabel.textAlignment = NSTextAlignmentCenter;
        [self.container addSubview:usernameLabel];
        

        
    }
    return self;
}

- (void)show
{

    self.container.transform = CGAffineTransformMakeTranslation(0, 20);
    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        self.container.alpha = 1;
        self.container.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect frame = self.loadingView.frame;
        frame.origin.x = self.frame.size.width/2-self.loadingView.frame.size.width/2;
        frame.origin.y = self.frame.size.height/5;
        self.loadingView.frame = frame;
        [self addSubview:self.loadingView];
        [self.loadingView startAnimating];

        
    }];


}


- (void)actionClose:(NSNotification*)notification
{

    
   [WDHelper runAfterDelay:1 block:^{
       [[NSNotificationCenter defaultCenter] removeObserver:self];
       
       if ([self.delegate respondsToSelector:@selector(WDWelcomeViewWillDisappear)]) {
           [self.delegate WDWelcomeViewWillDisappear];
       }
       [self.superview bringSubviewToFront:self];
       [UIView animateWithDuration:0.2 delay:0.5 options:0 animations:^{
           self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
       } completion:^(BOOL finished) {
           [self removeFromSuperview];
       }];

   }];

}

@end
