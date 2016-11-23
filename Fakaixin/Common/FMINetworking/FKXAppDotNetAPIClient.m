//
//  WDAppDotNetAPIClient.m
//  weidian
//
//  Created by Connor on 10/15/15.
//  Copyright (c) 2015 Fakaixin. All rights reserved.
//

#import "FKXAppDotNetAPIClient.h"
#import "FKXHTTPConfig.h"
#import "AFHTTPSessionManager.h"

typedef NS_ENUM(NSInteger, WDAppDotNetClientType) {
    WDAppDotNetAPIClientAPI = 0,
    WDAppDotNetAPIClientOpenAPI
};

@implementation FKXAppDotNetAPIClient

+ (instancetype)sharedAPIClient {
    
    static FKXAppDotNetAPIClient *_sharedAPIClient = nil;
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        NSString *baseUrlString = @"";
//        NSString *userAgentString = @"";
//        
//        baseUrlString = [FMIHTTPConfig onApiRequestUrlPrefix];
//        userAgentString = [FMIHTTPConfig onApiUserAgent];
//        
//        _sharedAPIClient = [[FMIAppDotNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrlString]];
//        [[_sharedAPIClient requestSerializer] setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
//        _sharedAPIClient.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//        [[_sharedAPIClient requestSerializer] setTimeoutInterval:10.f];
//    });
    
    NSString *baseUrlString = @"";
    NSString *userAgentString = @"";
    
    baseUrlString = [FKXHTTPConfig onApiRequestUrlPrefix];
    userAgentString = [FKXHTTPConfig onApiUserAgent];
    
    
    _sharedAPIClient = [[FKXAppDotNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrlString]];
    [[_sharedAPIClient requestSerializer] setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
    _sharedAPIClient.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    _sharedAPIClient.requestSerializer = [AFJSONRequestSerializer serializer];
    [[_sharedAPIClient requestSerializer] setTimeoutInterval:10.f];

    return _sharedAPIClient;
}

+ (instancetype)sharedOpenAPIClient {

    static FKXAppDotNetAPIClient *_sharedOpenAPIClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *baseUrlString = @"";
        NSString *userAgentString = @"";
        
        baseUrlString = [FKXHTTPConfig onOpenApiRequestUrlPrefix];
        userAgentString = [FKXHTTPConfig onApiUserAgent];
        
        _sharedOpenAPIClient = [[FKXAppDotNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrlString]];
        [[_sharedOpenAPIClient requestSerializer] setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
        _sharedOpenAPIClient.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [[_sharedOpenAPIClient requestSerializer] setTimeoutInterval:10.f];
    });
    
    return _sharedOpenAPIClient;

}

- (void)requestTimeoutInterval {
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [httpManager.requestSerializer setTimeoutInterval:10];
}

@end
