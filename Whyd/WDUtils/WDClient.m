//
//  WDClient.m
//  Cookie authentification
//
//  Created by Damien Romito on 05/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDClient.h"
#import "WDHelper.h"
#import "NSData+Base64.h"
#import "CocoaSecurity.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation WDClient


+ (instancetype)client {
    
    static WDClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
       // _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//        NSMutableSet *contentTypes = [NSMutableSet setWithSet:_sharedClient.responseSerializer.acceptableContentTypes];
//        [contentTypes addObject:@"text/html"];
//        _sharedClient.responseSerializer.acceptableContentTypes = contentTypes;
        
        _sharedClient.requestSerializer =  [AFJSONRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        
    });
    
    return _sharedClient;
}


- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters withCachePolicy:(NSURLRequestCachePolicy)cachePolicy
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    DLog(@"GET = %@ %@",URLString, (parameters)?parameters:@"{no params}");
//    if (cachePolicy == NSURLRequestReturnCacheDataDontLoad || cachePolicy == NSURLRequestReturnCacheDataElseLoad) {
//        DLog(@"use cache");
//    }
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    
    //DLog(@"USER AGENT %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    //PB WITH SAVE OF COOKIES
    [request setCachePolicy:cachePolicy];
    
    __block NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                DLog(@"Error %@", error);
                failure(task, error);
               // [WDClient handleError:error];
    
                //[[MainViewController manager] handleError:error];
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
  
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    DLog(@"POST = %@ %@",URLString, (parameters)?parameters:@"{no params}");

    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    if (cookies) {
        [request setHTTPShouldHandleCookies:YES];
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [request setAllHTTPHeaderFields:headers];
    }
  
    __block NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
}



- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    return [self GET:URLString parameters:parameters withCachePolicy:NSURLRequestReloadIgnoringLocalCacheData success:^(NSURLSessionDataTask *task, id responseObject) {
        success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}




+ (void) handleError:(NSError *)error
{
    return;
    NSString *errorString;
    switch (error.code) {
        case 200:
            errorString = error.localizedDescription;
            break;
        default:
            break;
    }


}


+ (void) uploadImageWithData:(NSData *)data success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *_afHTTPSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // hack to allow 'text/plain' content-type to work
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:_afHTTPSessionManager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/plain"];
    _afHTTPSessionManager.responseSerializer.acceptableContentTypes = contentTypes;
    
//    [_afHTTPSessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"[USERNAME]" password:@"[PASSWORD]"];
    
    
    [_afHTTPSessionManager POST:@"http://openwhyd.com/upload" parameters:@{@"keepOriginal": @1} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        [formData appendPartWithFileData:data name:@"file" fileName:@"avatar" mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
    
    
}


+ (void)sTkParameter:(void(^)(NSString *sTk))success
{
    [WDClient getPublicIPAddress:^(NSString *ipAddress) {

         NSLog(@"MY IP: %@",ipAddress);
        
        //ipAddress = @"192.168.1.177";
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] ;
        
         NSLog(@"Interval %f", interval);
        
        unsigned long long dateLong = (unsigned long long)interval ;
        NSLog(@"Interval %llu", dateLong);
        
        dateLong = dateLong * 1000;
        NSLog(@"dateInt %llu", dateLong);

        
        ipAddress = [ipAddress stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        ///HASH REQUEST
        NSString *string = [NSString stringWithFormat:@"%@%llu",ipAddress, dateLong];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        CocoaSecurityResult *md5 = [CocoaSecurity md5:string];
        string = [md5.base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
        NSString *hexInt = [NSString stringWithFormat:@"%2llX", dateLong  ];

        ///SIGNATURE
        NSString * hash = [NSString stringWithFormat:@"%@%@", [hexInt lowercaseString]  , string ];
        
        NSString *sign= [ [WDHelper hmacForKey:GENUINE_KEY andData:hash]  base64EncodedString];
        sign = [sign stringByReplacingOccurrencesOfString:@"=" withString:@""];
        
        success([NSString stringWithFormat:@"%@%@",hash , sign]);
        
    }];
    


}

+ (void)getPublicIPAddress:(void(^)(NSString * publicIp))success
{
    
//    NSURL *url = [NSURL URLWithString:@"http://checkip.dyndns.org"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [[[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            // consider handling error
//        } else {
//            NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
//            NSString *ipAddr = [[html componentsSeparatedByCharactersInSet:numbers.invertedSet]componentsJoinedByString:@""];
//            if (success) {
//                success(ipAddr);
//            }
//        }
//    }]resume];
//    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *theURL = [[NSURL alloc] initWithString:@"http://ip-api.com/line/?fields=query"];
        NSString* myIP = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:theURL] encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Manipulate the ip on the main queue
            NSLog(@"MY IP: %@",myIP);
            success(myIP);
        });
    });
}
//
//+ (NSString *)getIPAddress:(BOOL)preferIPv4
//{
//    NSArray *searchArray = preferIPv4 ?
//    @[ IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ,IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6 ] :
//    @[  IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4] ;
//    
//    NSDictionary *addresses = [WDClient getIPAddresses];
//    NSLog(@"Addresses %@", addresses);
//    __block NSString *address;
//    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
//     {
//         address = addresses[key];
//         if(address) *stop = YES;
//     } ];
//    return address ? address : @"0.0.0.0";
//}
//
//
//+ (NSDictionary *)getIPAddresses
//{
//    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
//    
//    // retrieve the current interfaces - returns 0 on success
//    struct ifaddrs *interfaces;
//    if(!getifaddrs(&interfaces)) {
//        // Loop through linked list of interfaces
//        struct ifaddrs *interface;
//        for(interface=interfaces; interface; interface=interface->ifa_next) {
//            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
//                continue; // deeply nested code harder to read
//            }
//            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
//            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
//            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
//                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
//                NSString *type;
//                if(addr->sin_family == AF_INET) {
//                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv4;
//                    }
//                } else {
//                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
//                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv6;
//                    }
//                }
//                if(type) {
//                 
//                    
//                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
//                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
//                }
//            }
//        }
//        // Free memory
//        freeifaddrs(interfaces);
//    }
//    return [addresses count] ? addresses : nil;
//}



@end
