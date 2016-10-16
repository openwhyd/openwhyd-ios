//
//  WDPlayerUrlVimeo.m
//  Whyd
//
//  Created by Damien Romito on 12/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerUrlVimeo.h"
#import "WDClient.h"

@implementation WDPlayerUrlVimeo




- (void)urlByTrackId:(NSString *)trackId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://player.vimeo.com/video/%@/config", trackId];

    [[WDClient client] GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
       
        
        if (!trackId) return ;
        
        NSDictionary *filesInfo = [responseObject valueForKeyPath:@"request.files.h264"];
        NSString *urlStream = [filesInfo valueForKeyPath:@"mobile.url"];
        
        
        if (!urlStream) {
            urlStream = [filesInfo valueForKeyPath:@"sd.url"];
            if (!urlStream) {
                urlStream = [filesInfo valueForKeyPath:@"hd.url"];
            }
        }
        
        success(urlStream);
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (!trackId) return ;
        
        failure(error);
        
    }];
}


@end
