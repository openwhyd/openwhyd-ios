//
//  Activity.m
//  Whyd
//
//  Created by Damien Romito on 07/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Activity.h"
#import "WDClient.h"
#import "WDHelper.h"
#import "NSDictionary+Additions.h"
#import "Playlist.h"

static const NSInteger MAX_ACTIVITIES_HISTORY = 30;



@implementation Activity


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"pId": @"pId",
             @"track": @"track",
             @"lastAuthor": @"lastAuthor",
             @"n": @"n",
             @"img": @"img",
             @"html": @"html",
             @"href": @"href",
             @"message":@"message",
             @"t": @"t",
             @"type":@"type",
             //@"playlist":@"playlist"
             };
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    
    
    self = [super initWithDictionary:dictionaryValue error:error];
    
    
    
    //PARSING
  

    if (!self.isParsed) {
        self.isParsed = YES;
        
        if ([self.type isEqualToString:@"reco"])
        {
            self.activityType = ActivityTypeReco;
        }
        else if ([self.pId hasSuffix:@"reposts"])
        {
            self.activityType = ActivityTypeRepost;
            self.id = [self.pId substringToIndex:24];
            self.href = [NSString stringWithFormat:@"/c/%@", self.id ];
            
        }else if ([self.pId hasSuffix:@"loves"])
        {
            self.id = [self.pId substringToIndex:24];
            self.activityType = ActivityTypeLike;
            self.href = [NSString stringWithFormat:@"/c/%@", self.id ];
        }else if ([self.pId hasPrefix:@"/u/"])
        {
            self.id = [self.pId substringFromIndex:3];
            self.activityType = ActivityTypeFollow;
            self.href = self.pId;
            
        }else if ([self.pId hasSuffix:@"comments"])
        {
            self.id = [self.pId substringToIndex:24];
            self.activityType = ActivityTypeComment;
        }else if ([self.html rangeOfString:@"mentionned"].length )
        {
            self.activityType = ActivityTypeMention;
            self.track.id = [self.href substringFromIndex:3];
            
        }else if ([self.type isEqualToString:@"Snt"])
        {
            self.activityType = ActivityTypeSendTrack;
            self.track.id = [self.href substringFromIndex:3];
            
        }else if ([self.type isEqualToString:@"Snp"])
        {
            self.activityType = ActivityTypeSendPlaylist;             
            
        }else
        {
            return nil;
        }
        
        //LASTUSER
        if (self.activityType == ActivityTypeFollow) {
            
            self.lastAuthor.id = [self.track.eId substringFromIndex:3];
            self.lastAuthor.name = self.track.name;
            self.track = nil;
        }else if (self.activityType == ActivityTypeMention || self.activityType == ActivityTypeComment)
        {
            NSRange range = {6, [self.html rangeOfString:@"</span>"].location - 6};
            self.lastAuthor.name = [self.html substringWithRange:range];
            self.lastAuthor.id = [self.img substringFromIndex:7];
            
            range = [self.html rangeOfString:@" <span>"];
            range.location = range.location + 7;
            range.length = self.html.length - 7 - range.location;
   
            self.track.name = [self.html substringWithRange:range];
            
        }
        
        //TRACK IMAGE
        if (self.track) {
            if (self.activityType == ActivityTypeComment || self.activityType == ActivityTypeRepost || self.activityType == ActivityTypeLike || self.activityType == ActivityTypeFollow ) {
                NSRange range = [self.pId rangeOfString:@"/"];
                self.track.id = [self.pId substringToIndex:range.location];
            }
            
            self.track.img = [NSString stringWithFormat:@"%@/img/post/%@", API_BASE_URL, self.track.id];
        }
        
        
    }
    //BUG 1.2
    else if (self.activityType == ActivityTypeDefault && [self.type integerValue] > 0)
    {
        self.activityType = [self.type integerValue];
        self.type = nil;
    }

    return self;
}



+ (NSValueTransformer *)trackJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[WDTrack class]];
}

+ (NSValueTransformer *)lastAuthorJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[User class]];
}

//+ (NSValueTransformer *)playlistJSONTransformer
//{
//    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[Playlist class]];
//}

- (NSString *)date
{
    return [WDHelper dateFromString:self.t  ];
}



- (NSMutableAttributedString *)attributedText
{
    

    NSString *userString = self.lastAuthor.name;
    
    NSString *stringFormat ;
    NSRange userRange = {0, userString.length};

    
    switch (self.activityType) {
            
        case ActivityTypeDefault:{
            
        }break;
            
        case ActivityTypeComment:{
            stringFormat = NSLocalizedString(@"NotificationsComment", nil);
        }break;
            
        case ActivityTypeLike:{
             stringFormat = NSLocalizedString(@"NotificationsLike", nil);
        }break;
            
        case ActivityTypeRepost:{
             stringFormat = NSLocalizedString(@"NotificationsAddYourTrack", nil);
        }break;
            
        case ActivityTypeMention:{
             stringFormat = NSLocalizedString(@"NotificationsMention", nil);
        }break;
            
        case ActivityTypeFollow:{
             stringFormat = NSLocalizedString(@"NotificationsNewFollower", nil);
        }break;
        case ActivityTypeJoin:{
            stringFormat = NSLocalizedString(@"NotificationsFriendJoin", nil);
            userRange.location = 12;
        }break;
        case ActivityTypeSendTrack:{
            stringFormat = NSLocalizedString(@"NotificationsSendTrack", nil);
        }break;
        case ActivityTypeSendPlaylist:{
            stringFormat =NSLocalizedString(@"NotificationsSendPlaylist", nil);
        }break;
        case ActivityTypeReco:{
            stringFormat = self.message;

        }break;
    }

    
    //multi users
    if ([self.n intValue] > 1) {
        NSInteger value = [self.n intValue] - 1;
        userString = [NSString stringWithFormat:NSLocalizedString(@"NotificationsMultiPeople", nil), userString, (int)value ];
    }
    
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:stringFormat, userString ]];
    
    
    [attributedString setTextColor:RGBCOLOR(50, 50, 50)];
    [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3]];
    
    [attributedString setTextColor:WDCOLOR_BLUE range:userRange];
    [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3] range:userRange];
    
//    NSURL *userURL = [NSURL URLWithString: OPEN_URL_USER(self.lastAuthor.id)];
//    [attributedString setLink:userURL range:userRange];
    
    
    return attributedString;
}




+ (void) refreshNotificationsHistoryAndRead:(BOOL)isRead success:(void (^)(NSArray *notifications))success
{
   
    [[WDClient client] GET:API_NOTIFICATIONS parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray* history = [[NSUserDefaults standardUserDefaults] arrayForKey:USERDEFAULT_NOTIFICATIONS] ;
        NSUInteger newCount  = 0;
        
        /**************** GET NEWS NOTIFS **********************/
        NSMutableArray *notifications = [[NSMutableArray alloc] init];
        for (NSDictionary *a in responseObject) {
            Activity *activity = [MTLJSONAdapter modelOfClass:[Activity class] fromJSONDictionary:a error:nil];
            
//            //is in history? 
//            if (history.firstObject && [activity.t isEqualToString:[history.firstObject valueForKey:@"t"]]) {
//                break;
//            }
            
            if(activity)
            {
                
                [notifications addObject:activity];
                newCount += [activity.n integerValue];
            }
        }
        
        //SORT NEW NOTIFS
        [notifications sortUsingComparator:^NSComparisonResult(Activity *act1, Activity * act2) {
            return [act2.t compare:act1.t];
        }];

        
        NSUInteger numberResult = notifications.count;
        
        /**************** NOTIFS TO DISPLAY **********************/
        
        if (history.count && numberResult < MAX_ACTIVITIES_HISTORY) {
            
            //TTO MANY NOTIFS
            if(numberResult + history.count > MAX_ACTIVITIES_HISTORY)
            {
                NSUInteger historyCount = MAX_ACTIVITIES_HISTORY - numberResult;
                NSRange range = {0, historyCount};
                history = [history subarrayWithRange:range] ;
            }
            
            //Merge new + history
            for (NSDictionary *historyNotif in history) {
              
                    Activity *notif = [MTLJSONAdapter modelOfClass:[Activity class] fromJSONDictionary:historyNotif error:nil];
                    notif.fromHistory = YES;
                    [notifications addObject:notif];
            }
        }


         /****************SAVE IN HISTORY **********************/
        if (isRead) {
            
            //UPDATE HISTORY
            NSMutableArray *newsNotificationsUserDefault = [[NSMutableArray alloc] init];
            for (Activity *activity in notifications) {
                [newsNotificationsUserDefault addObject:[NSDictionary dictionaryWithPropertiesOfObject:activity]];
            }
            [[NSUserDefaults standardUserDefaults] setObject:newsNotificationsUserDefault forKey:USERDEFAULT_NOTIFICATIONS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            //MARK AS READ
            NSDictionary *parameters = @{@"action":@"deleteAll"};
            [[WDClient client] POST:API_NOTIFICATIONS parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
            }];
        }else
        {
            [UIApplication sharedApplication].applicationIconBadgeNumber = newCount;
        }

        //PUS NOTIF COUNT
        NSDictionary *userInfo = @{NOTIFICATION_NOTIFICATIONS_UPDATE_COUNT_KEY:(isRead)?@0:@(newCount)};
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NOTIFICATIONS_UPDATE object:nil userInfo:userInfo];

        if (success) {
            success(notifications);
        }

        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    
}


+ (CGFloat) heightForText:(Activity*)activity
{
    OHAttributedLabel *sizer = [[WDHelper manager] sizer];
    sizer.frame = CGRectMake(0, 0, INFO_WIDTH, 9999);
    sizer.attributedText = activity.attributedText;
    [sizer sizeToFit];
    CGFloat height = 50 + (sizer.frame.size.height - 15);
    return height;
}


@end
