//
//  WDPlayerUrlSoundcloud.m
//  Whyd
//
//  Created by Damien Romito on 13/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerUrlSoundcloud.h"


static NSString* const API_URL =  @"https://api.soundcloud.com/tracks/";


@implementation WDPlayerUrlSoundcloud

- (void)urlByTrackId:(NSString *)trackId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    
    DLog(@"trackId %@",trackId);
    
    NSString* streamUrl;
    
   
    //trackId CAN HAVE SECRET TOKEN /sc/booka-shade/love-drug-feat-fritz-helder-maya-jane-coles-remix/s-jqwrZ#https://api.soundcloud.com/tracks/149820849?secret_token=s-jqwrZ
    NSInteger paramPosition = [trackId rangeOfString:@"secret_token"].location;
    if (paramPosition < 1000) {
        NSString *secret_token = [trackId substringFromIndex:paramPosition];
        trackId = [trackId substringToIndex:paramPosition -1];
        streamUrl =  [NSString stringWithFormat:@"%@%@/stream?client_id=%@&%@",API_URL, trackId ,SOUNDCLOUD_API_KEY, secret_token];
        //[NSString stringWithFormat:@"%@/stream",trackId];
        
    }else
    {
        streamUrl =  [NSString stringWithFormat:@"%@%@/stream?client_id=%@",API_URL, trackId ,SOUNDCLOUD_API_KEY];
        //[NSString stringWithFormat:@"%@/stream",streamUrl];
    }
    
    DLog(@"stream %@", streamUrl);

    success(streamUrl);

}

@end
