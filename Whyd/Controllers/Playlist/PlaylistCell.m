//
//  PlaylistCell.m
//  Whyd
//
//  Created by Damien Romito on 24/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "PlaylistCell.h"
#import "UIImageView+WebCache.h"


#define IMAGE_RECT CGRectMake(11, 15, 45, 45)


@interface PlaylistCell()
@property (nonatomic, strong) UIImageView *selectedImage;
@end
@implementation PlaylistCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier containingTableView:containingTableView leftUtilityButtons:leftUtilityButtons rightUtilityButtons:rightUtilityButtons];
    
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_4];
        self.textLabel.textColor = WDCOLOR_BLACK;
        
        
        //PLACEHOLDER
        UIImageView *placeholder = [[UIImageView alloc]initWithFrame:IMAGE_RECT];
        placeholder.image = [UIImage imageNamed:@"PlaylistPlaceholder"];
        [self.contentView addSubview:placeholder];
        
        //IMAGE
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView bringSubviewToFront:self.imageView];

        //IMAGE MASK
        UIImageView *imageMask = [[UIImageView alloc] initWithFrame:IMAGE_RECT];
        imageMask.image = [UIImage imageNamed:@"AddPlaylistCoverMask"];
        [self.contentView addSubview:imageMask];
        [self.contentView bringSubviewToFront:imageMask];

        
        self.selectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(283, 26, 16, 12)];
        self.selectedImage.image = [UIImage imageNamed:@"AddPlaylistIconSelectedName"];
        self.selectedImage.hidden = YES;
        [self.contentView addSubview:self.selectedImage];
    }
    
    return self;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.contentView.frame = CGRectMake(-1, -1, 322, self.frame.size.height + 1);
    [self.contentView sendSubviewToBack:self.imageView];

    self.textLabel.frame = CGRectMake(70, 0, 200, self.frame.size.height);
    
    self.imageView.frame = IMAGE_RECT;

}

- (void)setPlaylist:(Playlist *)playlist
{
    _playlist = playlist;
    self.textLabel.text = playlist.name;
    
    NSURL *imageUrl = [NSURL URLWithString:playlist.imageUrl];
    [self.imageView sd_setImageWithURL:imageUrl];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.selectedImage.hidden = !isSelected;
    if(isSelected)
    {
        self.textLabel.textColor = WDCOLOR_BLUE;
        
    }else
    {
        self.textLabel.textColor = WDCOLOR_BLACK;
    }
}





@end
