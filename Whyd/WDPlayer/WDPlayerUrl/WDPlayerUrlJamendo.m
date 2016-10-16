//
//  WDPlayerUrlJamendo.m
//  Whyd
//
//  Created by Damien Romito on 22/09/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerUrlJamendo.h"


static NSString* const API_URL =  @"http://api.jamendo.com/v3.0/tracks/file";

@implementation WDPlayerUrlJamendo


- (void)urlByTrackId:(NSString *)trackId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    

    
    NSString* streamUrl = [NSString stringWithFormat:@"%@?client_id=%@&action=stream&audioformat=mp32&id=%@", API_URL, JAMENDO_CLIENT_ID, trackId ];
    NSLog(@"STREAM %@", streamUrl);
    success(streamUrl);
    
}

@end
