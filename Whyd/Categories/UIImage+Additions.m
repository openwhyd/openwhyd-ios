//
//  UIImage+Additions.m
//  Whyd
//
//  Created by Damien Romito on 14/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage(Additions)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
