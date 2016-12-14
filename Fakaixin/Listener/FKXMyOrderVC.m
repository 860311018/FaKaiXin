//
//  FKXMyOrderVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/23.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyOrderVC.h"
#import "OrderRegularV.h"
#import "FKXLisOrderV.h"

#import "FKXMyOrdersCell.h"
#import "FKXOrderModel.h"

#import "FKXMyOderDetailVC.h"

#import "FKXEvaluateVC.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXNotifcationModel.h"

#import "FKXProfessionInfoVC.h"

#import "FKXConfirmView.h"
#import "FKXBindPhone.h"
#import "FKXLiXianView.h"
#import "FKXLianjieView.h"

#import "NSString+Extension.h"

#import "ChatViewController.h"
#import "FKXCallOrder.h"
#import "FKXPayView.h"

typedef enum : NSUInteger {
    PayType_weChat,
    PayType_Ali,
} PayType;


@interface FKXMyOrderVC ()<UITableViewDelegate,UITableViewDataSource,ConfirmDelegate,BindPhoneDelegate,BeeCloudDelegate,CallDelegate,LixianDelegate>
{
    
    NSInteger start;
    NSInteger size;

    FKXEmptyData *emptyDataView;    //空数据
   
    UIView *transViewPay;   //支付的透明图
    FKXPayView *payView;    //支付界面

    UIView *transViewRemind;//透明图
    OrderRegularV *mindRemindV;//每日提醒界面
    FKXLisOrderV *mindRemindV2;
    
    FKXUserInfoModel *proModel;
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

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *tableData;
@property (nonatomic,strong) NSMutableArray *proData;

@property (nonatomic,assign) NSInteger yanzhengCode;

@property (nonatomic,copy) NSString *mimaStr;

@property (nonatomic,copy) NSString *requestClientNum;
@property (nonatomic,copy) NSString *requestClientPwd;

@property (nonatomic,strong) NSMutableDictionary *payParameterDic;//支付参数
@property (nonatomic,strong) NSMutableDictionary *payParameterDic2;//图文支付参数

@property (nonatomic,assign) PayType payType;

@property (nonatomic,assign) BOOL isCall;

@end

@implementation FKXMyOrderVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self headerRefreshEvent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"我的订单";
    self.view.backgroundColor = [UIColor whiteColor];
   
    [BeeCloud setBeeCloudDelegate:self];

    [self setUpNav];
    
    size = kRequestSize;
    
    userModel = [FKXUserManager getUserInfoModel];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FKXMyOrdersCell" bundle:nil] forCellReuseIdentifier:@"FKXMyOrdersCell"];
    
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    self.tableView.tableFooterView.frame = CGRectZero;
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    [self headerRefreshEvent];
}


#pragma mark - seperator insets 设置

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
    self.tableView.header.state = MJRefreshHeaderStateIdle;
    self.tableView.footer.state = MJRefreshFooterStateIdle;
    NSDictionary *paramDic = @{@"start":@(start),@"size":@(size)};
    
    NSString *urlStr;
    if (self.isWorkBench) {
        urlStr = @"listener/orderByListener";
    }else {
        urlStr = @"listener/orderByUser";
    }
    
    [FKXOrderModel sendGetOrPostRequest:urlStr param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             if ([data count] < kRequestSize) {
                 self.tableView.footer.hidden = YES;
             }else
             {
                 self.tableView.footer.hidden = NO;
             }
             if (start == 0)
             {
                 [self.tableData removeAllObjects];
                 if ([data count] == 0) {
                     [self createEmptyData];
                 }else{
                     if (emptyDataView) {
                         [emptyDataView removeFromSuperview];
                         emptyDataView = nil;
                     }
                     if (self.isWorkBench) {
                         FKXOrderModel *model = data[0];
                         [[FKXUserManager shareInstance]setUnAcceptOrderTime:model.createTime];
                     }
                 }
             }
             [self.tableData addObjectsFromArray:data];
             [self.tableView reloadData];
         } else if (errorModel)
         {
             [self showHint:errorModel.message];
             
         }
     }];
}

- (void)loadListenInfo:(FKXOrderModel *)model {
   
}


#pragma mark - 空数据
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        emptyDataView.btnDeal.hidden = YES;
        emptyDataView.titleLab.text = @"还没有订单";
        [self.tableView addSubview:emptyDataView];
    }
}
- (NSMutableDictionary *)payParameterDic {
    if (!_payParameterDic) {
        _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _payParameterDic;
}

#pragma mark - 操作订单（拒绝、接受）
- (void)operationOrder:(FKXOrderModel *)model status:(NSNumber *)status {
//    NSDictionary *params = @{@"orderId":model.orderId,@"type":model.type,@"status":status};

    NSNumber *type = @0;
    if (model.callLength && [model.callLength integerValue]!=0) {
        type = @1;
    }

    NSDictionary *params = @{@"orderId":model.orderId,@"type":type,@"status":status};
    
    [AFRequest sendGetOrPostRequest:@"listener/updateOrders" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue]==0) {
            model.status = status;
            [self.tableView reloadData];
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

#pragma mark - 电话咨询（已经付款）
- (void)toCall:(FKXOrderModel *)model btn:(UIButton *)btn {
    [self showHudInView:self.view hint:@""];
    
    proModel = [[FKXUserInfoModel alloc]init];
    if (self.isWorkBench) {
        proModel.uid = model.userId;
    }else {
        proModel.uid = model.listenerId;
    }
    proModel.mobile = model.mobile;
    proModel.status = model.isOnline;
    proModel.clientNum = model.clientNum;
    proModel.name = model.nickName;
    proModel.head = model.headUrl;
    proModel.phonePrice = model.phonePrice;
    
    NSString *callStr = [NSString stringWithFormat:@"%ld",[model.callLength integerValue] *60];
    [self call:callStr];

//    NSDictionary *parmas = @{};
//    if (!self.isWorkBench) {
//        parmas = @{@"userId":userModel.uid,@"listenerId":model.listenerId};
//    }else {
//        parmas = @{@"userId":userModel.uid,@"listenerId":model.userId};
//    }
//    [AFRequest sendPostRequestTwo:@"user/selectClient" param:parmas success:^(id data) {
//        [self hideHud];
//        if ([data[@"code"] integerValue] == 0) {
//            NSDictionary *dic = data[@"data"][@"listenerInfo"];
//            proModel = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];
//            NSString *callStr = [NSString stringWithFormat:@"%ld",[model.callLength integerValue] *60];
//            [self call:callStr];
//            
//        }else {
//            [self showHint:data[@"message"]];
//        }
//    } failure:^(NSError *error) {
//        [self hideHud];
//        [self showHint:@"网络出错"];
//    }];
}



- (void)call:(NSString *)callLength {
    [self tapHide4];
    [FKXCallOrder calling:callLength userModel:userModel proModel:proModel controller:self];
}

#pragma mark - 图文咨询（聊天页，已确认订单）
//去服务
- (void)toChatWithMessage:(FKXOrderModel *)model {
    if (!model.userId) {
        return;
    }
    
    if ([model.userId integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不可以私信自己哟"];
        return;
    }
    NSArray *textArray = @[@"亲，我来了~在伐开心里可以无压力的倾诉心事，安抚您内心的小怪兽",@"身为伐开心的倾听者，能够倾听帮助您解决烦心事是我义不容辞的责任~",@"您的烦心事尽管告诉我，我会尽我所能帮助您的",@"不开心？来伐开心，我都在这陪伴倾听着你",@"我在呢~每当您有烦心事我都会第一时间出现在您身边的"];
    NSInteger radom = arc4random()%textArray.count;
    NSString * welcomeMessage = textArray[radom];
    NSDictionary *dicExt = @{
                             @"head" : userModel.head,
                             @"name": userModel.name,
                             };
    NSDictionary *params = @{@"userId":userModel.uid,@"listenerId":model.userId};
    
    [AFRequest sendPostRequestTwo:@"user/selectClient" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSDictionary *dic = data[@"data"][@"listenerInfo"];
            FKXUserInfoModel *proM = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];
            
            //保存接收方的信息
            EMMessage *receiverMessage = [[EMMessage alloc] initWithReceiver:[proM.uid stringValue] bodies:nil];
            receiverMessage.from = [proM.uid stringValue];
            receiverMessage.to = [NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId];
            receiverMessage.ext = @{
                                    @"head" : proM.head,
                                    @"name": proM.name,
                                    };
            [self insertDataToTableWith:receiverMessage managedObjectContext:ApplicationDelegate.managedObjectContext];
            
            ChatViewController * chatController=[[ChatViewController alloc] initWithConversationChatter:[proM.uid stringValue]  conversationType:eConversationTypeChat];
            chatController.title = proM.name;
            chatController.pModel = proM;

            //对方是咨询师
            if ([proM.role integerValue] !=0) {
                chatController.toZiXunShi = YES;
                 NSArray *array = [[FKXUserManager shareInstance] caluteHeight:proM];
                chatController.headerH = [array[1] floatValue];
                chatController.introStr = array[0];
            }
            [EaseSDKHelper sendTextMessage:welcomeMessage to:[model.userId stringValue] messageType:eMessageTypeChat requireEncryption:NO messageExt:dicExt];

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
    NSDictionary *params = @{@"userId":userModel.uid,@"listenerId":model.listenerId};
  
    [AFRequest sendPostRequestTwo:@"user/selectClient" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSDictionary *dic = data[@"data"][@"listenerInfo"];
            proModel = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];

            //保存接收方的信息
            EMMessage *receiverMessage = [[EMMessage alloc] initWithReceiver:[proModel.uid stringValue] bodies:nil];
            receiverMessage.from = [proModel.uid stringValue];
            receiverMessage.to = [NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId];
            receiverMessage.ext = @{
                                    @"head" : proModel.head,
                                    @"name": proModel.name,
                                    };
            [self insertDataToTableWith:receiverMessage managedObjectContext:ApplicationDelegate.managedObjectContext];
            
            NSArray *array = [[FKXUserManager shareInstance] caluteHeight:proModel];
            ChatViewController * chatController=[[ChatViewController alloc] initWithConversationChatter:[proModel.uid stringValue]  conversationType:eConversationTypeChat];
            chatController.title = proModel.name;
            
            if ([proModel.role integerValue] !=0) {
                chatController.toZiXunShi = YES;
            }
            
            chatController.pModel = proModel;
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
        vc.type = @2;
    }else {
        vc.type = @1;
    }
    vc.model = noModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 去看评价
- (void)toCommenViewt:(FKXOrderModel *)model {
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"user_center_yu_yue";//预约
    vc.pageType = MyPageType_consult;
    vc.urlString = [NSString stringWithFormat:@"%@front/user_center.html?uid=%@&token=%@",kServiceBaseURL, userModel.uid, [FKXUserManager shareInstance].currentUserToken];
    vc.userModel = userModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 查看详情
- (void)toDetailVC:(FKXOrderModel *)model {
    FKXMyOderDetailVC *vc = [[FKXMyOderDetailVC alloc]initWithNibName:@"FKXMyOderDetailVC" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.isWorkBench = self.isWorkBench;
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 点击按钮
- (void)cancel:(UIButton *)btn {
    FKXOrderModel *model = self.tableData[btn.tag-2000];
    //拒绝订单
    [self operationOrder:model status:@3];
}

- (void)operation :(UIButton *)btn {
    FKXOrderModel *model = self.tableData[btn.tag-1000];
    if (self.isWorkBench) {
        if ([model.status integerValue] == 0){
            //确认订单
            [self operationOrder:model status:@1];
        }else if ([model.status integerValue] == 1){
            
//            if ([model.type integerValue]!=0) {
//                //电话咨询
//                [self toCall:model btn:btn];
//            }else {
//                //图文咨询
//                [self toTuWen:model];
//            }
            //去服务
            if (model.callLength && [model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:model btn:btn];
            }else {
                //图文咨询
                [self toChatWithMessage:model];
            }
        }else if ([model.status integerValue] == 2){
            //查看详情
            [self toDetailVC:model];
        }else if ([model.status integerValue] == 3){
            //查看详情
            [self toDetailVC:model];
        }else if ([model.status integerValue] == 4){
            //去看评价
            [self toCommenViewt:model];
        }
    }else{
        if ([model.status integerValue] == 0){
            //私信TA
            [self toChatVC:model];
        }else if ([model.status integerValue] == 1){
            //立即咨询
//            if ([model.type integerValue]!=0) {
//                //电话咨询
//                [self toCall:model btn:btn];
//            }else {
//                //图文咨询
//                [self toTuWen:model];
//            }
            if (model.callLength && [model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:model btn:btn];
            }else {
                //图文咨询
                [self toTuWen:model];
            }
        }else if ([model.status integerValue] == 2){
            //立即评价
            [self toComment:model];
        }else if ([model.status integerValue] == 3){
            //查看详情
            [self toDetailVC:model];
        }else if ([model.status integerValue] == 4){
            //再次预约
//            if ([model.type integerValue]!=0) {
//                //电话咨询
//                [self callOrder:model];
//            }else {
//                //图文咨询
//                [self tuwenOrder:model];
//            }
            if (model.callLength && [model.callLength integerValue]!=0) {
                //电话咨询
                [self callOrder:model];
            }else {
                //图文咨询
                [self tuwenOrder:model];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FKXOrderModel *model = self.tableData[indexPath.row];
    [self toDetailVC:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXOrderModel *model = self.tableData[indexPath.row];
    FKXMyOrdersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyOrdersCell" forIndexPath:indexPath];
    cell.isWorkBench = self.isWorkBench;
    cell.model = model;
    cell.operationBtn.tag = 1000+indexPath.row;
    [cell.operationBtn addTarget:self action:@selector(operation:) forControlEvents:UIControlEventTouchUpInside];
    cell.cancelBtn.tag = 2000+indexPath.row;
    [cell.cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSMutableArray *)tableData {
    if (!_tableData) {
        _tableData = [[NSMutableArray alloc]init];
    }
    return _tableData;
}
- (NSMutableArray *)proData {
    if (!_proData) {
        _proData = [[NSMutableArray alloc]init];
    }
    return _proData;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpNav {
    UIView *guizeV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 16)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 35, 15)];
    label.text = @"规则";
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = kColorMainBlue;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(2, 15, 31, 1)];
    line.backgroundColor = kColorMainBlue;
    
    [guizeV addSubview:label];
    [guizeV addSubview:line];
    
    [guizeV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guize)]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:guizeV];
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
        
        mindRemindV = [[[NSBundle mainBundle] loadNibNamed:@"OrderRegularV" owner:nil options:nil] firstObject];
        [mindRemindV.btnDone addTarget:self action:@selector(hiddentransViewRemind) forControlEvents:UIControlEventTouchUpInside];
        
        mindRemindV2 = [[[NSBundle mainBundle] loadNibNamed:@"FKXLisOrderV" owner:nil options:nil] firstObject];
        [mindRemindV2.btnClose addTarget:self action:@selector(hiddentransViewRemind) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.isWorkBench) {
            [transViewRemind addSubview:mindRemindV2];
        }else {
            [transViewRemind addSubview:mindRemindV];
        }
        
        mindRemindV.center = transViewRemind.center;
        mindRemindV2.center = transViewRemind.center;

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

    }];
}

#pragma mark - 下电话订单 （再次预约）
- (void)callOrder:(FKXOrderModel *)model {
    self.isCall = YES;
    proModel = [[FKXUserInfoModel alloc]init];
    proModel.uid = model.listenerId;
    proModel.mobile = model.mobile;
    proModel.status = model.isOnline;
    proModel.clientNum = model.clientNum;
    proModel.name = model.nickName;
    proModel.head = model.headUrl;
    proModel.phonePrice = model.phonePrice;
    
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
    
    if (userModel.mobile) {
        order.phoneStr = userModel.mobile;
    }
    
    if (userModel.clientNum && userModel.clientNum.length>0) {
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
//    NSDictionary *parmas = @{};
//    if (!self.isWorkBench) {
//        parmas = @{@"userId":userModel.uid,@"listenerId":model.listenerId};
//    }else {
//        parmas = @{@"userId":userModel.uid,@"listenerId":model.userId};
//    }
//    [AFRequest sendPostRequestTwo:@"user/selectClient" param:parmas success:^(id data) {
//        [self hideHud];
//        if ([data[@"code"] integerValue] == 0) {
//            NSDictionary *dic = data[@"data"][@"listenerInfo"];
//            proModel = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];
//            
//
//        }else {
//            [self showHint:data[@"message"]];
//        }
//    } failure:^(NSError *error) {
//        [self hideHud];
//        [self showHint:@"网络出错"];
//    }];
    
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
    if (userModel.mobile) {
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
    
    if (!userModel.clientNum && !self.requestClientNum) {
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
}



- (void)loadCallLength {
    NSDictionary *params = @{@"userId":userModel.uid,@"listenerId":proModel.uid};
    [AFRequest sendPostRequestTwo:@"listener/allow_call_length" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSInteger callNum = [data[@"data"][@"length"] integerValue];
            
            lianjie = [FKXLianjieView creatZaiXian];
            lianjie.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
            lianjie.delegate = self;
            lianjie.lisId = proModel.uid;
            lianjie.callLength = [NSString stringWithFormat:@"%ld",callNum*60];
            lianjie.head = proModel.head;
            lianjie.name = proModel.name;
            
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
    if ([proModel.status integerValue]==1) {
        [self loadCallLength];
    }else {
        lixian = [FKXLiXianView creatLiXian];
        lixian.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
        lixian.head = proModel.head;
        lixian.name = proModel.name;
        lixian.lisId = proModel.uid;
        lixian.delegate = self;
        if ([proModel.status integerValue]==0) {
            lixian.statusL.text = @" 离线 ";
        }else if([proModel.status integerValue]==2) {
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
    
    if (userModel.mobile) {
        [dic setObject:userModel.mobile forKey:@"mobile"];
        [dic setObject:@(5) forKey:@"type"];
        
    }else {
        [dic setObject:userModel.mobile forKey:@"mobile"];
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
    else if (!userModel.mobile && [NSString isEmpty:secret])
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
    }    //开始申请client
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
    if (!userModel.mobile) {
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
                }else {
                    [self headerRefreshEvent];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
