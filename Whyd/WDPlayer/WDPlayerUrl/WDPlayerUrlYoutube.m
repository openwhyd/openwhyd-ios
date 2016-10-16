//
//  WDPlayerUrlYoutube.m
//  Whyd
//
//  Created by Damien Romito on 12/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerUrlYoutube.h"
#import "WDYoutubeDecoder.h"
#import "Reachability.h"

typedef NS_ENUM(NSUInteger, WDVideoYoutubeQuality) {
	WDVideoYoutubeQualitySmall240  = 36,
	WDVideoYoutubeQualityMedium360 = 18,
	WDVideoYoutubeQualityHD720 = 22,
	WDVideoYoutubeQualityHD1080 = 37,
};

@interface WDPlayerUrlYoutube()<UIWebViewDelegate, WDYoutubeDecoderDelegate>
@property (nonatomic) BOOL webViewReady;
@property (nonatomic) NSString *codeJSScript;
@property (nonatomic) NSArray *streamVideos;
@property (nonatomic) NSArray *streamSignatures;
@property (nonatomic) WDVideoYoutubeQuality youtubeVideoQuality;
@property (copy)void (^successBlock)();
@property (copy)void (^failureBlock)();

@end
@implementation WDPlayerUrlYoutube


- (id)init
{
    self = [super init];
    if (self) {
        if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi) {
            self.youtubeVideoQuality = WDVideoYoutubeQualitySmall240;
        }else
        {
            self.youtubeVideoQuality = WDVideoYoutubeQualityHD720;
        }
        
        
    }
    return self;
}


- (void)urlByTrackId:(NSString *)trackId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    
   // self.currentTrack.mediaContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    

   // DLog(@"YOUTUBE ID %@", trackId);
    self.successBlock = success;
    self.failureBlock = failure;

    /* 1 ******************* GET SOURCE CODE ********************/

    DLog(@"YOUTUBE ID %@", trackId );
    NSString *urlString = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@&nomobile=1", trackId];
    NSURLRequest *youtubeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    [NSURLConnection sendAsynchronousRequest:youtubeRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *youtubeResponse, NSData *youtubeData, NSError *youyubeError) {
        
        NSString *youtubeDataString = [[NSString alloc] initWithData:youtubeData encoding:NSUTF8StringEncoding];
        
        //NO NEXTWORK
        if (!youtubeDataString.length) {
            NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : @"The Internet connection appears to be offline.",};
            NSError *error = [NSError errorWithDomain:API_BASE_URL code:-1009 userInfo:userInfo];
            failure(error);
            return ;
        }
        
        
        //SELECT URLS JSON
        NSString * STREAMS_REGEX = @"url_encoded_fmt_stream_map\"\\:\\s*\"([^\"]+)\"";
        NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:STREAMS_REGEX options:(NSRegularExpressionOptions)0 error:NULL];
        NSRange range = {0, youtubeDataString.length};
        NSTextCheckingResult * mentionResult = [mentionRegex firstMatchInString:youtubeDataString options:(NSMatchingOptions)0 range:range];
        NSString* streamsString =  [youtubeDataString substringWithRange:[mentionResult range]];
        
//        DLog(@"===========> %@", youtubeDataString);

        
        //NOT AVAILABLE
        if (!streamsString.length) {
         
            
            
            youtubeDataString = [youtubeDataString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            
            

            NSString * STREAMS_REGEX = @"<h1 id=\"unavailable-message\" class=\"message\">(.*)<\\/h1>";
            mentionRegex = [NSRegularExpression regularExpressionWithPattern:STREAMS_REGEX options:(NSRegularExpressionOptions)0 error:NULL];
            NSRange range = {0, youtubeDataString.length};
            
            mentionResult = [mentionRegex firstMatchInString:youtubeDataString options:(NSMatchingOptions)0 range:range];
            NSString* unavailableString =  [youtubeDataString substringWithRange:[mentionResult range]];
            
            if (unavailableString.length) {
                
                
                //TRY OTHER SOLUTION
                NSString *urlString = [NSString stringWithFormat:@"http://www.youtube.com/get_video_info?video_id=%@&ps=default&eurl=&gl=US&hl=en", trackId];
                
                NSURLRequest *reQ = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                [NSURLConnection sendAsynchronousRequest:reQ queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *youtubeResponse, NSData *youtubeData, NSError *youyubeError) {
                    
                    NSString *videoQuery = [[NSString alloc] initWithData:youtubeData encoding:NSASCIIStringEncoding];
                    NSStringEncoding queryEncoding = NSUTF8StringEncoding;
                    NSDictionary *video = DictionaryWithQueryString(videoQuery, queryEncoding);
                    NSMutableArray *streamQueries = [[video[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","] mutableCopy];
                    [streamQueries addObjectsFromArray:[video[@"adaptive_fmts"] componentsSeparatedByString:@","]];
                    
                    NSMutableArray *videos = [NSMutableArray new];
                    for (NSString *streamQuery in streamQueries)
                    {
                        NSDictionary *dico = DictionaryWithQueryString(streamQuery, queryEncoding);
                        [videos addObject:dico];
                    }
                    self.streamVideos = videos;
                    
                    if (self.streamVideos && self.streamVideos.count) {
                        NSString *url = [self streamUrlForQuality:self.youtubeVideoQuality];
                        success(url);
                    }else
                    {
                        NSString *message = [unavailableString substringFromIndex:57];
                        message = [message substringToIndex:[message rangeOfString:@"</h1>"].location];
                        NSDictionary * userInfo = @{ NSLocalizedDescriptionKey :message,};
                        NSError *error = [NSError errorWithDomain:API_BASE_URL code:ERROR_YOUTUBE_MESSAGE userInfo:userInfo];
                        failure(error);
                    }
                    
                }];
                

            }else
            {
                NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : @"Method obselete",};
                NSError *error = [NSError errorWithDomain:API_BASE_URL code:ERROR_METHOD_OBSELETE userInfo:userInfo];
                failure(error);
            }
            
            return ;
        }
        streamsString = [streamsString substringFromIndex:30];
        streamsString = [streamsString substringToIndex:streamsString.length-1];
        
        
        /* 2 ******************* SET VIDEOS IN DICTIONARY ********************/
        
        NSMutableArray *videos = [NSMutableArray new];
        NSMutableArray *signatures = [NSMutableArray new];
        
        for (NSString *string in [streamsString componentsSeparatedByString:@","]) {
            NSMutableDictionary *video = [NSMutableDictionary new];
            for (NSString *subString in [string componentsSeparatedByString:@"\\u0026"]) {
                NSArray *pair = [subString componentsSeparatedByString:@"="];
                NSString *key = pair[0];
                NSString *value = [[subString substringFromIndex:key.length+1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                video[key] = value;
                if ([key isEqualToString:@"s"]) {
                    [signatures addObject:value];
                }
            }
            [videos addObject:video];
        }
        self.streamVideos = videos;
        
        /* 3 ******************* IF ENCODED SIGNATURE ********************/
        if (signatures.count) {
            self.streamSignatures = signatures;
            /* 4 ******************* GET SCRIPT CONTAINING DECODING FUNCTION ********************/
            [[WDYoutubeDecoder decoder] setDelegate:self];
            [[WDYoutubeDecoder decoder] decodeSignatures:self.streamSignatures withYoutubeSource:youtubeDataString];
        }else if(self.successBlock)
        {
            NSString *url = [self streamUrlForQuality:self.youtubeVideoQuality];
            
            success(url);
        }
    }];
    
    
}



#pragma DECODE



- (NSString *)streamUrlForQuality:(WDVideoYoutubeQuality)quality
{
    
    for (NSDictionary* video in self.streamVideos) {

        NSUInteger videoQuality = [[video valueForKey:@"itag"] integerValue];

        if (videoQuality == quality) {
            return [video valueForKey:@"url"];
        }
    }
    
    
    if(quality == WDVideoYoutubeQualitySmall240)
    {
        quality = WDVideoYoutubeQualityMedium360;
    }else if (quality == WDVideoYoutubeQualityMedium360)
    {
        quality = WDVideoYoutubeQualityHD720;
    }else if (quality == WDVideoYoutubeQualityHD720)
    {
        quality = WDVideoYoutubeQualityHD1080;
    }else if (quality == WDVideoYoutubeQualityHD1080)
    {
        quality = WDVideoYoutubeQualitySmall240;
    }else
    {         return nil;
    }

    return [self streamUrlForQuality:quality];
}


- (NSArray*)extractStreams:(NSString*)streamMap{
    NSMutableArray *videos = [NSMutableArray new];
    for (NSString *string in [streamMap componentsSeparatedByString:@","]) {
        NSMutableDictionary *video = [NSMutableDictionary new];
        for (NSString *subString in [string componentsSeparatedByString:@"\\u0026"]) {
            NSArray *pair = [subString componentsSeparatedByString:@"="];
            NSString *key = pair[0];
            video[key] = [[subString substringFromIndex:key.length+1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [videos addObject:video];
    }
	return videos;
}



- (void)decodedSignatures:(NSArray *)signatures
{
    if (!signatures) {
        NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : @"Method obselete",};
        NSError *error = [NSError errorWithDomain:API_BASE_URL code:ERROR_METHOD_OBSELETE userInfo:userInfo];
        self.failureBlock(error);
    }else{
        DLog(@"Decode signatures = %lu sign et %lu video", (unsigned long)signatures.count, (unsigned long)self.streamVideos.count);
        /* 4 ******************* ADD SIGNATURE ********************/
     
        int i = 0;
        for ( NSMutableDictionary* video in self.streamVideos ) {
            if (i < signatures.count) {
                @try {
                    
                    NSString *url = [video valueForKey:@"url"];
                    
                    NSString *newUrl = [NSString stringWithFormat:@"%@&signature=%@", url, [signatures objectAtIndex:i] ];
           
                    [video setObject:newUrl forKey:@"url"];
                    i++;
                    if (i > signatures.count) {
                        break;
                    }
                }
                @catch (NSException *exception) {
                    
                }
            }else{
                break;
            }
          
   
           
        }
        
        DLog(@"video %@", self.streamVideos);

        
        NSString *url = [self streamUrlForQuality:self.youtubeVideoQuality];
        if (self.successBlock) {
            if (url) {
                self.successBlock(url);
                
            }else
            {
                NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : @"Any video available",};
                NSError *error = [NSError errorWithDomain:API_BASE_URL code:ERROR_ANY_VIDEO_AVAILABLE userInfo:userInfo];
                self.failureBlock(error);
            }
        }
    }

    
    self.successBlock = nil;
    self.failureBlock = nil;
}

static NSDictionary *DictionaryWithQueryString(NSString *string, NSStringEncoding encoding)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSArray *fields = [string componentsSeparatedByString:@"&"];
    for (NSString *field in fields)
    {
        NSArray *pair = [field componentsSeparatedByString:@"="];
        if (pair.count == 2)
        {
            NSString *key = pair[0];
            NSString *value = [pair[1] stringByReplacingPercentEscapesUsingEncoding:encoding];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            dictionary[key] = value;
        }
    }
    return dictionary;
}



@end
