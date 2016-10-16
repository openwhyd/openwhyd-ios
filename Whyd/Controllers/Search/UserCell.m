//
//  UserCell.m
//  Whyd
//
//  Created by Damien Romito on 27/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "UserCell.h"
#import "UIImageView+WebCache.h"
#import "WDClient.h"
#import "WDHelper.h"
#import "WDFollowButton.h"
#define IMAGE_RECT CGRectMake(11, 9, 35, 35)



@interface UserCell()
@property (nonatomic, strong) WDFollowButton *followButton;
@property (nonatomic) UserCellType type;
@end

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier withType:UserCellTypeDefault];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withType:(UserCellType)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _type = type;
        CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;

        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:13];
        self.textLabel.textColor = WDCOLOR_BLACK_TITLE;
        
        UIImageView *imageMask = [[UIImageView alloc] initWithFrame:IMAGE_RECT];
        imageMask.image = [UIImage imageNamed:@"SearchUserMask"];
        [self.contentView addSubview:imageMask];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        if (self.type == UserCellTypeDefault || self.type == UserCellTypeGenres) {
            
            
            //FOLLOW BUTTON
            self.followButton = [[WDFollowButton alloc] initWithPosition:CGPointMake(size.width - 95, 11)];
            
            if (self.type == UserCellTypeGenres) {
                self.detailTextLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:12];
                self.detailTextLabel.textColor = RGBCOLOR(155, 159, 165);
            }
            
            self.followButton.normalColor = WDCOLOR_BLUE;
            self.followButton.normalHighlightedColor = WDCOLOR_BLUE_LIGHT;
            self.followButton.selectedColor = WDCOLOR_GRAY;
            self.followButton.selectedHighlightedColor = WDCOLOR_GRAY_LIGHT2;

            [self.followButton addTarget:self action:@selector(actionFollow) forControlEvents:UIControlEventTouchUpInside];
     
            [self.contentView addSubview:self.followButton];
        }else if (self.type == UserCellTypePick)
        {
            self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SignUpIconValidate"]];
        }
        

        

    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.origin.x = 63;
    frame.origin.y = (self.type == UserCellTypeGenres)?-10:0;
    frame.size.width = (self.followButton)?150:230;
    
    if (self.type == UserCellTypeGenres) {
        self.detailTextLabel.frame = CGRectMake(63, 32,  (self.followButton)?150:230, 13);
    }
    
    self.textLabel.frame = frame;
    self.imageView.frame = IMAGE_RECT;
    [self.contentView sendSubviewToBack:self.imageView];
}


- (void)setUser:(User *)user
{
    
    _user = user;
    self.active = NO;
    self.textLabel.text = user.name;
    NSURL *imageUrl = [NSURL URLWithString:[user imageUrl:UserImageSizeSmall]];
    [self.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"UserImagePlaceholder"]];
    
    if ([[WDHelper manager].currentUser.id isEqualToString:user.id]) {
        self.followButton.hidden = YES;
    }else
    {
        self.followButton.selected = self.user.isSubscribing;
        self.followButton.hidden = NO;
    }

    if (self.type == UserCellTypeGenres) {
        NSString *genres = @"";
        for (NSDictionary *genre in self.user.tags) {
            genres = [NSString stringWithFormat:@"%@%@%@", genres, ([genres isEqualToString:@""])?@"":@" - " ,[genre valueForKey:@"id"] ];
        }
        self.detailTextLabel.text = genres;
        
    }
    
}


- (void)actionFollow
{
    
    self.user.isSubscribing = !self.user.isSubscribing;
    self.followButton.selected = self.user.isSubscribing;

    if([self.delegate respondsToSelector:@selector(userCell:isFollow:)])
    {
        [self.delegate userCell:self isFollow:self.user.isSubscribing];
    }else
    {
        NSDictionary *parameters = @{@"tId":self.user.id,
                                     @"action": (self.user.isSubscribing)?@"insert":@"delete"};
        [[WDClient client] GET:API_USER_FOLLOW parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            if (self.user.isSubscribing) {
                [WDHelper manager].currentUser.nbSubscriptions ++;
            }else
            {
                [WDHelper manager].currentUser.nbSubscriptions --;
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }

}

- (void) setActive:(BOOL)active
{
    if (active) {
        self.accessoryView.hidden = NO;
        self.imageView.alpha = .5;
        self.textLabel.alpha = .5;
    }else
    {
        self.accessoryView.hidden = YES;
        self.imageView.alpha = 1;
        self.textLabel.alpha = 1;
    }
}





@end
