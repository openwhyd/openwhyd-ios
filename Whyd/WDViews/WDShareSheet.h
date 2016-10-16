//
//  WDShareSheet.h
//  Whyd
//
//  Created by Damien Romito on 30/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDTrack.h"
#import "WDActionSheet.h"

@interface WDShareSheet : WDActionSheet


+(WDShareSheet*)showInController:(UIViewController*)controller withTrack:(WDTrack*)track dismiss:(void (^)(NSString *))dismiss;
+(WDShareSheet*)showInController:(UIViewController*)controller withPlaylist:(Playlist*)playlist dismiss:(void (^)(NSString *))dismiss;

@end
