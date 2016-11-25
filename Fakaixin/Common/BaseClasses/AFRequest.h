//
//  1111.h
//  OtherUse
//
//  Created by 袁少华 on 15/10/10.
//  Copyright © 2015年 YouXianMing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONModel.h"

typedef enum : NSUInteger {
    HTTPResponseTypeJSON,
    HTTPResponseTypeXML,
    HTTPResponseTypeData
} HTTPResponseType;

@class FMIErrorModelTwo;

typedef void(^DataHandleBlockTwo)(id data,NSError *error,FMIErrorModelTwo *errorModel);
//封装的网络请求
@interface AFRequest : JSONModel

@property (nonatomic,copy) NSString<Optional> *code;
@property (nonatomic,copy) NSString<Optional> *message;

/**
 5  *  网络请求,只关注返回的code和message
 6  *
 7  *  @param url          将要访问的链接
 8  *  @param param        传入的参数
 9  *  @param requestStyle 请求方式
 10  *  @param serializer   数据返回形式
 11  *  @param success      请求成功后调用
 12  *  @param failure      请求失败后调用
 13  */
+ (void)sendGetOrPostRequest:(NSString *)url
                       param:(NSDictionary *)param
                requestStyle:(NSInteger)requestStyle
               setSerializer:(NSInteger)serializer
                     success:(void (^)(id data))success                    failure:(void (^)(NSError *error))failure;
/**
 *  上传头像
 *
 *  @param url     链接
 *  @param data    二进制
 *  @param success 成功回调
 *  @param failure 失败回调
 */
//+ (void)postUploadImageUrl:(NSString *)url
//                 imageData:(NSData*)data
//                   success:(void (^)(id data))success
//                   failure:(void (^)(NSError *error))failure;
/**
 *  网络请求,除了code和message之外,还要用到返回的data
 *
 *  @param url          链接
 *  @param param        参数
 *  @param requestStyle 请求类型get或post
 *  @param serializer   解析类型
 *  @param block        回调
 */

+ (void)sendGetOrPostRequest:(NSString *)url
                       param:(NSDictionary *)param
                requestStyle:(NSInteger)requestStyle
               setSerializer:(HTTPResponseType)serializer
                 handleBlock:(DataHandleBlockTwo)block;

+ (void)sendPostRequestTwo:(NSString *)url
                       param:(NSDictionary *)param
                     success:(void (^)(id data))success
                     failure:(void (^)(NSError *error))failure;

//调Reset Post
+ (void)sendResetPostRequest:(NSString *)url
                       param:(NSDictionary *)param
                     success:(void (^)(id data))success
                     failure:(void (^)(NSError *error))failure;

//调Reset Get
+ (void)sendResetGetRequest:(NSString *)url
                       param:(NSString *)param
                     success:(void (^)(id data))success
                     failure:(void (^)(NSError *error))failure;

@end

@interface FMIErrorModelTwo : JSONModel
@property (nonatomic,strong) NSString *code;//respcd
@property (nonatomic,strong) NSString *message;//respmsg
@end

