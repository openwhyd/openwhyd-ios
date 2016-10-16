//
//  SettingsCell.m
//  Whyd
//
//  Created by Damien Romito on 06/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsCell.h"

@implementation SettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_4];
        self.textLabel.textColor = WDCOLOR_BLUE_DARK;
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SettingIconNextView"]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(11, 1, self.frame.size.width, self.frame.size.height);
}

@end
