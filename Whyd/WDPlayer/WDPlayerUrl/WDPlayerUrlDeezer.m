//
//  WDPlayerUrlDeezer.m
//  Whyd
//
//  Created by Damien Romito on 13/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerUrlDeezer.h"
#import "WDClient.h"

static NSString* const API_URL = @"http://api.deezer.com/track/";


@implementation WDPlayerUrlDeezer

- (void)urlByTrackId:(NSString *)trackId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_URL,trackId];
    __weak __typeof(self)weakSelf = self;
    
    [[WDClient client] GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if(!weakSelf) return ;
        
        success([responseObject objectForKey:@"preview"]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
    
}
@end
