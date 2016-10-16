//
//  WDPlayerItem.h
//  Whyd
//
//  Created by Damien Romito on 02/08/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDTrack.h"

static NSString * const WDPlayerItemInitNotification = @"WDPlayerItemInitNotification";
static NSString * const WDPlayerItemDeallocNotification = @"WDPlayerItemDeallocNotification";

@interface WDPlayerItem : AVPlayerItem
@property (nonatomic, weak) WDTrack *track;
@end
