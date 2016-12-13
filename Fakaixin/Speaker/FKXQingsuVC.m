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

#import "FKXScrTitelModel.h"

#import "FKXProfessionInfoVC.h"

#import "ChatViewController.h"

#import "FKXCallOrder.h"

typedef enum : NSUInteger {
    PayType_weChat,
    PayType_Ali,
} PayType;

@interface FKXQingsuVC ()<UITableViewDelegate,UITableViewDataSource,CallProDelegate,ConfirmDelegate,BindPhoneDelegate,BeeCloudDelegate,CallDelegate,LixianDelegate>
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
    FKXUserInfoModel *userModel;

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
@property (nonatomic,strong)NSMutableArray *arr;

@property (nonatomic , retain) CycleScrollView *mainScorllView;

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,copy) NSString *mimaStr;
@property (nonatomic,assign) NSInteger yanzhengCode;

@property (nonatomic,copy) NSString *requestClientNum;
@property (nonatomic,copy) NSString *requestClientPwd;

@property (nonatomic,strong) NSMutableDictionary *payParameterDic;//支付参数
@property (nonatomic,assign) PayType payType;


//一键咨询需要的参数
@property (nonatomic,assign) BOOL isKeyTalk;

@property (nonatomic,copy) NSString *callStr;
@property (nonatomic,strong) NSNumber *listenerId;
@property (nonatomic,copy) NSString *pMobile;

@end

@implementation FKXQingsuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navTitle = @"一键咨询";
    self.view.backgroundColor = [UIColor whiteColor];
    userModel = [FKXUserManager getUserInfoModel];
    
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
    _isKeyTalk = YES;
    
    if (_contentArr.count >0) {
        FKXUserInfoModel *model = _contentArr[0];
        [self callPro:model];
    }
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
    
    [AFRequest sendPostRequestTwo:@"user/confide" param:paramDic success:^(id data) {
        [self hideHud];
        self.tableView.header.state = MJRefreshHeaderStateIdle;
        self.tableView.footer.state = MJRefreshFooterStateIdle;
        
        NSArray *listArr = data[@"data"][@"listenerList"];
        NSArray *dyArr = data[@"data"][@"dynamicVOList"];

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
        
        if (dyArr) {
            [self.viewArr removeAllObjects];
            for (NSDictionary *dic in dyArr) {
                FKXScrTitelModel * officalSources =  [[FKXScrTitelModel alloc] initWithDictionary:dic error:nil];
                [self.viewArr addObject:officalSources];
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
    
    if (self.viewArr.count !=0) {
        
        if (self.viewArr.count == 1){
            FKXScrTitelModel *model = self.viewArr[0];
            self.arr = [@[model,model,model,model] mutableCopy];
        }else if(self.viewArr.count == 2) {
            FKXScrTitelModel *model1 = self.viewArr[0];
            FKXScrTitelModel *model2 = self.viewArr[1];
            self.arr = [@[model1,model2,model1,model2] mutableCopy];
        }else {
            self.arr = self.viewArr;
        }
       
        int j = (int)(self.arr.count +2-1)/2 ;
        
    for (int i = 1; i <= j; i++) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(64, 0, kScreenWidth-56, 98)];
        for (int z=(i-1)*2; z<i*2; z++) {
            if (z<self.arr.count) {
                FKXScrTitelModel *tiModel = self.arr[z];
                if (z%2==0) {
                    ScrllTitleView *scrV1 = [ScrllTitleView creatTitleView];
                    scrV1.frame = CGRectMake(0, 0, kScreenWidth-56, 49);
                    scrV1.tag = z+1000;
                    [scrV1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScr:)]];
                    scrV1.nameL.text = [NSString stringWithFormat:@"%@***",[tiModel.fromNickname substringToIndex:1]];
                    scrV1.name2L.text = tiModel.toNickname;
                    switch ([tiModel.type integerValue]) {
                        case 1:
                            scrV1.label1.text = @"向";
                            scrV1.label2.text = @"提问";
                            break;
                        case 2:
                            scrV1.label1.text = @"购买了";
                            scrV1.label2.text = @"图文咨询";
                            break;
                        case 3:
                            scrV1.label1.text = @"购买了";
                            scrV1.label2.text = @"电话服务";
                            break;
                        case 4:
                            scrV1.label1.text = @"给了";
                            scrV1.label2.text = @"一个评价";
                            break;
                        default:
                            break;
                    }
                    [view addSubview:scrV1];
                    
                }else {
                    ScrllTitleView *scrV2 = [ScrllTitleView creatTitleView];
                    scrV2.frame = CGRectMake(0, 49, kScreenWidth-56, 49);
                    scrV2.tag = z+1000;
                    [scrV2 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScr:)]];
                    scrV2.nameL.text = [NSString stringWithFormat:@"%@***",[tiModel.fromNickname substringToIndex:1]];
                    scrV2.name2L.text = tiModel.toNickname;
                    switch ([tiModel.type integerValue]) {
                        case 1:
                            scrV2.label1.text = @"向";
                            scrV2.label2.text = @"提问";
                            break;
                        case 2:
                            scrV2.label1.text = @"购买了";
                            scrV2.label2.text = @"图文咨询";
                            break;
                        case 3:
                            scrV2.label1.text = @"购买了";
                            scrV2.label2.text = @"电话服务";
                            break;
                        case 4:
                            scrV2.label1.text = @"给了";
                            scrV2.label2.text = @"一个评价";
                            break;
                        default:
                            break;
                    }
                    [view addSubview:scrV2];
                }
            }
        }
        [viewsArray addObject:view];
    }

    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(64, 0, 288, 98) animationDuration:2.5];
    self.mainScorllView.backgroundColor = [[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1] colorWithAlphaComponent:0.1];

    self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    self.mainScorllView.totalPagesCount = ^NSInteger(void){
        return viewsArray.count;
    };
    
    [view addSubview:self.mainScorllView];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FKXUserInfoModel *pModel = _contentArr[indexPath.row];
    if (!pModel.uid) {
        return;
    }
    
    if ([pModel.uid integerValue] == [FKXUserManager shareInstance].currentUserId) {
        [self showHint:@"不可以私信自己哟"];
        return;
    }
    
    //保存接收方的信息
    
    //保存接收方的信息
    EMMessage *receiverMessage = [[EMMessage alloc] initWithReceiver:[professionModel.uid stringValue] bodies:nil];
    receiverMessage.from = [professionModel.uid stringValue];
    receiverMessage.to = [NSString stringWithFormat:@"%ld",[FKXUserManager shareInstance].currentUserId];
    receiverMessage.ext = @{
                            @"head" : professionModel.head,
                            @"name": professionModel.name,
                            };
    [self insertDataToTableWith:receiverMessage managedObjectContext:ApplicationDelegate.managedObjectContext];
    
    NSArray *array = [[FKXUserManager shareInstance] caluteHeight:pModel];
    ChatViewController * chatController=[[ChatViewController alloc] initWithConversationChatter:[pModel.uid stringValue]  conversationType:eConversationTypeChat];
    chatController.title = pModel.name;
    
    if ([pModel.role integerValue] !=0) {
        chatController.toZiXunShi = YES;
    }
    
    chatController.pModel = pModel;
    chatController.headerH = [array[1] floatValue];
    chatController.introStr = array[0];
    
    chatController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatController animated:YES];
    
}

#pragma mark - 进入专家个人页
- (void)tapScr:(UITapGestureRecognizer *)tap {
    FKXScrTitelModel *tiModel = self.arr[tap.view.tag-1000];
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = tiModel.toId;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
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

- (NSMutableArray *)arr {
    if (!_arr) {
        _arr = [NSMutableArray arrayWithCapacity:1];
    }
    return _arr;
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
    
    if (_isKeyTalk) {
        if (!proModel.mobile || [NSString isEmpty:proModel.mobile] ||[NSString isEmpty:proModel.clientNum]) {
            [self showHint:@"匹配失败"];
            return;
        }
    }else {
        if (!proModel.mobile || [NSString isEmpty:proModel.mobile] ||[NSString isEmpty:proModel.clientNum]) {
            [self showHint:@"该咨询师暂未开通电话咨询服务"];
            return;
        }
        
        if ([proModel.uid integerValue] == [FKXUserManager shareInstance].currentUserId) {
            [self showHint:@"不能咨询自己"];
            return;
        }
    }
    
    order = [FKXConfirmView creatOrder];
    order.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
    order.confirmDelegate = self;
    
    if (_isKeyTalk) {
        order.price = 25;
        //    order.head = ;
        order.isTalk = YES;
        order.name = @"推荐专家";
        order.status = @1;
        //    order.listenerId = proModel.uid;
    }else {
        order.price = [proModel.phonePrice integerValue]/100;
        order.head = proModel.head;
        order.name = proModel.name;
        order.status = proModel.status;
        order.listenerId = proModel.uid;
    }
    
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
    
    if (_isKeyTalk) {
        
        [dic setObject:totals forKey:@"price"];
        [dic setObject:time forKey:@"phoneTime"];
        self.callStr = [time stringValue];
        //    NSDictionary *paramDic = @{@"listenerId":listenerId,@"price":totals,@"phoneTime":time};
        
        [self showHudInView:self.view hint:@"正在提交..."];
        [AFRequest sendGetOrPostRequest:@"sys/aKeyTalk" param:dic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
         {
             [self hideHud];
             if ([data[@"code"] integerValue] == 0)
             {
                 self.listenerId = data[@"data"][@"listenerId"];
                 [self.payParameterDic setObject:data[@"data"][@"billNo"] forKey:@"billNo"];
                 CGFloat money = [data[@"data"][@"money"] floatValue];
                 [self.payParameterDic setObject:[NSNumber numberWithFloat:money] forKey:@"money"];
//                 NSInteger isAmple = [data[@"data"][@"isAmple"] integerValue];
//                 [self.payParameterDic setObject:[NSNumber numberWithInteger:isAmple] forKey:@"isAmple"];
                 [self confirmToPay];
             }else
             {
                 [self showHint:data[@"message"]];
                 
             }
         } failure:^(NSError *error) {
             [self hideHud];
             [self showHint:@"网络出错"];
         }];
    }else {
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

- (void)loadCallLength {
    NSDictionary *params = @{@"userId":userModel.uid,@"listenerId":professionModel.uid};
    [AFRequest sendPostRequestTwo:@"listener/allow_call_length" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSInteger callNum = [data[@"data"][@"length"] integerValue];
            [self showZaiXian:professionModel callNum:callNum];
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

- (void)loadProInfo:(NSNumber *)listenerId {
    NSDictionary *params = @{@"userId":[FKXUserManager getUserInfoModel].uid,@"listenerId":listenerId};
    
    [AFRequest sendPostRequestTwo:@"user/selectClient" param:params success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0) {
            NSDictionary *dic = data[@"data"][@"listenerInfo"];
            FKXUserInfoModel *pModel = [[FKXUserInfoModel alloc]initWithDictionary:dic error:nil];
            self.pMobile = pModel.mobile;
            if ([pModel.status integerValue] == 1) {
                [self showZaiXian:pModel callNum:[self.callStr integerValue]];
            }else {
                [self showLiXian:pModel];
            }
            
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
    
    if ([professionModel.status integerValue]==1) {
        [self loadCallLength];
    }else {
        [self showLiXian:professionModel];
    }
    
//    if (_isKeyTalk) {
//        [self loadProInfo:self.listenerId];
//    }else {
//        if ([professionModel.status integerValue]==1) {
//            [self loadCallLength];
//        }else {
//            [self showLiXian:professionModel];
//        }
//
//    }
    
}

- (void)showZaiXian:(FKXUserInfoModel *)proModel callNum:(NSInteger)callNum{
    lianjie = [FKXLianjieView creatZaiXian];
    lianjie.frame = CGRectMake(0, kScreenHeight-285, kScreenWidth, 285);
    lianjie.delegate = self;
    lianjie.callLength = [NSString stringWithFormat:@"%ld",callNum*60];
    lianjie.head = proModel.head;
    lianjie.name = proModel.name;
    lianjie.lisId = proModel.uid;
    
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
}

- (void)showLiXian:(FKXUserInfoModel *)proModel {
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
    self.mimaStr = [NSString md532BitUpper:secret];
    
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
    if (!uid) {
        return;
    }
    [self clickHead:uid];
}

- (void)toHead:(NSNumber *)uid {
    [self tapHide4];
    if (!uid) {
        return;
    }
    [self clickHead:uid];
}

- (void)clickHead:(NSNumber *)listenId {
    [self tapHide];
    if (!listenId) {
        return;
    }
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

#pragma mark - 电话回拨
- (void)call:(NSString *)callLength {
    [self tapHide4];
    
    [FKXCallOrder calling:callLength userModel:userModel proModel:professionModel controller:self];
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
