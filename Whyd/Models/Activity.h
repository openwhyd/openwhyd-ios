//
//  Activity.h
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Mantle.h"
#import "User.h"
#import "WDTrack.h"

static CGFloat const INFO_WIDTH = 210.;


typedef NS_ENUM(NSUInteger, ActivityType) {
    
	ActivityTypeDefault = 0,
    ActivityTypeLike = 1,
    ActivityTypeComment = 2,
    ActivityTypeRepost = 3,
    ActivityTypeFollow = 4,
    ActivityTypeMention = 5,
    ActivityTypeJoin = 6,
    ActivityTypeSendTrack = 7,
    ActivityTypeSendPlaylist = 8,
    ActivityTypeReco = 9,
};

@interface Activity : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *pId;
@property (nonatomic, strong) User *lastAuthor;
@property (nonatomic, strong) WDTrack *track;
@property (nonatomic, strong) Playlist *playlist;

@property (nonatomic, strong) NSNumber *n;
@property (nonatomic) ActivityType activityType;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, strong) NSString *html;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *t;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *type;

@property (nonatomic) BOOL fromHistory;
//@property (nonatomic, strong) NSMutableAttributedString *attributedText;
@property (nonatomic) BOOL isParsed;

- (NSMutableAttributedString *)attributedText;
+ (CGFloat) heightForText:(Activity*)activity;
+ (void) refreshNotificationsHistoryAndRead:(BOOL)isRead success:(void (^)(NSArray *notifications))success;
@end
