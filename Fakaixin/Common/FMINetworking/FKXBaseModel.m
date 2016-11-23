//
//  WDBaseModel.m
//  weidian
//
//  Created by Connor on 10/15/15.
//  Copyright (c) 2015 Fakaixin. All rights reserved.
//

#import "FKXBaseModel.h"
#import "FKXUserManager.h"

@implementation FKXBaseModel

+ (NSURLSessionDataTask *)httpRequestWithRequestType:(HTTPRequestType)type path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block {
    
    NSString *token = [FKXUserManager shareInstance].currentUserToken;
    token = [NSString stringWithFormat:@"?token=%@",token?token:@""];
    
    path = [path stringByAppendingString:token];//0ee5e01a4b216e81d5f202de8dfbeb40
    
    switch (type) {
        case HTTPRequestTypeGet:
            return [FKXBaseModel GETWithAPIClient:[FKXAppDotNetAPIClient sharedAPIClient] class:[self class] path:path parameters:parameters handleBlock:block];
            break;
        case HTTPRequestTypePost:
            return [FKXBaseModel POSTWithAPIClient:[FKXAppDotNetAPIClient sharedAPIClient] class:[self class] path:path parameters:parameters handleBlock:block];
            break;
        case HTTPRequestTypePut:
            return [FKXBaseModel PUTWithAPIClient:[FKXAppDotNetAPIClient sharedAPIClient] class:[self class] path:path parameters:parameters handleBlock:block];
            break;
        case HTTPRequestTypeDelete:
            return [FKXBaseModel DELETEWithAPIClient:[FKXAppDotNetAPIClient sharedAPIClient] class:[self class] path:path parameters:parameters handleBlock:block];
            break;
            
        default:
            break;
    }
    
    
}


+ (NSURLSessionDataTask *)openApiRequestWithRequestType:(HTTPRequestType)type path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block {
    if (type == HTTPRequestTypeGet) {
        return [FKXBaseModel GETWithAPIClient:[FKXAppDotNetAPIClient sharedOpenAPIClient] class:[self class] path:path parameters:parameters handleBlock:block];
    } else {
        return [FKXBaseModel POSTWithAPIClient:[FKXAppDotNetAPIClient sharedOpenAPIClient] class:[self class] path:path parameters:parameters handleBlock:block];
    }
    
}

+ (NSURLSessionDataTask *)GETWithAPIClient:(FKXAppDotNetAPIClient *)apiClient class:(id)class path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block {
    
    return [apiClient GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"requestURL-->%@\nparameters-->%@\nResponse-->%@",task.currentRequest.URL,parameters,responseObject);
        
        [self hanleResponseData:responseObject class:class handleBlock:block];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureError:error task:task handleBlock:block];
    }];
}

+ (NSURLSessionDataTask *)POSTWithAPIClient:(FKXAppDotNetAPIClient *)apiClient class:(id)class path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block {
    
    return [apiClient POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"requestURL-->%@\nparameters-->%@\nResponse-->%@",task.currentRequest.URL,parameters,responseObject);
        [self hanleResponseData:responseObject class:class handleBlock:block];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureError:error task:task handleBlock:block];
    }];
}

+ (NSURLSessionDataTask *)PUTWithAPIClient:(FKXAppDotNetAPIClient *)apiClient class:(id)class path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block {
    return [apiClient PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"requestURL-->%@\nparameters-->%@\nResponse-->%@",task.currentRequest.URL,parameters,responseObject);
        [self hanleResponseData:responseObject class:class handleBlock:block];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureError:error task:task handleBlock:block];
    }];
}

+ (NSURLSessionDataTask *)DELETEWithAPIClient:(FKXAppDotNetAPIClient *)apiClient class:(id)class path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block {
    
    
    return [apiClient DELETE:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"requestURL-->%@\nparameters-->%@\nResponse-->%@",task.currentRequest.URL,parameters,responseObject);
        [self hanleResponseData:responseObject class:class handleBlock:block];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureError:error task:task handleBlock:block];
    }];
}


#pragma mark ----success & failure  handle
+ (void)failureError:(NSError *)error task:(NSURLSessionDataTask *)task handleBlock:(DataHandleBlock)block{
    NSLog(@"%@",error.userInfo);
    if (block) {
        block(nil,error,nil);
    }
    
    if([[[error.userInfo objectForKey:@"NSErrorFailingURLKey"] absoluteString] rangeOfString:@"message_center/signal"].location != NSNotFound) {
        return;
    }
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown||
        [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || error.code == -1001) {
        //        hudWithStr(@"当前无法访问网络，请检查网络设置！");
    }else if(error.code != -999){
        hudWithStr(@"有点小问题，不要着急，程序员哥哥正在抢修！");
    }
    
}


+ (void)hanleResponseData:(id)responseObject class:(id)class handleBlock:(DataHandleBlock)block  {
    NSError *err = nil;
    
    if ([responseObject[@"code"] integerValue] == 0) {
        
        NSLog(@"DATA%@",responseObject[@"data"]);
        
        id responseDict = responseObject[@"data"];
        if (![responseDict isKindOfClass:[NSDictionary class]]) {
            block(responseDict,nil,nil);
            NSLog(@"%@",[responseDict class]);
            return;
        }
        
        FKXBaseModel *officalSources = nil;
        if (responseDict) {
            officalSources =  [[class alloc] initWithDictionary:responseDict error:&err];
        } else {
            officalSources = [[class alloc] initWithDictionary:responseObject error:&err];
        }
        
        if (err) {
            hudWithStr(@"解析错误");
            NSLog(@"%@解析错误%@",class,err.description);
        }
        if (block) {
            block(officalSources,nil,nil);
        }
    }else{
        FMIErrorModel *officalSoure = [[[FMIErrorModel class] alloc] initWithDictionary:responseObject error:&err];
        NSLog(@"错误原因：%@",officalSoure.message);
        hudWithStr(officalSoure.message);
        if (block) {
            block(nil,nil,officalSoure);
        }
    }
}

@end


@implementation FMIErrorModel

@end
