//
//  OnboardingGenreCell.h
//  Whyd
//
//  Created by Damien Romito on 01/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Genre.h"

@interface OnboardingGenreCell : UICollectionViewCell
@property (nonatomic, strong) Genre *genre;
@property (nonatomic) BOOL checked;
@end
