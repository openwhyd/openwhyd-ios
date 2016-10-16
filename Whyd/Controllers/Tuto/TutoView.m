//
//  TutoViewController.m
//  Whyd
//
//  Created by Damien Romito on 11/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TutoView.h"
#import "GHContextMenuView.h"
#import "UIImage+Additions.h"
#import "OHAttributedLabel.h"
#import "WDHelper.h"

@interface TutoView ()< GHContextOverlayViewDelegate>
@property (nonatomic, strong) UIImageView * animatedCircle;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) OHAttributedLabel *infosLabel;
@property (nonatomic, strong) UIView *infosView;
@property (nonatomic, strong) UIButton *infosButton;
@property (nonatomic) BOOL alreadyTap;
@end

@implementation TutoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
        overlay.delegate = self;
        
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:USERDEFAULT_TUTO_SEEN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:longPress];
        self.userInteractionEnabled = YES;
        
        self.infosView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 110)];
        self.infosView.backgroundColor = RGBCOLOR(23, 25, 29);
        [self addSubview:self.infosView];
        
        self.infosLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10, 38, self.frame.size.width-120, 70)];
        self.infosLabel.numberOfLines = 0;
        self.infosLabel.alpha = 0;

        NSString *boldString = NSLocalizedString(@"TutoInfoBold", nil);
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@ %@",boldString, NSLocalizedString(@"TutoInfo", nil)]];
        [attrStr setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3]];
        [attrStr setTextColor:RGBACOLOR(255, 255, 255, .7)];
        NSRange range = [attrStr.string rangeOfString:boldString];
        [attrStr setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3] range:range];
        [attrStr setTextColor:UICOLOR_WHITE range:range];
//        [attrStr setTextAlignment:kCTCenterTextAlignment lineBreakMode:0];
        self.infosLabel.attributedText = attrStr;
        [self.infosView addSubview:self.infosLabel];
        
        self.infosButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 26, self.frame.size.width-70, 40)];
        self.infosButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
        [self.infosButton setTintColor:UICOLOR_WHITE];
        self.infosButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.infosView addSubview:self.infosButton];
        

        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, 0, 40, self.infosView.frame.size.height)];
        [closeButton setImage:[UIImage imageNamed:@"TutorialIconClose"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(actionSkip) forControlEvents:UIControlEventTouchUpInside];
        [self.infosView addSubview:closeButton];
        
        
        self.animatedCircle = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 5, 162, 72, 74)];
        self.animatedCircle.image = [UIImage imageNamed:@"TutorialButtonPouceHelp"];
        self.animatedCircle.transform = CGAffineTransformMakeScale(0, 0);
        self.animatedCircle.alpha = 0;
        [self addSubview: self.animatedCircle];

        [self actionAnimationCirle];
        
        if (self.infosLabel.alpha == 0) {
            self.infosLabel.transform = CGAffineTransformMakeTranslation(0, 10);
            [UIView animateWithDuration:0.2 delay:0.7 options:0 animations:^{
                self.infosLabel.transform = CGAffineTransformMakeTranslation(0, 0);
                self.infosLabel.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    return self;
}


- (void)show
{
    
}

- (void)hide
{
}

- (void)actionDisplayText:(NSString *)string andImageString:(NSString *)imageString
{

    
    self.infosLabel.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        if (self.infosLabel.alpha == 1) {
            self.infosLabel.alpha = 0;
            self.infosLabel.transform = CGAffineTransformMakeTranslation(0, -10);
        }else
        {
            self.infosButton.alpha = 0;
            self.infosButton.transform = CGAffineTransformMakeTranslation(0, -10);
        }

    } completion:^(BOOL finished) {
        self.infosButton.transform = CGAffineTransformMakeTranslation(0, 10);
        [self.infosButton setImage:[UIImage imageNamed:imageString] forState:UIControlStateNormal];
        [self.infosButton setTitle:string forState:UIControlStateNormal];
        if (imageString) {
            self.infosButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.infosButton.alpha = 1;
            self.infosButton.transform = CGAffineTransformMakeTranslation(0, 10);
        } completion:^(BOOL finished) {

        }];
    }];
}

- (void)actionAnimationCirle
{
    [UIView animateWithDuration:0.2 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.animatedCircle.transform = CGAffineTransformMakeScale(1, 1);
        self.animatedCircle.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.animatedCircle.transform = CGAffineTransformMakeScale(0.7, 0.7);
        } completion:^(BOOL finished) {
            [self actionAnimationCirle];
        }];
    }];
    
}

- (void)actionSkip
{

    [Flurry logEvent:FLURRY_TUTO_SKIP];
    [self actionClose];
}

- (void)actionClose
{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.infosView.transform = CGAffineTransformMakeTranslation(0, -self.infosView.frame.size.height);
        self.animatedCircle.alpha = 0;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(TutoClosed)]) {
            [self.delegate TutoClosed];
        }
        [self removeFromSuperview];
    }];
}

- (void)actionTap
{
    if (!self.alreadyTap) {
        self.alreadyTap = YES;
        [self actionDisplayText:NSLocalizedString(@"TutoKeepHolding", nil) andImageString:nil];
    }else
    {
        [self actionDisplayText:NSLocalizedString(@"TutoKeepHolding2", nil) andImageString:@"TutorialIconInformation"];

    }
    
}

#pragma mark GHContextMenu Delegate

- (void)didSelectItemType:(MenuActionType)type
{
    [Flurry logEvent:FLURRY_TUTO_SUCCESS];
}


- (void)overlayViewIsOpen
{
    [self actionDisplayText:NSLocalizedString(@"TutoGreat", nil) andImageString:@"TutorialIconcongratulation"];
    [UIView animateWithDuration:0.2 animations:^{
        self.animatedCircle.alpha = 0;
    } completion:^(BOOL finished) {
        [self.animatedCircle removeFromSuperview];
        
    }];
    
  
}

- (void)overlayViewIsClose
{
    [WDHelper runAfterDelay:2 block:^{
        [self actionClose];
    }];
    
}

@end
