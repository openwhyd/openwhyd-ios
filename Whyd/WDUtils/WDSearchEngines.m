//
//  WDSearchEngines.m
//  Whyd
//
//  Created by Damien Romito on 11/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDSearchEngines.h"
#import "WDClient.h"
#import "WDTrack.h"
#import "WDPlayerConfig.h"
#import "Playlist.h"
#import "User.h"
//TODO check if crash https://www.crashlytics.com/whyd/ios/apps/com.whyd.whyd/issues/5467b6a365f8dfea1519bfd5

@implementation WDSearchEngines

- (id)initWithSearch:(NSString*)search andDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        NSDictionary *parameters = @{@"q" : search};
        
        [[WDClient client].operationQueue cancelAllOperations];

        
        [[WDClient client] GET:API_SEARCH_WHYD parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject objectForKey:@"error"]) {
                [self.delegate searchResultTracksFromWhyd:nil andPlaylist:nil andUsers:nil];

            }else
            {
                
                NSMutableArray* tracks = [[NSMutableArray alloc] init];
                for (NSDictionary *t in [responseObject valueForKeyPath:@"results.posts"]) {

                    
                    if (![t isEqual:[NSNull null]]) {
                        DLog(@"TRACK RESPONSE %@", t);
                        WDTrack *track = [MTLJSONAdapter modelOfClass:[WDTrack class] fromJSONDictionary:t error:nil];
                        
                        if(track.eId)
                        {
                            [tracks addObject:track];
                        }
                    }

                }
                
                
                NSMutableArray* playlists = [[NSMutableArray alloc] init];
                for (NSDictionary *p in [responseObject valueForKeyPath:@"results.playlists"]) {
                    if (![p isEqual:[NSNull null]]) {
                        Playlist *playlist = [MTLJSONAdapter modelOfClass:[Playlist class] fromJSONDictionary:p error:nil];
                        playlist.userName = [p valueForKeyPath:@"author.name"];
                        playlist.userId = [p valueForKeyPath:@"author.id"];
                        [playlists addObject:playlist];
                    }

                }
                
                NSMutableArray* users  = [[NSMutableArray alloc] init];
                for (NSDictionary *u in [responseObject valueForKeyPath:@"results.users"]) {
                    if (![u isEqual:[NSNull null]]) {
                        User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:u error:nil];
                        [users addObject:user];
                    }
                }
                
                [self.delegate searchResultTracksFromWhyd:tracks andPlaylist:playlists andUsers:users];
                
            }
          
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"WHYD ERROR %@", error);
            [self.delegate searchResultTracksFromWhyd:nil andPlaylist:nil andUsers:nil];
        }];
         
         
        
        
        
        [[WDClient client] GET:API_SEARCH_YOUTUBE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary * items = [responseObject valueForKeyPath:@"data.items"];
            NSMutableArray* tracks = [[NSMutableArray alloc] init];
           // DLog(@"%d YOUTUBE responses ", items.count);

            for (NSDictionary *item in items) {
                
                
                WDTrack* track = [[WDTrack alloc] init];
                track.trackId = [item valueForKey:@"id"];
                track.eId = [NSString stringWithFormat:@"/yt/%@", track.trackId ];
                track.name = [item valueForKey:@"title"];
                track.sourceKey = WDSourceYoutube;
                track.img = [item valueForKeyPath:@"thumbnail.hqDefault"];
                [track parseSource];
                [tracks addObject:track];
                

            }
            [self.delegate searchResultTracksFromYoutube:tracks];

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"YOUTUBE ERROR %@", error);
            [self.delegate searchResultTracksFromYoutube:nil];
        }];
        
        [[WDClient client] GET:API_SEARCH_SOUNDCLOUD parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSMutableArray* tracks = [[NSMutableArray alloc] init];

          //  DLog(@"responseObject %@",responseObject);
            
            for (NSDictionary *item in responseObject) {
                
                if (![item valueForKey:@"stream_url"]) {
                    continue;
                }
                WDTrack* track = [[WDTrack alloc] init];
                track.trackId = [item valueForKey:@"id"];
                track.name = [item valueForKey:@"title"];
                
                NSString *imageUrlString = [item valueForKey:@"artwork_url"];

                if (imageUrlString != (NSString *)[NSNull null])
                {
                    track.img = [imageUrlString substringToIndex:([imageUrlString rangeOfString:@".jpg"].location+4)];
                }
                
                track.sourceKey = WDSourceSoundcloud;
                
                NSString *permalink = [item valueForKey:@"permalink_url"];
                NSInteger position = [permalink rangeOfString:@"//soundcloud.com"].location + 16;
                permalink = [permalink substringFromIndex:position];
                track.eId = [NSString stringWithFormat:@"/sc%@#%@",permalink,[item valueForKey:@"uri"]];
                track.trackId = track.eId;
                [track parseSource];
                [tracks addObject:track];

            }
            
            //DLog(@"%d Soundcloud responses ", tracks.count);

            [self.delegate searchResultTracksFromSoundCloud:tracks];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"ERROR %@", error);
            [self.delegate searchResultTracksFromSoundCloud:nil];
        }];
                
        
    }
    return self;
}





@end
