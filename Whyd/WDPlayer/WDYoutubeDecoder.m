//
//  WDYoutubeDecoder.m
//  Whyd
//
//  Created by Damien Romito on 02/06/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "WDYoutubeDecoder.h"
#import "WDClient.h"
#import "User.h"
#import "WDHelper.h"

@interface WDYoutubeDecoder()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *myWeb;
@property (nonatomic) BOOL webViewReady;
@property (nonatomic) NSString *codeJSScript;
@property (nonatomic) NSArray *signatures;
@property (nonatomic) BOOL tryUpdate;
@end
@implementation WDYoutubeDecoder


+ (instancetype)decoder {
    static WDYoutubeDecoder *decoder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decoder = [[self alloc] init];
    });
    return decoder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //Prepare WebView
        self.myWeb = [[UIWebView alloc] init];
        self.myWeb.delegate = self;
        
    }
    return self;
}

 - (void)decodeSignatures:(NSArray*)signatures withYoutubeSource:(NSString*)youtubeSource
{
    self.signatures = signatures;
    
    if (!self.codeJSScript) {
        
       
   
        //Find url script
//        NSString * JS_FILE_REGEX = @"\\\\/\\\\/s\\.ytimg\\.com\\\\/yts\\\\/jsbin\\\\/html5player-(.+?)\\.js";

//        NSString * JS_FILE_REGEX = @"\\\\/\\\\/s\\.ytimg\\.com\\\\/yts\\\\/jsbin\\\\/(.+?)base\\.js";
        NSString * JS_FILE_REGEX = @"\\\\/\\\\/s\\.ytimg\\.com\\\\/yts\\\\/jsbin\\\\/((.+?)base|html5player-(.+?))\\.js";
        
        NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:JS_FILE_REGEX options:(NSRegularExpressionOptions)0 error:NULL];
        NSRange range = {0, youtubeSource.length};
        NSTextCheckingResult * mentionResult = [mentionRegex firstMatchInString:youtubeSource options:(NSMatchingOptions)0 range:range];
        NSString * matchString =[youtubeSource substringWithRange:[mentionResult range]];
        matchString = [matchString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSString *urlString = [NSString stringWithFormat:@"http:%@", matchString];
        
        NSString* htmlString = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_DECODE_HTML_CODE];
        
        if (!htmlString || htmlString.length == 0) {
            NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"decode" ofType:@"html"];
            htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        }
        [self.myWeb loadHTMLString:htmlString baseURL:nil];
        
        //load Script
        NSURLRequest *scriptRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        [NSURLConnection sendAsynchronousRequest:scriptRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *scriptResponse, NSData *scriptData, NSError *scriptError) {
            
            
            if (!scriptError) {
                NSString *webData = [[NSString alloc] initWithData:scriptData encoding:NSUTF8StringEncoding];
                
                
                NSString *escapedData = [webData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                self.codeJSScript = escapedData;
                
                if (self.signatures && self.webViewReady ) {
                    [self callDecodedURL];
                }
            }else{
                DLog(@"ERROR ==> %@", scriptError.localizedDescription);

            }
            
            
        }];
    }else
    {
        if (self.webViewReady) {
            
            [self callDecodedURL];
        }
    }
    
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    self.webViewReady = YES;
    if (self.signatures && self.codeJSScript) {
        [self callDecodedURL];
    }
    
}

- (void)callDecodedURL
{
    if (self.signatures) {
        NSData * JSONData = [NSJSONSerialization dataWithJSONObject:self.signatures options:(NSJSONWritingOptions)kNilOptions error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        
        NSString * jsCallBack = [NSString stringWithFormat:@"decodeSignatures('%@',\"%@\")", jsonString , self.codeJSScript];
        [self.myWeb stringByEvaluatingJavaScriptFromString:jsCallBack];
    }

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DLog(@"REQUEST %@", request.URL);
    if ([[request.URL scheme] isEqualToString:@"signaturedecoder"] ) {
        [self.delegate decodedSignatures:[[[request.URL path] substringFromIndex:1] componentsSeparatedByString:@","]];
    }else if ([[request.URL scheme] isEqualToString:@"signaturedecodererror"])
    {
        if (!self.tryUpdate) {
            
            [[WDClient client] GET:API_USER_INFOS parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                DLog(@"Need to get new decode ver");
                [User updateDecodeScriptWithNewDate:[responseObject valueForKey:@"decodeVer"] success:^(BOOL updated) {
                    if (updated) {
                        self.webViewReady = NO;
                        NSString* htmlString = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_DECODE_HTML_CODE];
                        [self.myWeb loadHTMLString:htmlString baseURL:nil];
                    }else
                    {
                        self.tryUpdate = YES;
                        [self.delegate decodedSignatures:nil];

                    }
                }];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
            }];
        }else
        {
            [self.delegate decodedSignatures:nil];

        }


        
    }
    
    return YES;
}



@end
