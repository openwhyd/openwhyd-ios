//
//  WDYoutubeDecoder.h
//  Whyd
//
//  Created by Damien Romito on 02/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDYoutubeDecoder : NSObject
@property (nonatomic, weak) id delegate;
+ (instancetype)decoder;
- (void)decodeSignatures:(NSArray*)signatures withYoutubeSource:(NSString*)youtubeSource;
@end


@protocol WDYoutubeDecoderDelegate <NSObject>

- (void)decodedSignatures:(NSArray *)signatures;

@end