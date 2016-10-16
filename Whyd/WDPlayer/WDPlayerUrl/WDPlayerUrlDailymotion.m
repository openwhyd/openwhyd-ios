//
//  WDPlayerUrlDailymotion.m
//  Whyd
//
//  Created by Damien Romito on 13/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerUrlDailymotion.h"

static const NSString *API_URL = @"http://www.dailymotion.com/embed/video/";


@implementation WDPlayerUrlDailymotion


- (void)urlByTrackId:(NSString *)trackId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?api=location",API_URL, trackId];
    
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    __weak __typeof(self)weakSelf = self;
    //NSLog(@"urlString %@", urlString);

    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!data) {
            NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"ErrorInternetOffline", nil)};
            NSError *error = [NSError errorWithDomain:API_BASE_URL code:-1009 userInfo:userInfo];
            failure(error);
        }else if(weakSelf)
        {
            NSString *webData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
          //  NSLog(@"Webdata %@", webData);
            NSInteger positionStart = [webData rangeOfString:@"var info"].location;
            webData = [webData substringFromIndex:positionStart+10];
            NSInteger positionEnd = [webData rangeOfString:@"fields ="].location;
            webData = [webData substringToIndex:positionEnd-14];
            
           // NSLog(@"Webdata %@", webData);

            id jsonData = [webData dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
           // NSLog(@"json %@", json);

            NSString *selectedMovieString = [json objectForKey:@"stream_h264_url"];
            
//            weakSelf.currentTrack.totalDutation = [[json objectForKey:@"duration"] floatValue];
//            
//            if (weakSelf.currentTrack.totalDutation) {
//                weakSelf.durationAvailable = YES;
//            }
            if (selectedMovieString) {
                success(selectedMovieString);

            }else
            {
                NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : @"Method obselete",};
                NSError *error = [NSError errorWithDomain:API_BASE_URL code:ERROR_METHOD_OBSELETE userInfo:userInfo];
                failure(error);
            }

        }
        
        
        
        
    }];
    
}
@end
