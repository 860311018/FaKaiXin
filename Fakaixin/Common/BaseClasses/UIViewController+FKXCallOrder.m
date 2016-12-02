//
//  UIViewController+FKXCallOrder.m
//  Fakaixin
//
//  Created by apple on 2016/12/2.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "UIViewController+FKXCallOrder.h"
#import "FKXUserInfoModel.h"
#import "NSString+Extension.h"
#import "FKXConfirmView.h"


//@interface UIViewController (FKXCallOrder)<ConfirmDelegate>
//{
//    CGFloat keyboardHeight;
//
//    FKXConfirmView *order;
//    UIView *view1;
//}


//@property (nonatomic,assign) PayType payType;
//
//@end

@implementation UIViewController (FKXCallOrder)




-(void)callOrder:(FKXUserInfoModel *)model{
//    FKXUserInfoModel *userModel = [FKXUserManager getUserInfoModel];
//    
//    if ([FKXUserManager needShowLoginVC]) {
//        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
//        return;
//    }
//    
//    if (!model.mobile || [NSString isEmpty:model.mobile] ||[NSString isEmpty:model.clientNum]) {
//        [self showHint:@"该咨询师暂未开通电话咨询服务"];
//        return;
//    }
//    
//    if ([model.uid integerValue] == [FKXUserManager shareInstance].currentUserId) {
//        [self showHint:@"不能咨询自己"];
//        return;
//    }
//    
//    order = [FKXConfirmView creatOrder];
//    order.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
//    order.confirmDelegate = self;
//    
//    order.price = [model.phonePrice integerValue]/100;
//    order.head = model.head;
//    order.name = model.name;
//    order.status = model.status;
//    order.listenerId = model.uid;
//    
//    if (userModel.mobile) {
//        order.phoneStr = userModel.mobile;
//    }
//    if (userModel.clientNum && userModel.clientNum.length>0) {
//        order.bangDingBtn.hidden = YES;
//    }
//    
//    view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    view1.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    [view1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:controller action:@selector(tapHide)]];
//    
//    view1.alpha = 0;
//    order.alpha = 0;
//    [[UIApplication sharedApplication].keyWindow addSubview:view1];
//    [[UIApplication sharedApplication].keyWindow addSubview:order];
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        view1.alpha = 1;
//        order.alpha = 1;
//    }];
}

#pragma mark - confirmDelegate
- (void)textBeginEdit {
//    if (keyboardHeight >0) {
//        [UIView animateWithDuration:0.5 animations:^{
//            order.frame = CGRectMake(0, kScreenHeight-285-keyboardHeight, kScreenWidth, 285);
//        }];
//    }
}

- (void)bangDingPhone:(NSString *)phoneStr{
    
}

- (void)weiXin {
//    self.payType = PayType_weChat;
}

- (void)zhiFuBao {
//    self.payType = PayType_Ali;
}

- (void)confirm:(NSNumber *)listenerId time:(NSNumber *)time totals:(NSNumber *)totals {
    
}


- (void)tapHide {
//    [UIView animateWithDuration:0.6 animations:^{
//        view1.alpha = 0;
//        order.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [view1 removeFromSuperview];
//            [order removeFromSuperview];
//        }
//    }];
}


@end
