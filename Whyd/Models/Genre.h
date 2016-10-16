//
//  Genre.h
//  Whyd
//
//  Created by Damien Romito on 28/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Mantle.h"

@interface Genre : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *image;
@property (nonatomic) BOOL isSelected;

+ (NSArray*)all;
+ (NSArray*)allHasAllItem:(BOOL)hasAllItem;
@end
