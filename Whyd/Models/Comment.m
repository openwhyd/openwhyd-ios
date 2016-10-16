//
//  Comment.m
//  Whyd
//
//  Created by Damien Romito on 05/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Comment.h"
#import "WDHelper.h"


static NSString * const MENTION_REGEX = @"@\\[([^\\]]*)\\]\\(user:([^\\)]*)\\)";

@implementation Comment


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"_id",
             @"text": @"text",
             @"userId": @"uId",
             @"userName": @"uNm",
             @"trackId": @"pId"
             };
    
    
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    self = [super initWithDictionary:dictionaryValue error:error];
    
    //user
    User *user = [User new];
    user.id = [dictionaryValue valueForKey:@"userId"];
    user.name = [dictionaryValue valueForKey:@"userName"];
    self.user = user;
    
    return self;
}

#pragma mark GETTER

- (NSString *)date
{
    return [WDHelper dateFromId:self.id];
}


- (NSMutableAttributedString *)attributedText
{
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:self.text];
    [attributedString setTextColor:WDCOLOR_BLACK];
    [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3]];
    _attributedText = [self addMentions:attributedString];

    return _attributedText;
}

#pragma mark SETTER

- (NSMutableAttributedString *)addMentions:(NSMutableAttributedString *)attributedString
{
    
    NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:MENTION_REGEX options:0 error:NULL];
    NSRange searchedRange = NSMakeRange(0, [attributedString.string length]);
    
    NSTextCheckingResult * mentionResult = [mentionRegex firstMatchInString:attributedString.string options:0 range:searchedRange];
    if (!mentionResult) return attributedString;
    
    NSString* matchString = [attributedString.string substringWithRange:[mentionResult range]];
    
    //username
    NSString* userName = [matchString substringFromIndex:2];
    userName =  [userName substringToIndex:[userName rangeOfString:@"]"].location];
    [attributedString replaceCharactersInRange:[mentionResult range] withString:userName];
    
    NSRange userRange = {[mentionResult range].location, userName.length};
    //id
    NSRange idRange = [matchString rangeOfString:@"(user:"];
    NSString* userId = [matchString substringFromIndex:idRange.location + 6];
    userId = [userId substringToIndex:userId.length -1];
    
    NSURL *userURL = [NSURL URLWithString: OPEN_URL_USER(userId)];
    
    [attributedString setLink:userURL range:userRange];
    [attributedString setFont:[UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3] range:userRange];
    
    return  [self addMentions:attributedString];
}

+ (CGFloat) heightForComment:(Comment*)comment
{
    OHAttributedLabel *sizer = [[WDHelper manager] sizer];
    sizer.frame = CGRectMake(0, 0, COMMENT_WIDTH, 9999);
    sizer.attributedText = comment.attributedText;
    [sizer sizeToFit];
    CGFloat height = 64 + (sizer.frame.size.height - 15);
    return height;
}



@end
