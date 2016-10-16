//
//  UIImage+Url.h
//  Whyd
//
//  Created by Damien Romito on 09/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

@interface UIImage (Url)

+ (void) loadFromURL: (NSURL*) url callback:(void (^)(UIImage *image))callback;

@end
