//
//  OnboardingGenreCell.m
//  Whyd
//
//  Created by Damien Romito on 01/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "OnboardingGenreCell.h"


@interface OnboardingGenreCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *selectedImageView;

@end
@implementation OnboardingGenreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSLog(@"WIDTHHHH %f", self.frame.size.width);
        CGFloat width = self.frame.size.width - 8;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8 , 0, width, width* 0.75)];
        [self.contentView addSubview:self.imageView];
        
        self.selectedImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
        self.selectedImageView.image = [UIImage imageNamed:@"OnboardingGenreIconChecked"];
        self.selectedImageView.backgroundColor = WDCOLOR_BLUE;
        self.selectedImageView.alpha = 0.8;
        self.selectedImageView.hidden = YES;
        [self.contentView addSubview:self.selectedImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8 , width* 0.75 - 26, width, 13)];
        self.titleLabel.textColor = UICOLOR_WHITE;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
        [self.contentView addSubview:self.titleLabel];
        
        
        
    }
    return self;
}

- (void)setGenre:(Genre *)genre
{
    _genre = genre;
    self.titleLabel.text = [NSLocalizedString(genre.name, nil) uppercaseString];
    self.imageView.image = [UIImage imageNamed:genre.image];
    self.checked = genre.isSelected;
    
}


- (void)setChecked:(BOOL)checked
{
    self.genre.isSelected = checked;
    self.selectedImageView.hidden = !checked;

}



@end
