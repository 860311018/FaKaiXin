//
//  WDAppDotNetAPIClient.h
//  weidian
//
//  Created by Connor on 10/15/15.
//  Copyright (c) 2015 QMM. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface FKXAppDotNetAPIClient : AFHTTPSessionManager

+ (instancetype)sharedAPIClient;

+ (instancetype)sharedOpenAPIClient;

@end
