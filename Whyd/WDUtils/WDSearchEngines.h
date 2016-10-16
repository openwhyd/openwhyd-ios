//
//  WDSearchEngines.h
//  Whyd
//
//  Created by Damien Romito on 11/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDSearchEngines : NSObject

@property (nonatomic, weak) id delegate;

- (id)initWithSearch:(NSString*)search andDelegate:(id)delegate;
@end

@protocol WDSearchEnginesDelegate <NSObject>

- (void) searchResultTracksFromYoutube:(NSArray*)tracks;
- (void) searchResultTracksFromSoundCloud:(NSArray*)tracks;
- (void) searchResultTracksFromWhyd:(NSArray*)tracks andPlaylist:(NSArray *)playlists andUsers:(NSArray *)users;

@end