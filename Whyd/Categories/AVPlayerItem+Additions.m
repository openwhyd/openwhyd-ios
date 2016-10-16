//
//  AVPlayerItem+Additions.m
//  Whyd
//
//  Created by Damien Romito on 16/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "AVPlayerItem+Additions.h"

@implementation AVPlayerItem  (Additions)

- (BOOL)urlIsEqualToString:(NSString *)string
{
    NSURL *nsurl =  [(AVURLAsset *)self.asset URL];
    return [[nsurl absoluteString] isEqualToString:string];
}

@end
