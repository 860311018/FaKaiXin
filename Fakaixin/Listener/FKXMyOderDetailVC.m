//
//  FKXMyOderDetailVC.m
//  Fakaixin
//
//  Created by apple on 2016/12/1.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyOderDetailVC.h"
#import "FKXOrderModel.h"

#import "FKXEvaluateVC.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXNotifcationModel.h"

#import "FKXProfessionInfoVC.h"

#import "FKXConfirmView.h"
#import "FKXBindPhone.h"
#import "FKXLiXianView.h"
#import "FKXLianjieView.h"
#import "FKXCallOrder.h"
#import "NSString+Extension.h"
#import "FKXPayView.h"

#import "ChatViewController.h"

typedef enum : NSUInteger {
    PayType_weChat,
    PayType_Ali,
} PayType;


@interface FKXMyOderDetailVC ()<ConfirmDelegate,BindPhoneDelegate,BeeCloudDelegate,CallDelegate,LixianDelegate>
{
    UIView *transViewPay;   //支付的透明图
    FKXPayView *payView;    //支付界面
    
    CGFloat keyboardHeight;
    
    FKXConfirmView *order;
    UIView *view1;
    
    FKXBindPhone *phone;
    UIView *view2;
    
    NSInteger times;
    NSTimer * timer;
    
    
    FKXLiXianView *lixian;
    UIView *view3;
    
    FKXLianjieView *lianjie;
    UIView *view4;
}
@property (weak, nonatomic) IBOutlet UILabel *yuyueTimeL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *zixunL;
@property (weak, nonatomic) IBOutlet UILabel *zixunDetail;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;

@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;


@property (nonatomic,assign) NSInteger yanzhengCode;

@property (nonatomic,copy) NSString *requestClientNum;
@property (nonatomic,copy) NSString *requestClientPwd;

@property (nonatomic,strong) NSMutableDictionary *payParameterDic;//支付参数
@property (nonatomic,strong) NSMutableDictionary *payParameterDic2;//图文支付参数

@property (nonatomic,assign) PayType payType;
@property (nonatomic,assign) BOOL isCall;

@end

@implementation FKXMyOderDetailVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [BeeCloud setBeeCloudDelegate:self];

    self.navTitle = @"我的订单";
    self.userModel = [FKXUserManager getUserInfoModel];

    [self setUpBtn];
    
    [self loadListenInfo:self.model];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}

- (IBAction)oneBtnClick:(id)sender {
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 1){
            //去服务
            if (self.model.callLength && [self.model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:self.model];
            }else {
                //图文咨询
                [self toTuWen:self.model];
            }
        }else if ([self.model.status integerValue] == 4) {
            //去看评价
            [self toCommenViewt:self.model];
        }
    }else{
        if ([self.model.status integerValue] == 0){
            //私信
            [self toChatVC:self.model];
        }
         else if ([self.model.status integerValue] == 1) {
            //立即咨询
            if (self.model.callLength && [self.model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:self.model];
            }else {
                //图文咨询
                [self toTuWen:self.model];
            }
        }
        else if ([self.model.status integerValue] == 2) {
            //立即评价
            [self toComment:self.model];

        }else if ([self.model.status integerValue] == 4) {
            //再次预约
            if (self.model.callLength && [self.model.callLength integerValue]!=0) {
                //电话咨询
                [self callOrder:self.model];
            }else {
                //图文咨询
                [self tuwenOrder:self.model];
            }
        }
    }
}

- (IBAction)cancelClick:(id)sender {
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 0){
            //拒绝订单
            [self operationOrder:self.model status:@3];
        }
    }
}

- (IBAction)confirmBtnClick:(id)sender {
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 0){
            //确认订单
            [self operationOrder:self.model status:@1];
        }
    }
}

- (void)setUpBtn {
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:self.model.headUrl] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nameL.text = self.model.nickName;
    
    
    if (self.model.callLength) {
        self.zixunL.text = @"电话咨询";
        NSInteger minute = [self.model.callLength integerValue];
        self.yuyueTimeL.text = [NSString stringWithFormat:@"预约时间：%ld分钟",minute];

    }else {
        self.zixunL.text = @"图文咨询";
        self.yuyueTimeL.text = @"预约时间：60分钟";
    }
    
    
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 0) {
            self.statusL.text = @"已付款";
            
            self.bottomView.hidden = NO;
            self.oneBtn.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.commentBtn.hidden = NO;
            [self.cancelBtn setTitle:@"拒绝订单" forState:UIControlStateNormal];
            [self.commentBtn setTitle:@"接受订单" forState:UIControlStateNormal];
        }else if ([self.model.status integerValue] == 1) {
            
            self.statusL.text = @"进行中";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"去服务" forState:UIControlStateNormal];

        }else if ([self.model.status integerValue] == 2) {
            self.statusL.text = @"待评价";
            
            self.bottomView.hidden = YES;
            
        }else if ([self.model.status integerValue] == 3) {
            self.statusL.text = @"已拒绝";

            self.bottomView.hidden = YES;

        }else if ([self.model.status integerValue] == 4) {
            self.statusL.text = @"已评价";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"去看评价" forState:UIControlStateNormal];
 
        }
    }else {
        if ([self.model.status integerValue] == 0) {
            self.statusL.text = @"待确认";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"私信TA" forState:UIControlStateNormal];
            
        }else if ([self.model.status integerValue] == 1) {
            self.statusL.text = @"进行中";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"立即咨询" forState:UIControlStateNormal];
        }else if ([self.model.status integerValue] == 2) {
            self.statusL.text = @"待评价";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"立即评价" forState:UIControlStateNormal];
        }else if ([self.model.status integerValue] == 3) {
            self.statusL.text = @"已拒绝";

            self.bottomView.hidden = YES;
        }else if ([self.model.status integerValue] == 4) {
            self.statusL.text = @"已完成";
            
            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"再次预约" forState:UIControlStateNormal];
        }
    }
    
}


#pragma mark - 操作订单（拒绝、接受）
- (void)operationOrder:(FKXOrderModel *)model status:(NSNumber *)status {
    NSNumber *type = @0;
    if (model.callLength && [model.callLength integerValue]!=0) {
        type = @1;
    }
    NSDictionary *params = @{@"orderId":model.orderId,@"type":type,@"status":status};
    
    [AFRequest sendGetOrPostRequest:@"listener/updateOrders" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue]==0) {
            self.model.status = status;
            [self setUpBtn];
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

#pragma mark - 电话咨询（已经付款）
- (void)toCall:(FKXOrderModel *)model {
    [self showHudInView:self.view hint:@""];
    NSString *callStr = [NSString stringWithFormat:@"%ld",[model.callLength integerValue] *60];
    [self call:callStr];
}

- (void)call:(NSString *)callLength {
    [self tapHide4];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@{                                            @"appId":ResetAppId,@"fromClient":self.userModel.clientNum,@"to":self.proModel.mobile,@"maxallowtime":callLength}, @"callback",nil];
    [AFRequest sendResetPostRequest:@"Calls/callBack" param:params success:^(id data) {
        [self hideHud];
        NSString *respCode = data[@"resp"][@"respCode"];
        if ([respCode isEqualToString:@"000000"]) {
            [self showHint2:@"马上会有电话打到您手机上，请及时接听。如果没有请过5分钟后再次拨打"];
            //改变咨询师在线状态
            NSDictionary *param = @{@"status":@2};
            [AFRequest sendPostRequestTwo:@"listener/update_status" param:param success:^(id data) {
                NSLog(@"%@",data);
            } failure:^(NSError *error) {
                NSLog(@"%@",error.description);
                
            }];
            
        }else {
            [self showHint:@"电话线路出错"];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"电话线路出错"];
    }];
}

#pragma mark - 图文咨询（聊天页，已确认订单）
- (void)toTuWen:(FKXOrderModel *)model {
    [self toChatVC:model];
}



#pragma mark - 下图文订单 （再次预约）
- (void)tuwenOrder:(FKXOrderModel *)model {
    self.isCall = NO;
    [self bookConsultService:model];
}

#pragma mark - 私信（未确认订单）
- (void)toChatVC:(FKXOrderModel *)model {
    if (!model.listenerId) {
        return;
    }
    
    if ([model.listenerId integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不可以私信自己哟"];
        return;
    }
    NSDictionary *params = @{@"userId":self.userModel.uid,@"listenerId":model.listenerId};
    
    [AFRequest sendPostRequestTwo:@"user/selectClient" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSDictionary *dic = data[@"data"][@"listenerInfo"];
            self.proModel = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];
            
            NSArray *array = [[FKXUserManager shareInstance] caluteHeight:self.proModel];
            ChatViewController * chatController=[[ChatViewController alloc] initWithConversationChatter:[self.proModel.uid stringValue]  conversationType:eConversationTypeChat];
            chatController.title = self.proModel.name;
            
            if ([self.proModel.role integerValue] !=0) {
                chatController.toZiXunShi = YES;
            }
            
            chatController.pModel = self.proModel;
            chatController.headerH = [array[1] floatValue];
            chatController.introStr = array[0];
            
            chatController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatController animated:YES];
            
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

#pragma mark - 去评价
- (void)toComment:(FKXOrderModel *)model {
    FKXEvaluateVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXEvaluateVC"];
    FKXNotifcationModel *noModel = [[FKXNotifcationModel alloc]init];
    noModel.fromId =model.listenerId;
    noModel.fromHeadUrl = model.headUrl;
    noModel.fromNickname = model.nickName;
    if (model.callLength && [model.callLength integerValue]!=0) {
        noModel.type = @2;
    }else {
        noModel.type = @1;
    }
    vc.model = noModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 去看评价
- (void)toCommenViewt:(FKXOrderModel *)model {
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"user_center_yu_yue";//预约
    vc.pageType = MyPageType_consult;
    FKXUserInfoModel *userModel = [FKXUserManager getUserInfoModel];
    vc.urlString = [NSString stringWithFormat:@"%@front/user_center.html?uid=%@&token=%@",kServiceBaseURL, userModel.uid, [FKXUserManager shareInstance].currentUserToken];
    vc.userModel = userModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadListenInfo:(FKXOrderModel *)model {
    NSDictionary *parmas = @{};
    if (!self.isWorkBench) {
        parmas = @{@"userId":self.userModel.uid,@"listenerId":model.listenerId};
    }else {
        parmas = @{@"userId":self.userModel.uid,@"listenerId":model.userId};
    }
    [AFRequest sendPostRequestTwo:@"user/selectClient" param:parmas success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSDictionary *dic = data[@"data"][@"listenerInfo"];
            self.proModel = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

#pragma mark - 下电话订单 （再次预约）
- (void)callOrder:(FKXOrderModel *)model {
    self.isCall = YES;
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    
    if (!self.proModel.mobile || [NSString isEmpty:self.proModel.mobile] ||[NSString isEmpty:self.proModel.clientNum]) {
        [self showHint:@"该咨询师暂未开通电话咨询服务"];
        return;
    }
    
    if ([self.proModel.uid integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不能咨询自己"];
        return;
    }
    
    order = [FKXConfirmView creatOrder];
    order.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
    order.confirmDelegate = self;
    
    order.price = [self.proModel.phonePrice integerValue]/100;
    order.head = self.proModel.head;
    order.name = self.proModel.name;
    order.status = self.proModel.status;
    order.listenerId = self.proModel.uid;
    
    if (self.userModel.mobile) {
        order.phoneStr = self.userModel.mobile;
    }
    
    if (self.userModel.clientNum && self.userModel.clientNum.length>0) {
        order.bangDingBtn.hidden = YES;
    }
    
    
    view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view1.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [view1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide)]];
    
    view1.alpha = 0;
    order.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:view1];
    [[UIApplication sharedApplication].keyWindow addSubview:order];
    
    [UIView animateWithDuration:0.5 animations:^{
        view1.alpha = 1;
        order.alpha = 1;
    }];

}

- (void)textBeginEdit {
    if (keyboardHeight >0) {
        [UIView animateWithDuration:0.5 animations:^{
            order.frame = CGRectMake(0, kScreenHeight-285-keyboardHeight, kScreenWidth, 285);
        }];
    }
}

- (void)bangDingPhone:(NSString *)phoneStr{
    
    if (![phoneStr isRealPhoneNumber]) {
        [self showHint:@"请输入正确的手机号"];
        return;
    }
    
    phone = [FKXBindPhone creatBangDing];
    phone.frame = CGRectMake(0, 0, 235, 345);
    CGPoint center = self.view.center;
    phone.center = center;
    phone.phoneStr = phoneStr;
    phone.bindPhoneDelegate = self;
    
    //已经绑定手机号，无需再设置密码
    if (self.userModel.mobile) {
        phone.pwdTF.hidden = YES;
    }
    
    view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [view2 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide2)]];
    
    view2.alpha = 0;
    phone.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:view2];
    [[UIApplication sharedApplication].keyWindow addSubview:phone];
    
    [UIView animateWithDuration:0.5 animations:^{
        view2.alpha = 1;
        phone.alpha = 1;
    }];
    
}

- (void)weiXin {
    self.payType = PayType_weChat;
}

- (void)zhiFuBao {
    self.payType = PayType_Ali;
}

- (void)confirm:(NSNumber *)listenerId time:(NSNumber *)time totals:(NSNumber *)totals {
    
    if (!self.userModel.clientNum && !self.requestClientNum) {
        [self showHint:@"请先绑定手机号哟"];
        return;
    }
    
    [self tapHide];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [dic setObject:listenerId forKey:@"listenerId"];
    [dic setObject:totals forKey:@"price"];
    [dic setObject:time forKey:@"phoneTime"];
    
    //    NSDictionary *paramDic = @{@"listenerId":listenerId,@"price":totals,@"phoneTime":time};
    
    [self showHudInView:self.view hint:@"正在提交..."];
    [AFRequest sendGetOrPostRequest:@"listener/pay" param:dic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self.payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
             CGFloat money = [data[@"data"][@"money"] floatValue];
             [self.payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
             NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
             [self.payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
             [self confirmToPay];
         }else
         {
             [self showHint:data[@"message"]];
             
         }
     } failure:^(NSError *error) {
         [self hideHud];
         [self showHint:@"网络出错"];
     }];
}

- (void)confirmToPay{
    PayChannel channel = PayChannelWxApp;
    switch (self.payType) {
        case PayType_weChat:
            channel = PayChannelWxApp;
            break;
        case PayType_Ali:
            channel = PayChannelAliApp;
            break;
        default:
            break;
    }
    [self doPay:channel billNo:self.payParameterDic[@"billNo"] money:self.payParameterDic[@"money"]];
    
}
//微信、支付宝
- (void)doPay:(PayChannel)channel billNo:(NSString *)billNo money:(NSNumber *)money {
    [self showHudInView:self.view hint:@"正在支付..."];
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"伐开心订单";
    payReq.totalFee = [NSString stringWithFormat:@"%ld",[money integerValue]];
    payReq.billNo = billNo;
    if (channel == PayChannelAliApp) {
        payReq.scheme = @"Zhifubaozidingyi001test";
    }
    payReq.billTimeOut = 360;
    payReq.viewController = self;
    payReq.optional = nil;
    [BeeCloud sendBCReq:payReq];
}



- (void)loadCallLength {
    NSDictionary *params = @{@"userId":self.userModel.uid,@"listenerId":self.proModel.uid};
    [AFRequest sendPostRequestTwo:@"listener/allow_call_length" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSInteger callNum = [data[@"data"][@"length"] integerValue];
            
            lianjie = [FKXLianjieView creatZaiXian];
            lianjie.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
            lianjie.delegate = self;
            lianjie.lisId = self.proModel.uid;
            lianjie.callLength = [NSString stringWithFormat:@"%ld",callNum*60];
            lianjie.head = self.proModel.head;
            lianjie.name = self.proModel.name;
            
            view4 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            view4.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            [view4 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide4)]];
            
            view4.alpha = 0;
            lianjie.alpha = 0;
            [[UIApplication sharedApplication].keyWindow addSubview:view4];
            [[UIApplication sharedApplication].keyWindow addSubview:lianjie];
            
            [UIView animateWithDuration:0.5 animations:^{
                view4.alpha = 1;
                lianjie.alpha = 1;
            }];
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

- (void)showView {
    [self hideHud];
    //在线
    if ([self.proModel.status integerValue]==1) {
        [self loadCallLength];

    }else {
        lixian = [FKXLiXianView creatLiXian];
        lixian.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
        lixian.head = self.proModel.head;
        lixian.name = self.proModel.name;
        lixian.delegate = self;
        lixian.lisId = self.proModel.uid;
        if ([self.proModel.status integerValue]==0) {
            lixian.statusL.text = @" 离线 ";
        }else if([self.proModel.status integerValue]==2) {
            lixian.statusL.text = @" 通话中 ";
        }
        view3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        view3.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [view3 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide3)]];
        
        view3.alpha = 0;
        lixian.alpha = 0;
        [[UIApplication sharedApplication].keyWindow addSubview:view3];
        [[UIApplication sharedApplication].keyWindow addSubview:lixian];
        
        [UIView animateWithDuration:0.5 animations:^{
            view3.alpha = 1;
            lixian.alpha = 1;
        }];
    }
    
}

#pragma mark - 绑定手机代理
- (void)receiveCode:(NSString *)phoneStr {
    if (![phoneStr isRealPhoneNumber]) {
        [self showHint:@"请输入正确的手机号"];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    if (self.userModel.mobile) {
        [dic setObject:self.userModel.mobile forKey:@"mobile"];
        [dic setObject:@(5) forKey:@"type"];
        
    }else {
        [dic setObject:self.userModel.mobile forKey:@"mobile"];
        [dic setObject:@(2) forKey:@"type"];
    }
    
    [AFRequest sendGetOrPostRequest:@"sys/mobilecode"param:dic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showAlertViewWithTitle:@"已发送至您的手机"];
             NSInteger codeNum =[data[@"data"] integerValue];
             self.yanzhengCode = codeNum;
             [self startTimer];
             
         }else
         {
             [self showHint:data[@"message"]];
         }
         
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
    
}

- (void)saveBind:(NSString *)phoneStr code:(NSString *)codeStr secret:(NSString *)secret {
    if ([NSString isEmpty:codeStr])
    {
        [self showHint:@"请输入验证码"];
        return;
    }else if ([codeStr integerValue] != self.yanzhengCode) {
        [self showHint:@"验证码错误！"];
        return;
    }
    else if (!self.userModel.mobile && [NSString isEmpty:secret])
    {
        [self showHint:@"请输入密码"];
        if (secret.length<6 ||secret.length>11) {
            [self showHint:@"密码的长度为6~11位"];
            return;
        }
        return;
    }
    
    //开始申请client
    [self requsetClient];
}

#pragma mark - 其他操作
- (void)tapHide {
    [UIView animateWithDuration:0.6 animations:^{
        view1.alpha = 0;
        order.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [view1 removeFromSuperview];
            [order removeFromSuperview];
        }
    }];
}

- (void)tapHide2 {
    [UIView animateWithDuration:0.6 animations:^{
        view2.alpha = 0;
        phone.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [view2 removeFromSuperview];
            [phone removeFromSuperview];
        }
    }];
}

- (void)tapHide3 {
    [UIView animateWithDuration:0.6 animations:^{
        view3.alpha = 0;
        lixian.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [view3 removeFromSuperview];
            [lixian removeFromSuperview];
        }
    }];
}


- (void)tapHide4 {
    [UIView animateWithDuration:0.6 animations:^{
        view4.alpha = 0;
        lianjie.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [view4 removeFromSuperview];
            [lianjie removeFromSuperview];
        }
    }];
}

- (void)lixiantoHead:(NSNumber *)uid {
    [self tapHide3];
    [self clickHead:uid];
}

- (void)toHead:(NSNumber *)uid {
    [self tapHide4];
    [self clickHead:uid];
}

- (void)clickHead:(NSNumber *)listenId {
    [self tapHide];
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = listenId;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)not{
    NSValue * value = [not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize size2 = [value CGRectValue].size;
    keyboardHeight = size2.height;
    if (keyboardHeight >0) {
        static int i=0;
        if (i==0) {
            [UIView animateWithDuration:0.5 animations:^{
                order.frame = CGRectMake(0, kScreenHeight-285-keyboardHeight, kScreenWidth, 285);
            }];
            i++;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)not{
    
    order.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
    
}

-(void)startTimer
{
    phone.sendCodeBtn.userInteractionEnabled = YES;
    times=60;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeload) userInfo:nil repeats:YES];
            [timer fire];
            [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop]run];
        }
        
    });
}
-(void)timeload
{
    
    times=times-1;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (times>0) {
            [phone.sendCodeBtn setTitleColor:[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1] forState:UIControlStateNormal];
            [phone.sendCodeBtn setTitle:[NSString stringWithFormat:@"%lds",(long)times] forState:UIControlStateNormal];
        }else
        {
            [timer invalidate];
            timer=nil;
            [phone.sendCodeBtn setTitleColor:[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1] forState:UIControlStateNormal];
            [phone.sendCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
            phone.sendCodeBtn.userInteractionEnabled = YES;
        }
        
    });
    
    
}

- (void)requsetClient {
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:@{                                            @"appId":ResetAppId,@"charge": @"0",@"mobile":phone.phoneTF.text,@"clientType": @"0"}, @"client",nil];
    [AFRequest sendResetPostRequest:@"Clients" param:params success:^(id data) {
        NSString *respCode = data[@"resp"][@"respCode"];
        if ([respCode isEqualToString:@"103114"]) {
            //已经绑定Client 但是没有存入数据库，查询当前绑定信息
            [self selectClient];
        }
        else if ([respCode isEqualToString:@"000000"]) {
            //            [self showHint:@"绑定成功"];
            NSDictionary *clientDic = data[@"resp"][@"client"];
            
            self.requestClientNum = clientDic[@"clientNum"];
            self.requestClientPwd = clientDic[@"clientPwd"];
            
            [self addToData];
        }else {
            [self showHint:@"绑定失败"];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self showHint:@"网络出错"];
        [self hideHud];
        
    }];
}

- (void)selectClient {
    NSString *param = [NSString stringWithFormat:@"&mobile=%@&appId=%@",phone.phoneTF.text,ResetAppId];
    [AFRequest sendResetGetRequest:@"ClientsByMobile" param:param success:^(id data) {
        if ([data[@"resp"][@"respCode"] isEqualToString:@"000000"]) {
            self.requestClientNum = data[@"resp"][@"client"][@"clientNumber"];
            self.requestClientPwd = data[@"resp"][@"client"][@"clientPwd"];
            //            self.creatTime = data[@"resp"][@"client"][@"createDate"];
            
            [self addToData];
        }else {
            [self showHint:@"绑定失败"];
        }
    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];
}

//存入绑定手机
- (void)addToData {
    
    NSDictionary *paramDic;
    
    //未绑定手机号，传入手机号，登录密码，clientPwd，clientNum
    if (!self.userModel.mobile) {
        paramDic = @{@"mobile" : phone.phoneTF.text, @"pwd":phone.pwdTF.text, @"clientNum":self.requestClientNum, @"clientPwd" : self.requestClientPwd};
    }
    //已绑定手机号 ，只需传入clientPwd，clientNum
    else {
        paramDic = @{@"clientNum":self.requestClientNum, @"clientPwd" : self.requestClientPwd};
    }
    
    [AFRequest sendGetOrPostRequest:@"user/edit"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"绑定手机成功"];
             phone.saveBtn.enabled = NO;
             
             FKXUserInfoModel *model = [FKXUserManager getUserInfoModel];
             
             model.clientNum = self.requestClientNum;
             model.clientPwd = self.requestClientPwd;
             
             if (!model.mobile) {
                 model.mobile = phone.phoneTF.text;
                 model.pwd = phone.pwdTF.text;
             }
             [FKXUserManager archiverUserInfo:model toUid:[model.uid stringValue]];
             
             [self tapHide2];
             order.bangDingBtn.hidden = YES;
             
         }else{
             [self showHint:data[@"message"]];
         }
         [self hideHud];
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSMutableDictionary *)payParameterDic {
    if (!_payParameterDic) {
        _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _payParameterDic;
}


- (void)bookConsultService:(FKXOrderModel *)model
{
    if ([FKXUserManager needShowLoginVC])
    {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
    }else
    {
        //        if (![WXApi isWXAppInstalled]) {
        //            [self showHint:@"当前不在线"];
        //            return;
        //        }else
        if (model.listenerId == [FKXUserManager getUserInfoModel].uid)
        {
            [self showHint:@"不能咨询自己"];
            return;
        }
        
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setValue:model.listenerId forKey:@"uid"];
        [self showHudInView:self.view hint:@"正在预约..."];
        [AFRequest sendGetOrPostRequest:@"talk/pay" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
         {
             [self hideHud];
             if ([data[@"code"] integerValue] == 0)
             {
                 if (!_payParameterDic2) {
                     _payParameterDic2 = [NSMutableDictionary dictionaryWithCapacity:1];
                 }
                 [_payParameterDic2 setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
                 CGFloat money = [data[@"data"][@"money"] floatValue];
                 [_payParameterDic2 setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
                 NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
                 [_payParameterDic2 setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
                 //创建购买界面
                 [self setUpTransViewPay];
             }
             else if ([data[@"code"] integerValue] == 4)
             {
                 [self showAlertViewWithTitle:data[@"message"]];
                 [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             }else
             {
                 [self showHint:data[@"message"]];
                 
             }
         } failure:^(NSError *error) {
             [self hideHud];
             [self showHint:@"网络出错"];
         }];
    }
}
- (void)setUpTransViewPay
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transViewPay)
    {
        //透明背景
        transViewPay = [[UIView alloc] initWithFrame:screenBounds];
        transViewPay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewPay.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewPay];
        
        payView = [[[NSBundle mainBundle] loadNibNamed:@"FKXPayView" owner:nil options:nil] firstObject];
        [payView.btnClose addTarget:self action:@selector(hiddentransViewPay) forControlEvents:UIControlEventTouchUpInside];
        [payView.myPayBtn addTarget:self action:@selector(confirmToPay2) forControlEvents:UIControlEventTouchUpInside];
        
        if (_payParameterDic2[@"isAmple"]) {
            if (![_payParameterDic2[@"isAmple"] integerValue]) {
                payView.btnRemain.enabled = NO;
                [payView.btnRemain setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
        
        [transViewPay addSubview:payView];
        payView.center = transViewPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewPay.alpha = 1.0;
        }];
        
        payView.labTitle.text = @"咨询";
        payView.labPrice.text = [NSString stringWithFormat:@"%.2f", [_payParameterDic2[@"money"] doubleValue]/100];
    }
}

- (void)hiddentransViewPay
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewPay.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewPay removeFromSuperview];
        transViewPay = nil;
    }];
}
- (void)confirmToPay2
{
    PayChannel channel = PayChannelWxApp;
    switch (payView.myPayChannel) {
        case MyPayChannel_weChat:
            channel = PayChannelWxApp;
            break;
        case MyPayChannel_Ali:
            channel = PayChannelAliApp;
            break;
        case MyPayChannel_remain:
        {
            [self showHudInView:self.view hint:@"正在支付..."];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:_payParameterDic2[@"billNo"] forKey:@"billNo"];
            NSString *methodName = @"sys/balancePay";
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     [self showHint:@"支付成功，等待对方确认"];
                 }
                 else if ([data[@"code"] integerValue] == 4)
                 {
                     [self showAlertViewWithTitle:data[@"message"]];
                     
                     [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                 }else
                 {
                     [self showHint:data[@"message"]];
                 }
             } failure:^(NSError *error) {
                 [self showHint:@"网络出错"];
                 [self hideHud];
             }];
            [self hiddentransViewPay];
        }
            break;
        default:
            break;
    }
    if (payView.myPayChannel == MyPayChannel_remain) {
        return;
    }
    //除余额以外的支付
    [self doPay:channel billNo:_payParameterDic2[@"billNo"] money:_payParameterDic2[@"money"]];
    
    [self hiddentransViewPay];
}

#pragma mark - BeeCloudDelegate
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    [self hideHud];
    switch (resp.type) {
        case BCObjsTypePayResp:
        {
            // 支付请求响应
            BCPayResp *tempResp = (BCPayResp *)resp;
            if (tempResp.resultCode == 0)
            {
                [self showHint:@"支付成功，等待对方确认"];
                if (self.isCall) {
                    [self showView];
                }
            }
            else
            {
                //支付取消或者支付失败,,或者取消支付都要再次提示用户购买
                [self showAlertViewWithTitle:[NSString stringWithFormat:@"%@", tempResp.errDetail]];
            }
        }
            break;
        default:
            NSLog(@"%@", @"不是支付响应的回调");
            break;
    }
}

@end
