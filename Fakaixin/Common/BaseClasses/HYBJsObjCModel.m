//
//  HYBJsObjCModel.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/5/19.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "HYBJsObjCModel.h"

@implementation HYBJsObjCModel

- (void)userClickedSendBarrage
{
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self.commitVC withSomeObject:nil];
    }
}
- (void)clickHotPraise:(NSString *)str
//点击热门赞赏
{
    NSLog(@"h5回调参数热门打赏:%@", str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    NSMutableDictionary *mutD = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutD setObject:dic[@"shareId"] forKey:@"shareId"];
    self.commitVC.pageType = MyPageType_hot;
    self.commitVC.payParameterDic = mutD;
    [self.commitVC createcustomPopView];
}
- (void)getTheInnerUserInfo:(NSString *)str
{
    NSLog(@"h5回调参数innerUser:%@", str);
    [self.jsContext evaluateScript:@"getTheInnerUserInfoResult()"];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    FKXUserInfoModel *model;
    if (dic[@"content"]) {//在专题的详情列表返回的是带有content的
        model = [[FKXUserInfoModel alloc] init];
        model.name = dic[@"nickName"];
        model.uid = dic[@"uid"];
//        model.price = @([dic[@"price"] integerValue]);
        model.url = dic[@"headUrl"];
    }else{//在分享会和课程是一下的内容
        model = [[FKXUserInfoModel alloc] init];
        model.name = dic[@"name"];
        model.uid = dic[@"uid"];
        model.price = @([dic[@"price"] integerValue]);
        model.url = dic[@"url"];
    }
    self.commitVC.userModel = model;
}
//个人被提问调用支付，支付成功刷新界面
- (void)someOneAskedMeAQuestion:(NSString *)str
{
    NSLog(@"h5回调参数个人提问:%@", str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (![dic[@"text"] length]) {
        [self.commitVC showHint:@"请输入提问内容"];
        return;
    }
    NSMutableDictionary *mutD = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutD setObject:dic[@"text"] forKey:@"text"];
    [mutD setObject:dic[@"uid"] forKey:@"uid"];
    self.commitVC.pageType = MyPageType_people;
    self.commitVC.payParameterDic = mutD;
    [self.commitVC goToPayService];
}
//专题，我也来答，认证倾听者
- (void)IAlseComeToAnswerTheQuestion
{
    if ([[FKXUserManager getUserInfoModel].role integerValue] == 0) {
        [self.commitVC openSecondAsk];
        return;
    }
    [self.commitVC goToCareDetailVC];
}
//享问详情，赞赏
- (void)rewordForTheSecondAskDetail:(NSString *)str
{
    NSLog(@"h5回调参数享问赞赏:%@", str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    NSMutableDictionary *mutD = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutD setObject:dic[@"voiceId"] forKey:@"voiceId"];
    [mutD setObject:dic[@"uid"] forKey:@"uid"];
    if (self.commitVC) {
        self.commitVC.pageType = MyPageType_ask_praise;
        self.commitVC.payParameterDic = mutD;
        [self.commitVC createcustomPopView];
    }
}
//付费听
- (void)payForVoice:(NSString *)str
{
    NSLog(@"h5回调参数付费听:%@", str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    NSMutableDictionary *mutD = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutD setObject:dic[@"voiceId"] forKey:@"voiceId"];
    [mutD setObject:dic[@"price"] forKey:@"price"];
    [mutD setObject:dic[@"uid"] forKey:@"uid"];
    self.commitVC.pageType = MyPageType_ask_listen;
    self.commitVC.payParameterDic = mutD;
    [self.commitVC goToPayService];
}
//播放完毕后回调我们方法,
- (void)userDidFinishPlayingTheVoice
{
    if (self.customAcceptVC) {
        [self.customAcceptVC goToPayService];
    }
}
//h5种点击头像跳转到客服端写的个人动态主页
- (void)goToPersonalDynamicPage:(NSString *)str
{
    NSLog(@"个人动态主页:%@", str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    NSMutableDictionary *mutD = [NSMutableDictionary dictionaryWithCapacity:1];
    [mutD setObject:dic[@"uid"] forKey:@"uid"];
    
    if (_customAcceptVC) {
        [_customAcceptVC goToPersonalDynamicPageWithUid:[NSNumber numberWithInteger:[mutD[@"uid"] integerValue]]];
    }
    if (_commitVC) {
        [_commitVC goToPersonalDynamicPageWithUid:[NSNumber numberWithInteger:[mutD[@"uid"] integerValue]]];
    }
}
@end
