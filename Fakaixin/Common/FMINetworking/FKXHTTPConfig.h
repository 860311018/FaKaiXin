//
//  WDHTTPConfig.h
//  weidian
//
//  Created by Connor on 10/15/15.
//  Copyright (c) 2015 Fakaixin. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  环境变量枚举
 */
typedef NS_ENUM(NSInteger, Environment){
    /**
     *  线上环境
     */
    APIRELEASE = 0,
    /**
     *  测试环境
     */
    APIDEBUG,
    /**
     *  第二种测试环境
     *
     */
    APIDEBUG_Second,
};

@interface FKXHTTPConfig : NSObject

/**
 *  获得当前环境
 *
 *  @return 环境变量
 */
+ (Environment)onEnv;
/**
 *  设置环境变量
 *
 *  @param env
 */
+ (void)setEnv:(Environment)env;
/**
 *  获得API的BaseURL
 *
 *  @return
 */
+ (NSString *)onApiRequestUrlPrefix;
/**
 *  获得API的后缀
 *
 *  @return
 */
+ (NSString *)onApiRequestUrlSuffix;
/**
 *  获得OpenAPI的BaseURL
 *
 *  @return
 */
+ (NSString *)onOpenApiRequestUrlPrefix;
/**
 *  获得OpenUrl的后缀
 *
 *  @return
 */
+ (NSString *)onOpenApiRequestUrlSuffix;


/**
 *  获得MMWD的BaseURL
 *
 *  @return
 */
+ (NSString *)onWDRequestUrlPrefix;

+ (NSString *)onApiUserAgent;

+ (NSString *)onOpenApiUserAgent;

@end
