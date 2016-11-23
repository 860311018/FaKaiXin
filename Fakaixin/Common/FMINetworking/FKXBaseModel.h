//
//  WDBaseModel.h
//  weidian
//
//  Created by Connor on 10/15/15.
//  Copyright (c) 2015 Fakaixin. All rights reserved.
//

#import "JSONModel.h"
#import "FKXAppDotNetAPIClient.h"

static NSString *path = @"";
@class FMIErrorModel;
typedef void(^DataHandleBlock)(id data,NSError *error,FMIErrorModel *errorModel);

typedef NS_ENUM(NSInteger, HTTPRequestType) {
    HTTPRequestTypeGet = 0,
    HTTPRequestTypePost,
    HTTPRequestTypePut,
    HTTPRequestTypeDelete
};

@interface FKXBaseModel : JSONModel

@property (nonatomic,copy) NSString<Optional> *code;
@property (nonatomic,copy) NSString<Optional> *msg;

+ (NSURLSessionDataTask *)httpRequestWithRequestType:(HTTPRequestType)type path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block;

+ (NSURLSessionDataTask *)openApiRequestWithRequestType:(HTTPRequestType)type path:(NSString *)path parameters:(NSDictionary *)parameters handleBlock:(DataHandleBlock)block;

@end

@interface FMIErrorModel : JSONModel
@property (nonatomic,strong) NSString *code;
@property (nonatomic,strong) NSString *message;
@end
