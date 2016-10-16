//
//  Genre.m
//  Whyd
//
//  Created by Damien Romito on 28/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Genre.h"

@implementation Genre


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"key": @"key",
             @"image": @"image",
             };
}

+ (NSArray*)allHasAllItem:(BOOL)hasAllItem
{
    //GET ALL GENRES
    NSString *myFile = [[NSBundle mainBundle] pathForResource:@"Genres" ofType:@"plist"];
    NSMutableArray *mArray = [[NSMutableArray alloc]initWithContentsOfFile:myFile];
    if (!hasAllItem) {
        [mArray removeObjectAtIndex:0];
    }
    
    NSMutableArray *genresMutables = [NSMutableArray new];
    [mArray enumerateObjectsUsingBlock:^(NSDictionary *genreDico, NSUInteger idx, BOOL *stop) {
        Genre *genre = [MTLJSONAdapter modelOfClass:[Genre class] fromJSONDictionary:genreDico error:nil];
        [genresMutables addObject:genre];
    }];
    
    return genresMutables;
}

+ (NSArray*)all
{
   
    return [Genre allHasAllItem:NO];
}


@end
