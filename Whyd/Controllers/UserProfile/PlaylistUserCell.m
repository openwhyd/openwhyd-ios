//
//  PlaylistSearchCell.m
//  Whyd
//
//  Created by Damien Romito on 27/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PlaylistUserCell.h"
#import "UIImageView+WebCache.h"
#import "WDClient.h"
#import "WDTrack.h"
#import "WDPlayerManager.h"

#define IMAGE_RECT CGRectMake(11, 13, 70, 70)


@interface PlaylistUserCell()
@property (nonatomic, strong) UILabel *tracksCountLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic) BOOL hasPlayButton;
@end

@implementation PlaylistUserCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;

        
        //PLACEHOLDER
        UIImageView *placeholder = [[UIImageView alloc]initWithFrame:IMAGE_RECT];
        placeholder.image = [UIImage imageNamed:@"PlaylistPlaceholder"];
        [self.contentView addSubview:placeholder];
        [self.contentView sendSubviewToBack:placeholder];
        
        //IMAGE
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        //MASK
        UIImageView *imageMask = [[UIImageView alloc] initWithFrame:IMAGE_RECT];
        imageMask.image = [UIImage imageNamed:@"ProfilePlaylistMask"];
        [self.contentView addSubview:imageMask];
        [self.contentView bringSubviewToFront:imageMask];
        
        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:13];
        self.textLabel.textColor = WDCOLOR_BLACK_TITLE;
        

        self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(size.width - 55, 22, 50, 50)];
        [self.playButton setImage:[UIImage imageNamed:@"ProfileButtonPlayAllPlaylist"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(actionPlayAllPlaylist) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playButton];
  
    
        
        //TRACK COUNT LABEL
        self.detailTextLabel.textColor = RGBCOLOR(146, 147, 149);
        self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.detailTextLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:13];
    }
    return self;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    //TEXTS
    self.textLabel.frame = CGRectMake(96, 32, self.frame.size.width - 150, 16);
    self.detailTextLabel.frame = CGRectMake(96, 57, self.frame.size.width - 150, 11);
    
    //IMAGES
    self.imageView.frame = IMAGE_RECT;
    
}

- (void)setPlaylist:(Playlist *)playlist
{
    _playlist = playlist;
    self.textLabel.text = playlist.name;
    NSNumber *tracksCount = playlist.nbTracks;
    self.playButton.hidden = ([playlist.nbTracks integerValue])?NO:YES;
    
    self.detailTextLabel.text = [NSString stringWithFormat:@"%i %@", [tracksCount intValue] , ([tracksCount intValue] == 1)?[NSLocalizedString(@"Track",nil) uppercaseString] :[NSLocalizedString(@"Tracks",nil) uppercaseString] ];
    NSURL *imageUrl = [NSURL URLWithString:playlist.imageUrl];
    [self.imageView sd_setImageWithURL:imageUrl];
    
    
}

- (void)actionPlayAllPlaylist
{
    
    [[WDClient client] GET:self.playlist.url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *tracks = [[NSMutableArray alloc] init];
        for (int i = 0 ; i < [responseObject count] ; i++) {
            NSDictionary *t = [responseObject objectAtIndex:i];
            WDTrack *track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:t error:nil];
            if(track)
            {
                [tracks addObject:track];
            }
        }
        self.playlist.tracks =  tracks;
        self.playlist.shuffleEnable = YES;
        [[WDPlayerManager manager] playAtIndex:0 inPlayList:self.playlist];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end