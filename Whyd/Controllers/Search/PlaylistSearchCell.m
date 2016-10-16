//
//  PlaylistSearchCell.m
//  Whyd
//
//  Created by Damien Romito on 27/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PlaylistSearchCell.h"
#import "UIImageView+WebCache.h"
#import "WDClient.h"
#import "WDTrack.h"
#import "WDPlayerManager.h"

#define IMAGE_RECT CGRectMake(11, 11, 40, 40)


@interface PlaylistSearchCell()
@property (nonatomic, strong) UILabel *tracksCountLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic) BOOL hasPlayButton;
@end
@implementation PlaylistSearchCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        
        //PLACEHOLDER
        UIImageView *placeholder = [[UIImageView alloc]initWithFrame:IMAGE_RECT];
        placeholder.image = [UIImage imageNamed:@"SearchPlaylistPlaceholder"];
        [self.contentView addSubview:placeholder];
        [self.contentView sendSubviewToBack:placeholder];
        
        //IMAGE
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;

        //MASK
        UIImageView *imageMask = [[UIImageView alloc] initWithFrame:IMAGE_RECT];
        imageMask.image = [UIImage imageNamed:@"SearchSquareMask"];
        [self.contentView addSubview:imageMask];
        [self.contentView bringSubviewToFront:imageMask];

        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:13];
        self.textLabel.textColor = WDCOLOR_BLACK_TITLE;
        

        //TRACK COUNT LABEL
        self.detailTextLabel.textColor = WDCOLOR_GRAY_TEXT_DARK_MEDIUM;
        self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.detailTextLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:13];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    //TEXTS
    self.textLabel.frame = CGRectMake(63, 13, 240, 16);
    self.detailTextLabel.frame = CGRectMake(63, 35, 210, 11);
    
    //IMAGES
    self.imageView.frame = IMAGE_RECT;

}

- (void)setPlaylist:(Playlist *)playlist
{
    _playlist = playlist;
    self.textLabel.text = playlist.name;
    NSNumber *tracksCount = playlist.nbTracks;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%i %@", [tracksCount intValue] , ([tracksCount intValue] == 1)?[NSLocalizedString(@"Track", nil) uppercaseString] :[NSLocalizedString(@"Tracks", nil) uppercaseString] ];
    NSURL *imageUrl = [NSURL URLWithString:playlist.imageUrl];
    [self.imageView sd_setImageWithURL:imageUrl];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
