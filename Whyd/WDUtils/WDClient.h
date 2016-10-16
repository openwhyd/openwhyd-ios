//
//  WDClient.h
//  Cookie authentification
//
//  Created by Damien Romito on 05/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

@interface WDClient : AFHTTPSessionManager<NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>



- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters withCachePolicy:(NSURLRequestCachePolicy)cachePolicy
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
+ (instancetype)client;
+ (void) handleError:(NSError *)error;

+ (void) uploadImageWithData:(NSData *)data success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
+ (void)sTkParameter:(void(^)(NSString *sTk))success;


+ (void)getPublicIPAddress:(void(^)(NSString * publicIp))success;
@end

