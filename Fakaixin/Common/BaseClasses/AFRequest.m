//
//  1111.m
//  OtherUse
//
//  Created by 袁少华 on 15/10/10.
//  Copyright © 2015年 YouXianMing. All rights reserved.
//

#import "AFRequest.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

#import "NSString+Extension.h"

//@class FMIErrorModel;
//typedef void(^DataHandleBlock)(id data,NSError *error,FMIErrorModelTwo *errorModel);


@implementation AFRequest

+ (void)sendResetPostRequest:(NSString *)url
                       param:(NSDictionary *)param
                     success:(void (^)(id data))success
                     failure:(void (^)(NSError *error))failure{
    
    //授权令牌
    NSString *token = @"2e22f29d1a1afb6dd77f5b1c91d2eb09";
    //版本号
    NSString *SoftVersion=@"2014-06-30";
    //用户id
    NSString *accountSid=@"d431679f700750f2c3f4859f613d7c73";
    //APP id
    NSString *appId = @"c369cfe9148a40b998323b8e4d00d902";
    //系统当前时间
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    
    
    NSString *sigStr = [NSString stringWithFormat:@"%@%@%@",accountSid,token,time];
    NSString *SigParameter = [NSString md532BitUpper:sigStr];
    
    NSString *auStr = [NSString stringWithFormat:@"%@:%@",accountSid,time];
    NSString *Authorization = [NSString base64:auStr];
    
    NSString *requstUrl = [NSString stringWithFormat:@"https://api.ucpaas.com/%@/Accounts/%@/%@?sig=%@",SoftVersion,accountSid,url,SigParameter];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"application/xml", nil]];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:Authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager POST:requstUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];

}

+ (void)sendResetGetRequest:(NSString *)url
                       param:(NSString *)param
                     success:(void (^)(id data))success
                     failure:(void (^)(NSError *error))failure{
    
    //授权令牌
    NSString *token = @"2e22f29d1a1afb6dd77f5b1c91d2eb09";
    //版本号
    NSString *SoftVersion=@"2014-06-30";
    //用户id
    NSString *accountSid=@"d431679f700750f2c3f4859f613d7c73";
    //APP id
    NSString *appId = @"c369cfe9148a40b998323b8e4d00d902";
    //系统当前时间
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    
    
    NSString *sigStr = [NSString stringWithFormat:@"%@%@%@",accountSid,token,time];
    NSString *SigParameter = [NSString md532BitUpper:sigStr];
    
    NSString *auStr = [NSString stringWithFormat:@"%@:%@",accountSid,time];
    NSString *Authorization = [NSString base64:auStr];
    
    NSString *requstUrl = [NSString stringWithFormat:@"https://api.ucpaas.com/%@/Accounts/%@/%@?sig=%@%@",SoftVersion,accountSid,url,SigParameter,param];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"application/xml", nil]];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:Authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:requstUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
    11  *  网络请求方法
    12  *
    13  *  @param url          将要访问的链接
    14  *  @param param        传入的参数
    15  *  @param requestStyle 请求方式
    16  *  @param serializer   数据返回形式
    17  *  @param success      请求成功后调用
    18  *  @param failure      请求失败后调用
    19  */

+ (void)sendGetOrPostRequest:(NSString *)url
                       param:(NSDictionary *)param
                requestStyle:(NSInteger)requestStyle
               setSerializer:(NSInteger)serializer
                     success:(void (^)(id data))success
                    failure:(void (^)(NSError *error))failure
 {
     NSString *urlString = [NSString stringWithFormat:@"%@%@?token=%@",kServiceBaseURL, url, kToken ? kToken : @""];
     urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//     NSLog(<#NSString * _Nonnull format, ...#>)
     // 创建请求 管理者
     AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

     // 设置序列化器
     switch(serializer)
     {
         case HTTPResponseTypeJSON:
         {
             manager.requestSerializer = [AFJSONRequestSerializer serializer];
             [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];//默认(返回的是json并自动解析成数组或字典)
         }break;
         case HTTPResponseTypeXML:
         {

             [manager setResponseSerializer:[AFXMLParserResponseSerializer serializer]];//返回的是xml，afn不支持xml解析
         }break;
         case HTTPResponseTypeData:
         {
             manager.requestSerializer = [AFHTTPRequestSerializer serializer];
             [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];//返回的是data并自动解析成数组或字典

         }break;
     }

     [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil]];

     // 3.发送请求
     if(requestStyle == HTTPRequestTypePost)
     {
         [manager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
             
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"\n接口:%@\n参数:%@\n返回的数据:%@",url,param, responseObject);
             success(responseObject);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             failure(error);
             NSLog(@"接口:%@\n参数:%@\n请求失败:%@",url,param, error);
         }];
         
//         [manager POST:<#(nonnull NSString *)#> parameters:<#(nullable id)#> constructingBodyWithBlock:<#^(id<AFMultipartFormData>  _Nonnull formData)block#> progress:<#^(NSProgress * _Nonnull uploadProgress)uploadProgress#> success:<#^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)success#> failure:<#^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)failure#>]
         
//         [manager POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject)
//         {
//            NSLog(@"\n接口:%@\n参数:%@\n返回的数据:%@",url,param, responseObject);
//            success(responseObject);
//
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//         {
////             hudWithStr(@"网络出错");
//             failure(error);
//             NSLog(@"接口:%@\n参数:%@\n请求失败:%@",url,param, error);
//         }];
     }
     else if(requestStyle == HTTPRequestTypeGet)
     {
//         [manager GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSLog(@"\n接口:%@\n参数:%@\n返回的数据:%@",url,param, responseObject);
//             success(responseObject);
//            
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//          {
//              NSLog(@"接口:%@\n参数:%@\n请求失败:%@",url,param, error);
//          }];
      }
}
/*
+ (void)postUploadImageUrl:(NSString *)url
                 imageData:(NSData*)data
               success:(void (^)(id data))success
               failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?token=%@",kServiceBaseURL, url, kToken ? kToken : @""];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager  POST:urlString  parameters:nil  constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        
        [formData appendPartWithFileData:data name:@"fileData" fileName:@"avarta.png" mimeType:@"image/png"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject){
        
         NSLog(@"上传头像成功!");
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"上传头像失败: %@", error);
    }];
}
*/

+ (void)sendPostRequestTwo:(NSString *)url
                       param:(NSDictionary *)param
                     success:(void (^)(id data))success
                     failure:(void (^)(NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@?token=%@",kServiceBaseURL,url,kToken ? kToken : @""];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"请求url:%@", urlString);
    
    // 创建请求 管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];//默认(返回的是json并自动解析成数组或字典)
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil]];

    [manager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
}


+ (void)sendGetOrPostRequest:(NSString *)url
                       param:(NSDictionary *)param
                requestStyle:(NSInteger)requestStyle
               setSerializer:(HTTPResponseType)serializer
                     handleBlock:(DataHandleBlockTwo)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?token=%@",kServiceBaseURL,url,kToken ? kToken : @""];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"请求url:%@", urlString);

    // 创建请求 管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 设置序列化器
    switch(serializer)
    {
        case HTTPResponseTypeJSON:
        {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];//默认(返回的是json并自动解析成数组或字典)
        }break;
        case HTTPResponseTypeXML:
        {
            [manager setResponseSerializer:[AFXMLParserResponseSerializer serializer]];//返回的是xml，afn不支持xml解析
        }break;
        case HTTPResponseTypeData:
        {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];//返回的是data并自动解析成数组或字典
            
        }break;
    }
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil]];
    
    // 3.发送请求
    if(requestStyle == HTTPRequestTypePost)
    {
        [manager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"\n接口:%@\n参数:%@\n返回的数据:%@",url,param, responseObject);
            
            [self hanleResponseData:responseObject class:[self class] handleBlock:block];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            hudWithStr(@"网络出错");
            //方便取消当前的网络请求状态,比如转圈
            if (block) {
                block(nil,error,nil);
            }
        }];
        
//        [manager POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject)
//         {
//             NSLog(@"\n接口:%@\n参数:%@\n返回的数据:%@",url,param, responseObject);
//             [self hanleResponseData:responseObject class:[self class] handleBlock:block];
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//         {
//             hudWithStr(@"网络出错");
//             //方便取消当前的网络请求状态,比如转圈
//             if (block) {
//                 block(nil,error,nil);
//             }
//         }];
    }
    else if(requestStyle == HTTPRequestTypeGet)
    {
//        [manager GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"\n接口:%@\n参数:%@\n返回的数据:%@",url,param, responseObject);
////            success(responseObject);
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//         {
//             NSLog(@"接口:%@\n参数:%@\n请求失败:%@",url,param, error);
//         }];
    }
}
+ (void)hanleResponseData:(id)responseObject class:(id)class handleBlock:(DataHandleBlockTwo)block  {
    NSError *err = nil;
    if ([responseObject[@"code"] integerValue] == 0)
    {
        id data = responseObject[@"data"];
        AFRequest *officalSources = nil;
        NSMutableArray *mutData = [NSMutableArray arrayWithCapacity:1];
        BOOL isDic = [data isKindOfClass:[NSDictionary class]];
        BOOL isArr = [data isKindOfClass:[NSArray class]];
        if (isDic)
        {
            if (data[@"list"])
            {
                for (NSDictionary *dic in data[@"list"]) {
                    AFRequest * officalSources =  [[class alloc] initWithDictionary:dic error:&err];
                    [mutData addObject:officalSources];
                }
            }
            else
            {
                if (data) {
                    officalSources =  [[class alloc] initWithDictionary:data error:&err];
                } else
                {
                    officalSources = [[class alloc] initWithDictionary:responseObject error:&err];
                }
            }
        }
        if (isArr) {
            for (NSDictionary *dic in data)
            {
                AFRequest * officalSources =  [[class alloc] initWithDictionary:dic error:&err];
                [mutData addObject:officalSources];
            }
        }
        if (err)
        {
            hudWithStr(@"解析错误");
            NSLog(@"%@解析错误%@",class,err.description);
        }
        if (block)
        {
            if (isDic)
            {
                if (data[@"list"]) {
                    block(mutData,err,nil);
                }
                else
                {
                    block(officalSources,err,nil);
                }
            }
            if (isArr)
            {
                block(mutData,err,nil);
            }//v1.0之后的注释
        }
    }
    else
    {
        FMIErrorModelTwo *officalSoure = [[[FMIErrorModelTwo class] alloc] initWithDictionary:responseObject error:&err];
        NSLog(@"FMIErrorModel错误原因：%@",officalSoure.message);
        hudWithStr(officalSoure.message);
        if (block) {
            block(nil,nil,officalSoure);
        }
    }
}

@end

@implementation FMIErrorModelTwo

@end
