//
//  FKXCallOrder.m
//  Fakaixin
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXCallOrder.h"

#import "NSString+Extension.h"

#import "FKXConfirmView.h"
#import "FKXBindPhone.h"
#import "FKXLiXianView.h"
#import "FKXLianjieView.h"

@interface FKXCallOrder ()

@end

@implementation FKXCallOrder

+ (FKXConfirmView *)callOrder:(FKXUserInfoModel *)proModel andVC:(UIViewController *)vc {


    FKXUserInfoModel *userModel = [FKXUserManager getUserInfoModel];
    
    
    if (!proModel.mobile || [NSString isEmpty:proModel.mobile] ||[NSString isEmpty:proModel.clientNum]) {
        [vc showHint:@"该咨询师暂未开通电话咨询服务"];
        return nil;
    }
    
    if ([proModel.uid integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [vc showHint:@"不能咨询自己"];
        return nil;
    }
    
    FKXConfirmView *order = [FKXConfirmView creatOrder];
    order.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
    
    order.price = [proModel.phonePrice integerValue]/100;
    order.head = proModel.head;
    order.name = proModel.name;
    order.status = proModel.status;
    order.listenerId = proModel.uid;
    
    if (userModel.mobile) {
        order.phoneStr = userModel.mobile;
    }
    
    if (userModel.clientNum && userModel.clientNum.length>0) {
        order.bangDingBtn.hidden = YES;
    }
 
    return order;
}

+ (FKXBindPhone *)bindPhone:(NSString *)phoneStr andVC:(UIViewController *)vc {
    if (![phoneStr isRealPhoneNumber]) {
        [vc showHint:@"请输入正确的手机号"];
        return nil;
    }
    
    FKXBindPhone *phone = [FKXBindPhone creatBangDing];
    phone.frame = CGRectMake(0, 0, 235, 345);
    CGPoint center = vc.view.center;
    phone.center = center;
    phone.phoneStr = phoneStr;
    
    FKXUserInfoModel *userModel = [FKXUserManager getUserInfoModel];

    //已经绑定手机号，无需再设置密码
    if (userModel.mobile) {
        phone.pwdTF.hidden = YES;
    }
    return phone;
}


+ (NSInteger )yanzhengCode:(NSString *)phoneStr andVC:(UIViewController *)vc {
    if (![phoneStr isRealPhoneNumber]) {
        [vc showHint:@"请输入正确的手机号"];
        return 0;
    }
    
   __block NSInteger yanzhengCode = 0;
    
    FKXUserInfoModel *userModel = [FKXUserManager getUserInfoModel];

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    if (userModel.mobile) {
        [dic setObject:userModel.mobile forKey:@"mobile"];
        [dic setObject:@(5) forKey:@"type"];
        
    }else {
        [dic setObject:userModel.mobile forKey:@"mobile"];
        [dic setObject:@(2) forKey:@"type"];
    }
    
    [AFRequest sendGetOrPostRequest:@"sys/mobilecode"param:dic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [vc hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [vc showAlertViewWithTitle:@"已发送至您的手机"];
             NSInteger codeNum =[data[@"data"] integerValue];
             yanzhengCode = codeNum;
             
         }else
         {
             [vc showHint:data[@"message"]];
         }
         
     } failure:^(NSError *error) {
         [vc showHint:@"网络出错"];
         [vc hideHud];
     }];

    return yanzhengCode;
}

+ (NSMutableDictionary *)params:(NSNumber *)listenerId time:(NSNumber *)time totals:(NSNumber *)totals andVC:(UIViewController *)vc{

    NSMutableDictionary *payParameterDic = [[NSMutableDictionary alloc]init];

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [dic setObject:listenerId forKey:@"listenerId"];
    [dic setObject:totals forKey:@"price"];
    [dic setObject:time forKey:@"phoneTime"];
    
    
    [vc showHudInView:vc.view hint:@"正在提交..."];
    [AFRequest sendGetOrPostRequest:@"listener/pay" param:dic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [vc hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
             CGFloat money = [data[@"data"][@"money"] floatValue];
             [payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
             NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
             [payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
         }else
         {
             [vc showHint:data[@"message"]];
             
         }
     } failure:^(NSError *error) {
         [vc hideHud];
         [vc showHint:@"网络出错"];
     }];
    
    return payParameterDic;
}


#pragma mark - 其他操作



@end