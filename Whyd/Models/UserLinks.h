//
//  UserLinks.h
//  Whyd
//
//  Created by Damien Romito on 03/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Mantle.h"

@interface UserLinks : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *fb;
@property (nonatomic, strong) NSString *yt;
@property (nonatomic, strong) NSString *igrm;
@property (nonatomic, strong) NSString *sc;
@property (nonatomic, strong) NSString *tw;
@property (nonatomic, strong) NSString *home;

@end
