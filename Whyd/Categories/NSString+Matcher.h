//
//  NSString+Matcher.h
//  Whyd
//
//  Created by Damien Romito on 29/01/15.
//  Copyright (c) 2015 Damien Romito. All rights reserved.
//


@interface NSString(Matcher)

- (NSArray *)matchWithRegex:(NSString *)regex;
- (NSString *)matchWithRegex:(NSString *)regex atIndex:(NSUInteger)index;
- (NSString *)firstMatchedGroupWithRegex:(NSString *)regex;
- (NSTextCheckingResult *)firstMatchedResultWithRegex:(NSString *)regex;

@end
