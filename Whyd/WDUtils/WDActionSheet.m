//
//  WDActionSheet.m
//  Whyd
//
//  Created by Damien Romito on 09/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//


#import "WDActionSheet.h"

@interface WDActionSheet()
    @property (nonatomic, strong) NSString* title;
    @property (nonatomic, strong) NSString* cancelTitle;
    @property (nonatomic, strong) NSArray* buttonsTitles;
    @property (nonatomic, strong) UIView* bg;
    @property (nonatomic) CGFloat height;
    @property (nonatomic) CGFloat top;
@end

static CGFloat const WDACTIONSHEET_MARGIN = 11.;
static CGFloat const WDACTIONSHEET_ROW_HEIGHT = 44.;
static CGFloat const WDACTIONSHEET_ANIMATION_DURATION = 0.25;

@implementation WDActionSheet

- (instancetype)initWithTitle:(NSString *)title delegate:(id<WDActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles
{
    self = [self init];
    if (self) {
        self.autoClose = YES;
        self.buttonsTitles = otherButtonTitles;
        self.title = title;
        self.cancelTitle = cancelButtonTitle;
        self.delegate = delegate;
    }
    
    return self;

}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        
        /***************** BACKGROUND *******************/
        self.bg = [[UIView alloc] initWithFrame:window.bounds];
        self.bg.alpha = 0;
        self.bg.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        self.bg.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
        [self.bg addGestureRecognizer:tap];
        [window addSubview:self.bg];



    }
    return self;
}

- (void) show
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];

    self.height = 0;
    
    /***************** BUTTONS *******************/
    UIView *background = [UIView new];
    
    //TITLE
    if (self.title)
    {
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , window.frame.size.width - WDACTIONSHEET_MARGIN*2, WDACTIONSHEET_ROW_HEIGHT)];
        labelView.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = WDCOLOR_GRAY_DARK;
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.text = self.title;
        
        [background addSubview:labelView];
        self.height += WDACTIONSHEET_ROW_HEIGHT;
    }
    
    
    //OTHERS BUTTONS
    int i = 0;
    for (NSString *title in self.buttonsTitles)
    {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.height, window.frame.size.width - WDACTIONSHEET_MARGIN*2, WDACTIONSHEET_ROW_HEIGHT)];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
        [button setTitleColor:WDCOLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_4];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [background addSubview:button];
        self.height += button.frame.size.height;
        
        if ((i < self.buttonsTitles.count -1 && self.title) && i < self.buttonsTitles.count) {
            button.layer.borderColor = RGBCOLOR(244, 246, 247).CGColor;
            button.layer.borderWidth = .5;
        }
        
        
        i++;
    }
    
    
    // BACKGROUND
    background.frame = CGRectMake(WDACTIONSHEET_MARGIN,  0 , window.frame.size.width - WDACTIONSHEET_MARGIN*2, self.height);
    background.layer.cornerRadius = 3;
    background.backgroundColor = UICOLOR_WHITE;
    [self addSubview:background];
    
    
    /***************** CANCEL BUTTONS *******************/
    
    if (self.cancelTitle) {
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(WDACTIONSHEET_MARGIN,
                                                                            self.height +  WDACTIONSHEET_MARGIN ,
                                                                            window.frame.size.width - WDACTIONSHEET_MARGIN*2,
                                                                            WDACTIONSHEET_ROW_HEIGHT )];
        [cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
        [cancelButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
        [cancelButton setTitleColor:WDCOLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
        cancelButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_4];
        [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.layer.cornerRadius = 3;
        cancelButton.backgroundColor = UICOLOR_WHITE;
        [self addSubview:cancelButton];
        
        self.height += cancelButton.frame.size.height + WDACTIONSHEET_MARGIN*2;
    }
    
    
    /***************** DISPLAY *******************/
    
    self.frame = CGRectMake(0, window.frame.size.height - self.height, window.frame.size.width, self.height);
    [window addSubview: self];
    
    self.transform = CGAffineTransformMakeTranslation(0, self.height );
    
    [UIView animateWithDuration:WDACTIONSHEET_ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, -10);
                         self.bg.alpha = 1;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              self.transform = CGAffineTransformIdentity;
                                          } completion:nil];
                     }];
}




- (void) buttonClicked:(UIButton*)sender
{
     /* Run the button's block */
    if ([self.delegate respondsToSelector:@selector(clickedButtonWithTitle:)]) {
        [self.delegate clickedButtonWithTitle:sender.titleLabel.text];
    }
    
    if (self.autoClose) {
        [self close:YES];
    }
}


- (void)close
{
    [self close:YES];
}

- (void) close:(BOOL)animated
{

    if (animated) {
        [UIView animateWithDuration:WDACTIONSHEET_ANIMATION_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height + self.height);
                             self.bg.alpha = 0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             [self.bg removeFromSuperview];
                         }];
    }else
    {
        [self removeFromSuperview];
        [self.bg removeFromSuperview];
    }


}

- (void) tapView
{
    [self close:YES];
}

@end
