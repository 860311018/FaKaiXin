//
//  FKXCustomAcceptHtmlVC.h
//  Fakaixin
//
//  Created by liushengnan on 16/9/22.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBaseViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "FKXSecondAskModel.h"

//自定义认可界面（支付打赏）
@interface FKXCustomAcceptHtmlVC : FKXBaseViewController

@property(nonatomic, copy)NSString * urlString; //加载的h5链接
@property(nonatomic, strong)JSContext * jsContext;
@property(nonatomic, strong)NSMutableDictionary  * payParameterDic;    //支付的参数
@property(nonatomic, strong)FKXSecondAskModel * secondModel;

- (void)goToPayService;//h5播放完毕调用的

//h5种点击头像跳转到客服端写的个人动态主页
- (void)goToPersonalDynamicPageWithUid:(NSNumber *)uid;
@property(nonatomic, assign) BOOL isShowAlert;//未认可的才展示

@end
