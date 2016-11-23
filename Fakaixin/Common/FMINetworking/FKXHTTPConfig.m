//
//  WDHTTPConfig.m
//  weidian
//
//  Created by Connor on 10/15/15.
//  Copyright (c) 2015 Fakaixin. All rights reserved.
//

#import "FKXHTTPConfig.h"

/**
 *  在这里修改环境变量
 */
static Environment apiEnv = APIRELEASE;

static NSString * const API_Release_BaseUrl = @"http://101.200.196.71:8200/";
//static NSString * const API_Release_BaseUrl = @"http://192.168.1.115:8200/";
//static NSString * const API_Release_BaseUrl = @"http://api.imfakaixin.com/";
static NSString * const OpenAPI_Release_BaseUrl = @"http://init.xapi.me";
static NSString * const WD_Release_BaseUrl = @"http://mmwd.me";

static NSString * const API_Debug_BaseUrl   = @"http://192.168.1.123:8200";

static NSString * const OpenAPI_Debug_BaseUrl   = @"http://init.xapi.me";
static NSString * const WD_Debug_BaseUrl = @"http://bj.mmwd.me";

static NSString * const API_Debug_Second_BaseUrl   = @"http://1.api.haojin.in";
static NSString * const OpenAPI_Debug_Second_BaseUrl   = @"http://init.xapi.me";
static NSString * const WD_Debug_Second_BaseUrl = @"http://mmwd.me";


@implementation FKXHTTPConfig

#pragma mark - Enviroment

+ (Environment)onEnv {
    return apiEnv;
}

+ (void)setEnv:(Environment)env {
    apiEnv = env;
}

#pragma mark - BaseUrl
+ (NSString *)onApiRequestUrlPrefix {
    switch (apiEnv) {
        case APIRELEASE: {
            return API_Release_BaseUrl;
        }
            break;
        case APIDEBUG: {
            return API_Debug_BaseUrl;
        }
            break;
        case APIDEBUG_Second: {
            return API_Debug_Second_BaseUrl;
        }
            break;
            
        default:
            break;
    }
    return apiEnv == APIRELEASE ? API_Release_BaseUrl:API_Debug_BaseUrl;
}

+ (NSString *)onOpenApiRequestUrlPrefix {
    
    switch (apiEnv) {
        case APIRELEASE: {
            return OpenAPI_Release_BaseUrl;
        }
            break;
        case APIDEBUG: {
            return OpenAPI_Debug_BaseUrl;
        }
            break;
        case APIDEBUG_Second: {
            return OpenAPI_Debug_Second_BaseUrl;
        }
            break;
            
        default:
            break;
    }
    
    return apiEnv == APIRELEASE ? OpenAPI_Release_BaseUrl:OpenAPI_Debug_BaseUrl;
}

+ (NSString *)onWDRequestUrlPrefix {
    
    switch (apiEnv) {
        case APIRELEASE: {
            return API_Debug_Second_BaseUrl;
        }
            break;
        case APIDEBUG: {
            return OpenAPI_Debug_Second_BaseUrl;
        }
            break;
        case APIDEBUG_Second: {
            return WD_Debug_Second_BaseUrl;
        }
            break;
            
        default:
            break;
    }
    
    return apiEnv == APIRELEASE ? WD_Release_BaseUrl:WD_Debug_BaseUrl;
}

#pragma mark - Suffix
+ (NSString *)onApiRequestUrlSuffix{
    return [NSString stringWithFormat:@"?platform=ios&os_ver=%@&app_ver=%@device=%@",iOS_Version,AppVersionShort,Device];
}

+ (NSString *)onOpenApiRequestUrlSuffix {
    return [NSString stringWithFormat:@"?platform=ios&os_ver=%@&app_ver=%@device=%@",iOS_Version,AppVersionShort,Device];
}

#pragma mark - UserAgent

+ (NSString *)onApiUserAgent {
    return [NSString stringWithFormat:@"QMMWD/%@ %@/%@ AFNetwork/1.1",AppVersionShort,Device,iOS_Version];
}

+ (NSString *)onOpenApiUserAgent {
    return [NSString stringWithFormat:@"QMMWD-AS /%@ %@/%@ AFNetwork/1.1",AppVersionShort,Device,iOS_Version];
}

@end
