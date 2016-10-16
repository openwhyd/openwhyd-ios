//
//  SettingsSharingCell.m
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "SettingsSharingCell.h"


@interface SettingsSharingCell()

@property (nonatomic) SharingType type;

@end
@implementation SettingsSharingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSharingType:(SharingType)sharingType
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _type = sharingType;
        
        // Initialization code
        NSString *imageName;
        switch (sharingType) {
            case SharingTypeFacebook:{
                imageName = @"SettingSharingIconFacebook";
            }break;
            case SharingTypeTwitter:{
                imageName = @"SettingSharingIconTwitter";
            }break;
        }
        
        self.imageView.image = [UIImage imageNamed:imageName];
        self.textLabel.textColor = WDCOLOR_BLACK_LIGHT;
        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_4];
        
        self.detailTextLabel.textColor = WDCOLOR_BLUE;
        self.detailTextLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SettingIconNextView"]];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(11, 11, 25, 25);
    
    self.textLabel.frame = CGRectMake(45, 0, 290, self.frame.size.height);
    
    self.detailTextLabel.frame = CGRectMake(140, 0, self.frame.size.width - 170, self.frame.size.height);
}






@end
