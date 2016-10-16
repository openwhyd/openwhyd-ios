//
//  WDTwitterHelper.h
//  Whyd
//
//  Created by Damien Romito on 02/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "User.h"
#import "WDTrack.h"
#import <Social/Social.h>

@interface WDTwitterHelper : NSObject

+ (instancetype)manager;
+ (void)unlinkAccount;
+ (BOOL)isLogged:(void(^)(ACAccount *account))success;

- (void)selectAccountInView:(UIView*)pickerContainer success:(void(^)(NSString *username))result failure:(void(^)(NSError *error))failure;
+ (void)shareTrack:(WDTrack*)track;

@end
