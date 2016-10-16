//
//  WDQueuePlayer.m
//  Whyd
//
//  Created by Damien Romito on 02/08/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDQueuePlayer.h"

@implementation WDQueuePlayer

- (void)insertItem:(AVPlayerItem *)item afterItem:(AVPlayerItem *)afterItem
{
    
    if (![self.items containsObject:item]) {
        
        @try {
            [super insertItem:item afterItem:afterItem];
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION %@",exception);
        }

    }
    else
    {
        DLog(@"ITEM ALREADY CONTAINED");
    }
}

- (void)dealloc
{
    
}

@end
