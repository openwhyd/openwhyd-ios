//
//  WDMessage.m
//  Whyd
//
//  Created by Damien Romito on 23/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDMessage.h"
#import "WDHelper.h"

static const CGFloat DISPLAY_DURATION = 3.;
static const CGFloat DEFAULT_HEIGHT = 32.;
@interface WDMessage()
@property (nonatomic, strong) NSString *messageString;
@property (nonatomic, strong) UIView *customView;

@property (nonatomic) BOOL withTopMargin;
@property (copy)void (^callback)();

@end
@implementation WDMessage


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

        //TAP
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
        UISwipeGestureRecognizer *swipeV = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        UISwipeGestureRecognizer *swipeH = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        swipeH.direction = ( UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight  );
        swipeV.direction = ( UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown );
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:swipeH];
        [self addGestureRecognizer:swipeV];


    }
    return self;
}

- (void)show
{
    
    //LABEL
    if (self.messageString) {
        UILabel *messageLabel = [[UILabel alloc] init];

        CGRect frame = self.frame;
        if (self.withTopMargin) {
            frame.origin.y += 20;
            frame.size.height -=20;
        }
        
        messageLabel.frame = frame;
        messageLabel.text = self.messageString;
        messageLabel.textColor = UICOLOR_WHITE;
        messageLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:messageLabel];

    }
    
    if (self.customView) {
        [self addSubview:self.customView];
        
        CGRect frame = self.customView.frame;
        frame.origin.y = frame.size.height - DEFAULT_HEIGHT;
        self.customView.frame = frame;
        
        frame = self.frame;
        frame.size.height =  self.customView.frame.origin.y + self.customView.frame.size.height;
        self.frame = frame;
        
 
    }

    
    self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        [WDHelper runAfterDelay:DISPLAY_DURATION block:^{
            [self hide];
        }];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)actionTap
{
    if (self.callback) {
        self.callback();
        [self hide];
    }else
    {
        [self hide];
    }
}


+ (void)showMessage:(NSString*)message withCustomView:(UIView*)customView inView:(UIView*)container withTopMargin:(BOOL)withTopMargin withBackgroundColor:(UIColor*)backgroundColor callback:(void (^)())callback
{
    CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;
    
    WDMessage *messageView = [[WDMessage alloc] initWithFrame:CGRectMake(0, 0, size.width, (withTopMargin)?DEFAULT_HEIGHT+40:DEFAULT_HEIGHT)];
    messageView.backgroundColor =(backgroundColor == nil)?WDCOLOR_BLACK:backgroundColor ;
    messageView.callback = callback;

  //  messageView.messageButton = buttonText;
    if(message)
    {
        messageView.messageString = message;
    }else if(customView)
    {
        messageView.customView = customView;
    }
   
    messageView.withTopMargin = withTopMargin;
    
    if (container) {
        [container addSubview:messageView];
        messageView.withTopMargin = withTopMargin;
    }else
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:messageView];
        messageView.withTopMargin = YES;
    }
    [messageView show];
}


//+ (void)showMessage:(NSString*)message inView:(UIView*)container withTopMargin:(BOOL)withTopMargin withBackgroundColor:(UIColor*)backgroundColor callback:(void (^)())callback
//{
//    [self showMessage:message inView:container withTopMargin:withTopMargin withBackgroundColor:backgroundColor callback:callback onTextButton:nil];
//    
//}
+ (void)showCustomView:(UIView*)customView inView:(UIView*)container withTopMargin:(BOOL)withTopMargin withBackgroundColor:(UIColor*)backgroundColor callback:(void (^)())callback
{
    [WDMessage showMessage:nil withCustomView:customView inView:container withTopMargin:withTopMargin withBackgroundColor:backgroundColor callback:callback];
}


+ (void)showMessage:(NSString*)message inView:(UIView*)container withTopMargin:(BOOL)withTopMargin withBackgroundColor:(UIColor*)backgroundColor callback:(void (^)())callback
{
    [WDMessage showMessage:message withCustomView:nil inView:container withTopMargin:withTopMargin withBackgroundColor:backgroundColor callback:callback];
}



+ (void)showMessage:(NSString*)message inView:(UIView*)container withTopMargin:(BOOL)withTopMargin withBackgroundColor:(UIColor*)backgroundColor
{
    [WDMessage showMessage:message withCustomView:nil inView:container withTopMargin:withTopMargin withBackgroundColor:backgroundColor callback:nil];
}


+ (void)showMessage:(NSString*)message inView:(UIView*)container withTopMargin:(BOOL)withTopMargin
{
    
    [WDMessage showMessage:message inView:container withTopMargin:withTopMargin withBackgroundColor:WDCOLOR_BLACK];

}

+ (void)showMessage:(NSString*)message inView:(UIView*)container
{
    [WDMessage showMessage:message inView:container withTopMargin:NO];
}

+ (void)showMessage:(NSString*)message
{
    UIView *topView = [[[UIApplication sharedApplication]delegate] window].rootViewController.view;
    [WDMessage showMessage:message inView:topView withTopMargin:NO];
}

@end
