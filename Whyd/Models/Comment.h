//
//  Comment.h
//  Whyd
//
//  Created by Damien Romito on 05/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "Mantle.h"
@class User;



@interface Comment : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableAttributedString *attributedText;
@property (nonatomic, strong) User *user;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *userName;
@property (nonatomic, strong) NSString *trackId;
@property (nonatomic, readonly) NSString *date;
@property (nonatomic, strong) NSString *id;
@property (nonatomic) BOOL isSending;

+ (CGFloat) heightForComment:(Comment*)comment;

@end
