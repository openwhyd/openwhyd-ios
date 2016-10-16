//
//  HotTracksCell.m
//  Whyd
//
//  Created by Damien Romito on 26/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "GenreCell.h"


@interface GenreCell()
@property (nonatomic, strong) UIImageView *selectedImage;
@end
@implementation GenreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UICOLOR_CLEAR;
        // Initialization code
        self.textLabel.textColor = WDCOLOR_BLACK_LIGHT;
        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:13];
        self.selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HotTrackIconSelected"]];
        self.selectedImage.hidden = YES;
        [self.contentView addSubview:self.selectedImage];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setGenre:(Genre *)genre
{
   _genre = genre;
    NSString *titleString;
    if ([genre.name isEqualToString:@"GenreAll"]) {
        titleString = [NSLocalizedString(@"GenreAll", nil) uppercaseString];
    }else
    {
        titleString = [NSLocalizedString(genre.name, nil) uppercaseString];
    }
    
    self.textLabel.text = titleString;
    NSDictionary *attributes = @{NSFontAttributeName: self.textLabel.font};
    CGRect rect = [titleString boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil];
    CGFloat xPosition = self.frame.size.width/2 * 1.25+ rect.size.width/2;
    
    CGRect frame = self.selectedImage.frame;
    frame.origin.x = xPosition;
    frame.origin.y = 17;
    self.selectedImage.frame = frame;
    
    [self stateSelected:genre.isSelected];
    
    
}

- (void)stateSelected:(BOOL)selected
{
    self.selectedImage.hidden = !selected;
    if (selected) {
        self.textLabel.textColor = WDCOLOR_BLUE;
    }else
    {
        self.textLabel.textColor = WDCOLOR_BLACK_LIGHT;
    }
}




@end
