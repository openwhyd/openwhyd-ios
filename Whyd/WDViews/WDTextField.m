
#import "WDTextField.h"

@interface WDTextField()<UITextFieldDelegate>
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIButton *hideShowButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *successImageView;
@property (nonatomic, strong) UIImageView *failedImageView;
@property (nonatomic, strong) UILabel *titelLabel;
@property (nonatomic) CGRect STATE_INDICATOR_FRAME;


@end
@implementation WDTextField

CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0.25;

- (instancetype) initWithYPosition:(CGFloat)yPosition
{
    CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;
    
    return [self initWithFrame:CGRectMake(0, yPosition, size.width, 46)];
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.STATE_INDICATOR_FRAME =  CGRectMake(frame.size.width - 28, 16, 14, 10);
        
        NSLog(@"WIDTH %f",frame.size.width );

        self.font =  [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
        self.backgroundColor = UICOLOR_WHITE;
        self.textColor = WDCOLOR_BLUE;
        self.edgeInsets = UIEdgeInsetsMake(0, 100, 0, 0);
        [self addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        self.textFieldState = WDTextFieldStateDefault;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.frame = self.STATE_INDICATOR_FRAME;
        [self addSubview:self.activityIndicator];
        
        self.successImageView = [[UIImageView alloc] initWithFrame:self.STATE_INDICATOR_FRAME];
        self.successImageView.image = [UIImage imageNamed:@"SignUpIconValidate"];
        self.successImageView.hidden = YES;
        [self addSubview:self.successImageView];
        
        self.failedImageView = [[UIImageView alloc] initWithFrame:self.STATE_INDICATOR_FRAME];
        self.failedImageView.image = [UIImage imageNamed:@"SignUpIconError"];
        self.failedImageView.hidden = YES;
        [self addSubview:self.failedImageView];

        
        
    }
    return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (void)actionHideShowPassword
{
    UIButton *hideShow = (UIButton *)self.rightView;
    if (!self.secureTextEntry)
    {
        self.secureTextEntry = YES;
        [hideShow setTitle:[NSLocalizedString(@"TextFieldShow", nil) uppercaseString] forState:UIControlStateNormal];
    }
    else
    {
        self.secureTextEntry = NO;
        [hideShow setTitle:[NSLocalizedString(@"TextFieldHide", nil) uppercaseString] forState:UIControlStateNormal];
    }
    [self becomeFirstResponder];
}

#pragma SETTER

- (void)setIsPassword:(BOOL)isPassword
{
    [self setSecureTextEntry:YES];
    if (isPassword && !self.hideShowButton) {
        
        self.secureTextEntry = YES;
        self.hideShowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, self.frame.size.height)];
        self.hideShowButton.hidden = YES;
        [self.hideShowButton.titleLabel setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_2]];
        [self.hideShowButton setTitle:[NSLocalizedString(@"TextFieldShow", nil) uppercaseString]forState:UIControlStateNormal];
        self.hideShowButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 33);
        self.hideShowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.hideShowButton setTitleColor:RGBCOLOR(169, 172, 175) forState:UIControlStateNormal];
        self.rightView = self.hideShowButton;
        self.rightViewMode = UITextFieldViewModeAlways;
        [self.hideShowButton addTarget:self action:@selector(actionHideShowPassword) forControlEvents:UIControlEventTouchUpInside];
        
    }    
}

- (void)setLabelString:(NSString *)labelString
{
    if (!self.titelLabel) {
        self.titelLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, self.frame.size.width, self.frame.size.height)];
        self.titelLabel.textColor = WDCOLOR_BLUE_DARK;
        self.titelLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_4];
        [self addSubview:self.titelLabel];
    }
    self.titelLabel.text = labelString;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    UIFont* font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];

    [super setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: WDCOLOR_GRAY_LIGHT,
                                                                                                        NSFontAttributeName : font}]];
}


- (void)setState:(WDTextFieldState)state
{
    self.successImageView.hidden = YES;
    self.failedImageView.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    switch (state) {
        case WDTextFieldStateDefault:{
        }break;
            
        case WDTextFieldStateSuccess:{
            self.successImageView.hidden = NO;
        }break;
            
        case WDTextFieldStateFailed:{
            self.failedImageView.hidden = NO;

        }break;
        case WDTextFieldStateLoading:{
            [self.activityIndicator startAnimating];

        }break;
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self displayPlaceholder:!self.text.length ];

}

- (void)displayPlaceholder:(BOOL)isDisplay
{
    
    if (self.hideShowButton) {
        if (isDisplay) {
            self.hideShowButton.hidden = YES;
        }else
        {
            self.hideShowButton.hidden = NO;
        }
    }
}

#pragma Textfield delegate

- (id<WDTextFieldDelegate>) customDelegate {
    return (id<WDTextFieldDelegate>)[self delegate];
}

- (void) textFieldTextChange
{
     [self displayPlaceholder:(self.text.length < 1) ];
    if ([self.delegate respondsToSelector:@selector(WDTextField:didChangeWithString:)]) {
        [self.customDelegate WDTextField:(WDTextField *)self didChangeWithString:self.text];
    }
}

@end