//
//  WDPlayerUrlBandcamp.m
//  Whyd
//
//  Created by Damien Romito on 13/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerUrlBandcamp.h"

@implementation WDPlayerUrlBandcamp


-(void)urlByTrackId:(NSString *)trackId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    NSInteger position = [trackId rangeOfString:@"#http://"].location + 1 ;
    if (position < 0) {
        position = [trackId rangeOfString:@"#https://"].location + 1;
    }
    NSString* streamUrl =[trackId substringFromIndex:position];
    success(streamUrl);
    
}

@end
