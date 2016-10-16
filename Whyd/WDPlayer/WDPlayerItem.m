//
//  WDPlayerItem.m
//  Whyd
//
//  Created by Damien Romito on 02/08/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDPlayerItem.h"

@implementation WDPlayerItem

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
////        NSNotificationCenter.defaultCenter().postNotificationName[("WDPlayerItemInitNotification", object: self)
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:WDPlayerItemInitNotification object:self];
//    }
//    return self;
//}

- (instancetype)initWithAsset:(AVAsset *)asset automaticallyLoadedAssetKeys:(NSArray<NSString *> *)automaticallyLoadedAssetKeys
{
    
    self = [super initWithAsset:asset automaticallyLoadedAssetKeys:automaticallyLoadedAssetKeys];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WDPlayerItemInitNotification object:self];
    }
    return self;
}




- (void)dealloc
{
    
    DLog(@"DEALLOOCC ITEMMMP");
    [[NSNotificationCenter defaultCenter] postNotificationName:WDPlayerItemDeallocNotification object:self];
}

@end
