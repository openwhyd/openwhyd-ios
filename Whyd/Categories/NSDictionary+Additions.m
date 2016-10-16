//
//  NSDictionary+Additions.m
//  Whyd
//
//  Created by Damien Romito on 05/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "NSDictionary+Additions.h"
#import <objc/runtime.h>
#import "Mantle.h"

@implementation NSDictionary (Additions)

+(id) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
       // Class classObject = NSClassFromString([key capitalizedString]);
        
        id object = [obj valueForKey:key];
        if ([[object class] isSubclassOfClass:[MTLModel class]]) {
            id subObj = [self dictionaryWithPropertiesOfObject:object];
            [dict setObject:subObj forKey:key];
        }
        else if([object isKindOfClass:[NSArray class]])
        {
            NSMutableArray *subObj = [NSMutableArray array];
            for (id o in object) {
                [subObj addObject:[self dictionaryWithPropertiesOfObject:o] ];
            }
            [dict setObject:subObj forKey:key];
        }
        else
        {
            if(object)
            {
                [dict setObject:object forKey:key];
            }
        }
    }
    
    free(properties);
    return [NSDictionary dictionaryWithDictionary:dict];
}
//+ (id) parseObject:(id)object withKey:(NSString *)key
//{
//    Class classObject = NSClassFromString([key capitalizedString]);
//    
//    if (classObject) {
//        return [self dictionaryWithPropertiesOfObject:object];
//    }
//    else if([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]])
//    {
//        return [self dictionaryWithPropertiesOfObject:object];
//    }
//    else if(object)
//    {
//        return object;
//    }
//    else
//    {
//        return nil;
//    }
//    
//}

@end
