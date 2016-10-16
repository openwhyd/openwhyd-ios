//
//  WDPlayerUrl.h
//  Whyd
//
//  Created by Damien Romito on 12/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

static NSInteger const ERROR_METHOD_OBSELETE  =  9990;
static NSInteger const ERROR_ANY_VIDEO_AVAILABLE  =  9991;
static NSInteger const ERROR_YOUTUBE_MESSAGE  =  150;


@interface WDPlayerUrl : NSObject

- (void)urlByTrackId:(NSString *)trackId success:(void(^)(NSString *streamURL))success failure:(void(^)(NSError *error))failure;

@end
