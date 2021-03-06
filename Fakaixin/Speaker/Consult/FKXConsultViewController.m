//
//  FKXConsultViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXConsultViewController.h"
#import "FKXConsulterCell.h"
#import "FKXCommitHtmlViewController.h"
#import "NSString+HeightCalculate.h"
#import "FKXProfessionInfoVC.h"

#import "FKXYuYueProCell.h"
#import "FKXGrayView.h"

#import "FKXConfirmView.h"
#import "FKXBindPhone.h"
#import "FKXLiXianView.h"
#import "FKXLianjieView.h"

#import "ChatViewController.h"

#import "FKXCallOrder.h"

#import "NSString+Extension.h"

typedef enum : NSUInteger {
    PayType_weChat,
    PayType_Ali,
} PayType;


@interface FKXConsultViewController ()<CallProDelegate,ConfirmDelegate,BindPhoneDelegate,CallDelegate,UITableViewDelegate,UITableViewDataSource,BeeCloudDelegate,LixianDelegate,ConsultCallProDelegate>//<FKXConsulterCellDelegate>
{
    NSInteger start;
    NSInteger size;
    BOOL isVip;

//    FKXGrayView *order;
    
    FKXUserInfoModel *professionModel;
    FKXUserInfoModel *userModel;

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

//@property (nonatomic,assign) CGFloat headerH;
//@property (nonatomic,copy) NSString *introStr;

@property   (nonatomic,strong)NSMutableArray *contentArr;

@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *clientNum;

@property (nonatomic,copy) NSString *mimaStr;
@property (nonatomic,assign) NSInteger yanzhengCode;

@property (nonatomic,copy) NSString *requestClientNum;
@property (nonatomic,copy) NSString *requestClientPwd;

@property (nonatomic,strong) NSMutableDictionary *payParameterDic;//支付参数
@property (nonatomic,assign) PayType payType;

//@property (nonatomic,strong) UITableView *tableView;


@end

@implementation FKXConsultViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginBackToConsult" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor yellowColor];
    
    userModel = [FKXUserManager getUserInfoModel];
    
    if ([_paraDic[@"role"] integerValue] == 1) {
        isVip = NO;
    }else{
        isVip = YES;
    }
    
    //设置支付代理,记得要在支付页面写上这句话，否则支付成功后不走代理方法
    [BeeCloud setBeeCloudDelegate:self];
    
    //初始化数据
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    
//    [self setUpNavBar];
    
//
//    [self.tableView registerNib:[UINib nibWithNibName:@"FKXYuYueProCell" bundle:nil] forCellReuseIdentifier:@"FKXYuYueProCell"];
    
    //给tableview添加下拉刷新,上拉加载
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    //首次刷新加载页面数据
    [self headerRefreshEvent];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshEvent) name:@"LoginBackToConsult"  object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
////    [self.tableView becomeFirstResponder];
//    [self.view bringSubviewToFront:self.tableView];
//}
#pragma mark - ---网络请求---
- (void)headerRefreshEvent
{
    start = 0;
    [self loadData];
}
- (void)footRefreshEvent
{
    start += size;
    [self loadData];
}
- (void)loadData
{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    //未登录
    if ([FKXUserManager needShowLoginVC]) {
        paramDic[@"uid"] = @0;
    }else {
        paramDic[@"uid"] = @([FKXUserManager shareInstance].currentUserId);
    }
    paramDic[@"start"] = @(start);
    paramDic[@"size"] = @(size);
    
    paramDic[@"role"] = _paraDic[@"role"];
    paramDic[@"priceOrder"] = [_paraDic[@"priceOrder"] integerValue] == -1 ? nil : _paraDic[@"priceOrder"];
    paramDic[@"goodAt"] = [_paraDic[@"goodAt"] count]?_paraDic[@"goodAt"] : nil;
   
//    [self showHudInView:self.view hint:@""];

    [AFRequest sendPostRequestTwo:@"listener/listByRole" param:paramDic success:^(id data) {
        [self hideHud];
        self.tableView.header.state = MJRefreshHeaderStateIdle;
        self.tableView.footer.state = MJRefreshFooterStateIdle;
        
        NSArray *listArr = data[@"data"][@"list"];
        NSDictionary *userD = data[@"data"][@"user"];
        self.clientNum = userD[@"clientNum"];
        self.mobile = userD[@"mobile"];
        
        if (listArr) {
            
            if ([listArr count] < kRequestSize) {
                self.tableView.footer.hidden = YES;
            }else{
                self.tableView.footer.hidden = NO;
            }
            if (start == 0){
                [_contentArr removeAllObjects];
            }
            for (NSDictionary *dic in listArr) {
                FKXUserInfoModel * officalSources =  [[FKXUserInfoModel alloc] initWithDictionary:dic error:nil];
                [_contentArr addObject:officalSources];
            }
               [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

//#pragma mark - 打电话给咨询师
//- (IBAction)callZiXun:(id)sender {
//    
//}


#pragma mark - separator insets 设置
//-(void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
//        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
//}
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//}
//#pragma mark - cell自定义代理
//- (void)goToDynamicVC:(FKXUserInfoModel*)cellModel sender:(UIButton*)sender
//{
//    FKXMyDynamicVC *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil]instantiateViewControllerWithIdentifier:@"FKXMyDynamicVC"];
//    vc.userId = cellModel.uid;
//    [vc setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:vc animated:YES];
//}
#pragma mark - tableView代理
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXUserInfoModel *model = [self.contentArr objectAtIndex:indexPath.row];
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 7;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [model.profile heightForWidth:screen.size.width - 143 usingFont:[UIFont systemFontOfSize:14] style:sty];
    CGFloat unitH = [@"哈" heightForWidth:screen.size.width - 143 usingFont:[UIFont systemFontOfSize:14] style:nil];
    if (height > (unitH + 7)*2) {
        return 95 + (unitH + 7)*2;
    }
    return 95 + height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 50;
//}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXUserInfoModel *model = [self.contentArr objectAtIndex:indexPath.row];

    FKXConsulterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXConsulterCell" forIndexPath:indexPath];
        cell.delegate = self;

//    FKXYuYueProCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXYuYueProCell" forIndexPath:indexPath];
    cell.isVip = isVip;
    cell.model = model;
//    cell.callProDelegate = self;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXUserInfoModel *model = _contentArr[indexPath.row];
    if ([model.uid integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不可以私信自己哟"];
        return;
    }
    
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    
    //保存接收方的信息
    EMMessage *receiverMessage = [[EMMessage alloc] initWithReceiver:[model.uid stringValue] bodies:nil];
    receiverMessage.from = [model.uid stringValue];
    receiverMessage.to = [NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId];
    receiverMessage.ext = @{
                            @"head" : model.head,
                            @"name": model.name,
                            };
    [self insertDataToTableWith:receiverMessage managedObjectContext:ApplicationDelegate.managedObjectContext];

    
    NSArray *array = [[FKXUserManager shareInstance] caluteHeight:model];
    ChatViewController * chatController=[[ChatViewController alloc] initWithConversationChatter:[model.uid stringValue]  conversationType:eConversationTypeChat];
    chatController.title = model.name;
    
    chatController.toZiXunShi = YES;
    
    chatController.pModel = model;
    chatController.headerH = [array[1] floatValue];
    chatController.introStr = array[0];
    
    chatController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatController animated:YES];

    
}




- (NSMutableDictionary *)payParameterDic {
    if (!_payParameterDic) {
        _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _payParameterDic;
}

//- (UITableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-49) style:UITableViewStylePlain];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
////        _tableView.backgroundColor = [UIColor blueColor];
//        _tableView.estimatedRowHeight = 44;
//        _tableView.rowHeight = UITableViewAutomaticDimension;
//        
//        [self.view addSubview:_tableView];
//    }
//    return _tableView;
//}


#pragma mark - 打电话

- (void)consultCallPro:(FKXUserInfoModel *)proModel{
    
    professionModel = proModel;
    
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }

    if (!proModel.mobile || [NSString isEmpty:proModel.mobile] ||[NSString isEmpty:proModel.clientNum]) {
        [self showHint:@"该咨询师暂未开通电话咨询服务"];
        return;
    }
    
    if ([proModel.uid integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不能咨询自己"];
        return;
    }

    order = [FKXConfirmView creatOrder];
    order.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
    order.confirmDelegate = self;

    order.price = [proModel.phonePrice integerValue]/100;
    order.head = proModel.head;
    order.name = proModel.name;
    order.status = proModel.status;
    order.listenerId = proModel.uid;

    if (self.mobile) {
        order.phoneStr = self.mobile;
    }
    
    if (self.clientNum && self.clientNum.length>0) {
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
    if (self.mobile) {
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
    
    if (!self.clientNum && !self.requestClientNum) {
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
//             NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
//             [self.payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
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
    
    [self performSelector:@selector(hideDelayed) withObject:[NSNumber numberWithBool:nil] afterDelay:10];

}

- (void)hideDelayed {
    [self hideHud];
    [self showHint:@"请到我的订单联系咨询师"];
}

#pragma mark - BeeCloudDelegate
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    [self hideHud];
    [self hideHud];
    [self hideHud];

    switch (resp.type) {
        case BCObjsTypePayResp:
        {
            // 支付请求响应
            BCPayResp *tempResp = (BCPayResp *)resp;
            if (tempResp.resultCode == 0)
            {
                [self showHint:@"支付成功，等待对方确认"];
//                if (self.isCall) {
                    [self showView];
//                }
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

- (void)loadCallLength {
    NSDictionary *params = @{@"userId":userModel.uid,@"listenerId":professionModel.uid};
    [AFRequest sendPostRequestTwo:@"listener/allow_call_length" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSInteger callNum = [data[@"data"][@"length"] integerValue];
            
            lianjie = [FKXLianjieView creatZaiXian];
            lianjie.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
            lianjie.delegate = self;
            lianjie.callLength = [NSString stringWithFormat:@"%ld",callNum*60];
            lianjie.head = professionModel.head;
            lianjie.name = professionModel.name;
            lianjie.lisId = professionModel.uid;
          
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
    if ([professionModel.status integerValue]==1) {
        [self loadCallLength];
    }else {
        lixian = [FKXLiXianView creatLiXian];
        lixian.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
        lixian.head = professionModel.head;
        lixian.name = professionModel.name;
        lixian.lisId = professionModel.uid;
        lixian.delegate = self;
        
        if ([professionModel.status integerValue]==0) {
            lixian.statusL.text = @" 离线 ";
        }else if([professionModel.status integerValue]==2) {
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
    
    if (self.mobile) {
        [dic setObject:self.mobile forKey:@"mobile"];
        [dic setObject:@(5) forKey:@"type"];
        
    }else {
        [dic setObject:self.mobile forKey:@"mobile"];
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
    else if (!self.mobile && [NSString isEmpty:secret])
    {
        [self showHint:@"请输入密码"];
        if (secret.length<6 ||secret.length>11) {
            [self showHint:@"密码的长度为6~11位"];
            return;
        }
        return;
    }
    
    if(secret) {
        self.mimaStr = [NSString md532BitUpper:secret];
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


- (void)noOperation {
    return;
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
    if (!self.mobile) {
        paramDic = @{@"mobile" : phone.phoneTF.text, @"pwd":self.mimaStr, @"clientNum":self.requestClientNum, @"clientPwd" : self.requestClientPwd};
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
//                 model.pwd = phone.pwdTF.text;
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

#pragma mark - 电话回拨
- (void)call:(NSString *)callLength {
    [self tapHide4];

    [FKXCallOrder calling:callLength userModel:userModel proModel:professionModel controller:self];

}


@end
