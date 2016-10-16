//
//  UIImage+Url.m
//  Whyd
//
//  Created by Damien Romito on 09/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//



#import "UIImage+Url.h"

@implementation UIImage (Helpers)

+ (void) loadFromURL: (NSURL*) url callback:(void (^)(UIImage *image))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            callback(image);
        });
    });
}

@end