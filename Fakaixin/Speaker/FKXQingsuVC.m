//
//  FKXQingsuVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "FKXQingsuVC.h"
#import "FKXYuYueProCell.h"
#import "CycleScrollView.h"

#import "QingsuView.h"
#import "ScrllTitleView.h"

#import "FKXGrayView.h"
#import "FKXBindPhone.h"
#import "FKXLianjieView.h"
#import "FKXLiXianView.h"

#import "NSString+Extension.h"

#import "FKXRegularView.h"

@interface FKXQingsuVC ()<UITableViewDelegate,UITableViewDataSource,CallProDelegate,ConfirmDelegate,BindPhoneDelegate,BeeCloudDelegate>
{
    NSInteger start;
    NSInteger size;
    BOOL isVip;
    
    UIView *header;
    
    CGFloat keyboardHeight;
    
    FKXConfirmView *order;
    UIView *view1;
    
    FKXBindPhone *phone;
    UIView *view2;
    
    NSInteger times;
    NSTimer * timer;
    
    FKXUserInfoModel *professionModel;
    
    FKXLiXianView *lixian;
    UIView *view3;
    
    FKXLianjieView *lianjie;
    UIView *view4;
    
    UIView *transViewRemind;//透明图
    FKXRegularView *mindRemindV;//每日提醒界面

}

@property (nonatomic,strong)NSMutableArray *contentArr;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIView *bottomView;

@property (nonatomic,strong)NSMutableArray *viewArr;

@property (nonatomic , retain) CycleScrollView *mainScorllView;

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *clientNum;
@property (nonatomic,assign) NSInteger yanzhengCode;

@property (nonatomic,copy) NSString *requestClientNum;
@property (nonatomic,copy) NSString *requestClientPwd;

@property (nonatomic,strong) NSMutableDictionary *payParameterDic;//支付参数

@end

@implementation FKXQingsuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navTitle = @"一键咨询";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_paraDic) {
        if ([_paraDic[@"role"] integerValue] == 1) {
            isVip = NO;
        }else{
            isVip = YES;
        }
    }
    
    //设置支付代理,记得要在支付页面写上这句话，否则支付成功后不走代理方法
    [BeeCloud setBeeCloudDelegate:self];

    [self setUpNavBar];
    if (self.showBack) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backView];
    }
    //初始化数据
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;

    [self.tableView  registerNib:[UINib nibWithNibName:@"FKXYuYueProCell" bundle:nil] forCellReuseIdentifier:@"FKXYuYueProCell"];
    
    //给tableview添加下拉刷新,上拉加载
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    //首次刷新加载页面数据
    [self headerRefreshEvent];
    
    [self.view addSubview:self.bottomView];

}

#pragma mark - UI
- (void)setUpNavBar
{
    UIView *guizeV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 16)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 15)];
    label.text = @"规则";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = kColorMainBlue;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 15, 30, 1)];
    line.backgroundColor = kColorMainBlue;

    [guizeV addSubview:label];
    [guizeV addSubview:line];
    
    [guizeV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guize)]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:guizeV];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 规则
- (void)guize{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    if (!transViewRemind)
    {
        //透明背景
        transViewRemind = [[UIView alloc] initWithFrame:screenBounds];
        transViewRemind.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewRemind.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewRemind];
        
        mindRemindV = [[[NSBundle mainBundle] loadNibNamed:@"FKXRegularView" owner:nil options:nil] firstObject];
        [mindRemindV.btnDone addTarget:self action:@selector(hiddentransViewRemind) forControlEvents:UIControlEventTouchUpInside];
        [transViewRemind addSubview:mindRemindV];
        mindRemindV.center = transViewRemind.center;
        [UIView animateWithDuration:0.5 animations:^{
            transViewRemind.alpha = 1.0;
        }];
    }
}

- (void)hiddentransViewRemind
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewRemind.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewRemind removeFromSuperview];
        transViewRemind = nil;
//        NSString *imageName = @"user_guide_refresh";
//        [FKXUserManager showUserGuideWithKey:imageName];
    }];
}

#pragma mark - 一键倾诉
- (void)qingsu {
    
}

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
    paramDic[@"start"] = @(start);
    paramDic[@"size"] = @(size);
    paramDic[@"role"] = @3;
    
    self.clientNum = [FKXUserManager getUserInfoModel].clientNum;
    self.mobile = [FKXUserManager getUserInfoModel].mobile;
    
    [AFRequest sendPostRequestTwo:@"listener/listByRole" param:paramDic success:^(id data) {
        [self hideHud];
        self.tableView.header.state = MJRefreshHeaderStateIdle;
        self.tableView.footer.state = MJRefreshFooterStateIdle;
        
        NSArray *listArr = data[@"data"][@"list"];
//        NSDictionary *userD = data[@"data"][@"user"];
//        self.clientNum = userD[@"clientNum"];
//        self.mobile = userD[@"mobile"];
        
        if (listArr) {
            
            if ([data count] < kRequestSize) {
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



#pragma mark - tableViewDelegate


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.tableView)
//    {
//        CGFloat sectionHeaderHeight = 294; //sectionHeaderHeight
//        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//        }
//    }
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentArr.count;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[NSBundle mainBundle]loadNibNamed:@"QingsuView" owner:self options:nil].lastObject;
    
    
    NSMutableArray *viewsArray = [@[] mutableCopy];
    
    NSArray *arr = @[@"111111111111111111111",@"22222222222222222222",@"3333333333333333"];

    for (int i = 0; i < arr.count; ++i) {
        for (NSString *s in arr) {
           
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(64, 0, kScreenWidth-56, 98)];
            
            ScrllTitleView *view1 = [ScrllTitleView creatTitleView];
            view1.frame = CGRectMake(0, 0, kScreenWidth-56, 49);
            
           
            ScrllTitleView *view2 = [ScrllTitleView creatTitleView];
            view2.frame = CGRectMake(0, 49, kScreenWidth-56, 49);

            
            [view addSubview:view1];
            [view addSubview:view2];
            
            [viewsArray addObject:view];
        }
        
    }

    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(64, 0, 288, 98) animationDuration:2.5];
    self.mainScorllView.backgroundColor = [[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1] colorWithAlphaComponent:0.1];

    self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    self.mainScorllView.totalPagesCount = ^NSInteger(void){
        return arr.count;
    };
    
    [view addSubview:self.mainScorllView];

    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 294;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FKXUserInfoModel *model = [self.contentArr objectAtIndex:indexPath.row];

    FKXYuYueProCell * cell =[tableView dequeueReusableCellWithIdentifier:@"FKXYuYueProCell" forIndexPath:indexPath];
    cell.model = model;
    cell.isVip = isVip;
    
    cell.callProDelegate = self;
    
    return cell;
}




- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight-64-10) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50-64, kScreenWidth, 50)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.alpha = 0.85;
        
        UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        lineV.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        [_bottomView addSubview:lineV];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (kScreenWidth-150)/2, 50)];
        lable.text = @"25元/15分钟";
        lable.textAlignment = NSTextAlignmentCenter;
        lable.font = [UIFont systemFontOfSize:13];
        lable.textColor = [UIColor grayColor];
        lable.backgroundColor = [UIColor clearColor];
        [_bottomView addSubview:lable];
        
        UIButton *zixunBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        zixunBtn.frame = CGRectMake((kScreenWidth-150)/2, 6, 150, 37);
        zixunBtn.backgroundColor = [UIColor colorWithRed:46/255.0 green:227/255.0 blue:245/255.0 alpha:1];
        zixunBtn.layer.cornerRadius = 18;
        zixunBtn.layer.masksToBounds = YES;
//        [zixunBtn setBackgroundImage:[UIImage imageNamed:@"qingsu_btnBack"] forState:UIControlStateNormal];
        [zixunBtn setTitle:@"  一键倾诉" forState:UIControlStateNormal];
        [zixunBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [zixunBtn setImage:[UIImage imageNamed:@"free_yuyue"] forState:UIControlStateNormal];
        zixunBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [zixunBtn addTarget:self action:@selector(qingsu) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:zixunBtn];
    }
    return _bottomView;
}

- (NSMutableArray *)viewArr {
    if (!_viewArr) {
        _viewArr = [NSMutableArray arrayWithCapacity:1];
    }
    return _viewArr;
}


- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        UIImageView *imge = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back"]];
        [_backView addSubview:imge];
        
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)]];
    }
    return _backView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 打电话

- (void)callPro:(FKXUserInfoModel *)proModel{
    
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
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:view1];
    [[UIApplication sharedApplication].keyWindow addSubview:order];
    
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
    
    [[UIApplication sharedApplication].keyWindow addSubview:view2];
    [[UIApplication sharedApplication].keyWindow addSubview:phone];
    
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
                [self showView];
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

- (void)showView {
    [self hideHud];
    //离线
    if ([professionModel.status integerValue]==0) {
        lixian = [FKXLiXianView creatLiXian];
        lixian.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
        lixian.head = professionModel.head;
        lixian.name = professionModel.name;
        
        view3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        view3.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [view3 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide3)]];
        
        [[UIApplication sharedApplication].keyWindow addSubview:view3];
        [[UIApplication sharedApplication].keyWindow addSubview:lixian];
        
        
    }else {
        lianjie = [FKXLianjieView creatZaiXian];
        lianjie.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
        lianjie.head = professionModel.head;
        lianjie.name = professionModel.name;
        
        view4 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        view4.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [view4 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide4)]];
        
        [[UIApplication sharedApplication].keyWindow addSubview:view4];
        [[UIApplication sharedApplication].keyWindow addSubview:lianjie];
        
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

- (NSMutableDictionary *)payParameterDic {
    if (!_payParameterDic) {
        _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _payParameterDic;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
