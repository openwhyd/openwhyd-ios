//
//  SearchTableViewCell.m
//  Whyd
//
//  Created by Damien Romito on 11/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TrackSearchCell.h"
#import "UIImageView+WebCache.h"
#import "WDPlayerConfig.h"
#import "UIImage+Additions.h"
#import "UIImage+animatedGIF.h"
#import "WDPlayerManager.h"
#import "WDPlayerButton.h"
#import "OHAttributedLabel.h"
#import "User.h"


@interface TrackSearchCell ()
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) WDPlayerButton* playButton;
@property (nonatomic,strong) UIImageView *detailImageView;
@property (nonatomic, strong) OHAttributedLabel *detailLabel;

@property (nonatomic,strong) UIButton *userButton;
@end

#define IMAGE_RECT CGRectMake(11, 11, 40, 40)

@implementation TrackSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andType:(SearchCellType)searchCellType
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;

        // Initialization coded
        self.type = searchCellType;

        //IMAGE MASK
        UIImageView *imageMask = [[UIImageView alloc] initWithFrame:IMAGE_RECT];
        imageMask.image = [UIImage imageNamed:@"SearchSquareMask"];
        [self.contentView addSubview:imageMask];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        //PLAY BUTTON
        self.playButton = [[WDPlayerButton alloc] initWithOrigin:CGPointMake(-1, -1)];
        self.playButton.transform = CGAffineTransformMakeScale(.63, .63);
        [self.playButton addTarget:self action:@selector(actionPlay) forControlEvents:UIControlEventTouchUpInside];
        
        //TITLE
        [self.contentView addSubview:self.playButton];
        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:13];
        self.textLabel.textColor = WDCOLOR_BLACK_TITLE;
        
        if (searchCellType == SearchCellTypeWhyd) {
            
            self.detailLabel = [[OHAttributedLabel alloc] init];
            self.detailLabel.frame = CGRectMake(83, 34, 180, 20);
            self.detailLabel.textColor = WDCOLOR_BLUE;
            self.detailLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_2];
            [self.contentView addSubview:self.detailLabel];
            
            self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(63, 33, 16, 16)];
            self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.detailImageView.clipsToBounds = YES;
            [self.contentView addSubview:self.detailImageView];
            
            UIImageView *userMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchUserMask"]];
            userMask.frame = self.detailImageView.frame;
            [self.contentView addSubview:userMask];
        }else
        {

            self.detailTextLabel.textColor = WDCOLOR_GRAY_TEXT_DARK_MEDIUM;
            self.detailTextLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_2];
            
            self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(63, 33, 21, 16)];
            self.detailImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:self.detailImageView];

        }
     //   [self.contentView addSubview:self.userButton];

        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(size.width - 35 , 20, 25, 25)];
        [addButton setImage:[UIImage imageNamed:@"SearchIconAddShortcut"] forState:UIControlStateNormal];
        addButton.layer.borderColor = WDCOLOR_BLUE.CGColor;
        addButton.layer.borderWidth = 1;
        addButton.layer.cornerRadius = CORNER_RADIUS;
        addButton.clipsToBounds = YES;
        [addButton addTarget:self action:@selector(actionAdd) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addButton];
        [self addObserver:self forKeyPath:@"track.state" options:NSKeyValueObservingOptionNew context:NULL];

        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(63, 16, self.frame.size.width  -  110, 15) ;
    if (self.type == SearchCellTypeExternal) {
        self.detailTextLabel.frame = CGRectMake(88, 33, 180, 16);
    }
    self.imageView.frame = IMAGE_RECT;
    [self.contentView sendSubviewToBack:self.imageView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.type == SearchCellTypeExternal) {
        [self.delegate trackCellAdd:self];
        
    }else
    {
        CGPoint location = [[touches anyObject] locationInView:self];
        if (location.x > 275) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            [self.delegate trackCellAdd:self];
        }else
        {
            [super touchesEnded:touches withEvent:event];
            
        }
    }

}


#pragma mark ACTIONS

- (void)actionAdd
{
    [self.delegate trackCellAdd:self];

}

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
            [self.delegate trackCellPlay:self];
            break;
        case TrackStateUnavailable:
            [self.delegate trackCellPlayUnaivailable];
            break;
        default:
            break;
            
    }
}



- (void)setTrack:(WDTrack *)track
{
    _track = track;
    self.playButton.selected = (self.track == [WDPlayerManager manager].currentTrack);

    self.selectionStyle = UITableViewCellSelectionStyleDefault;

    
    //TEXT
    self.textLabel.text =  track.name;
    
    if (self.type == SearchCellTypeWhyd) {
        
        NSURL *imageUrl = [NSURL URLWithString:[track.user imageUrl:UserImageSizeSmall]];
        [self.detailImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
        
        NSString *names;
        if (track.doublonCount) {
            names = [NSString stringWithFormat:NSLocalizedString(@"SearchPeopleCount", nil), track.user.name,track.doublonCount ];
            
            NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:names];
            [attributedString setTextColor:RGBCOLOR(105, 149, 186)];
            [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_2]];
            
            NSRange range ={0,track.user.name.length};
            [attributedString setTextColor:WDCOLOR_BLUE range:range];
            [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_2] range:range];
            
            self.detailLabel.attributedText = attributedString;
            
        }else
        {
            names = track.user.name;
            self.detailLabel.text = names;


        }
        
        
      

    }else
    {
        
        if (track.sourceKey == WDSourceSoundcloud)
        {
            [self.detailImageView setImage:[UIImage imageNamed:@"SearchIconSoundcloud"]];
            self.detailTextLabel.text = NSLocalizedString(@"SearchPoweredSouncloud", nil);
        }else if (track.sourceKey == WDSourceYoutube)
        {

            [self.detailImageView setImage:[UIImage imageNamed:@"SearchIconYoutube"]];
            self.detailTextLabel.text = NSLocalizedString(@"SearchPoweredYoutube", nil);
        }
    }
    
    //IMAGE
    NSURL *imageUrl = [NSURL URLWithString:track.img];
    [self.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageWithColor:WDCOLOR_GRAY_PLACEHOLDER_IMAGE]];
    
    
}


#pragma Notifications

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
            self.playButton.backgroundColor = RGBACOLOR(24, 27, 31, .76);
            
        }
            break;
            
    }
    
    if (self.track.state != TrackStateUnavailable) {
        
       self.playButton.backgroundColor = UICOLOR_CLEAR;
    }
    
    
}



- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"track.state"];
    
}

@end
