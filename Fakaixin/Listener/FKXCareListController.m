//
//  FKXCareListController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/25.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXCareListController.h"
#import "FKXCareListCell.h"
#import "FKXSameMindModel.h"
#import "NSString+HeightCalculate.h"
#import "FKXCareDetailController.h"
#import "CareRemindView.h"
#import "FKXProfessionInfoVC.h"
#import "FKXPublishCourseController.h"
#import "FKXBindPhone.h"

#import "NSString+Extension.h"

#define kFontOfContent 15
#define kMarginXTotal 62    //cell的边距加上textView的内边距 12 + 12 + 19 + 19
#define kLineSpacing 8  //段落的行间距
#define kTextVTopInset 12  //textV 的内容上下inset

@interface FKXCareListController ()<protocolFKXCareListCell,BindPhoneDelegate>
{
    NSInteger start;
    NSInteger size;
    CGFloat oneLineH;//一行的高度
    
    FKXEmptyData *emptyDataView;//空数据
    
    UIView *transViewRemind;//透明图
    CareRemindView *mindRemindV;//每日提醒界面
    UIButton *beginRefreshBtn;
    BOOL animating;//是否展示刷新按钮的动画
    BOOL showCellAni;//是否展示cell的动画（规则：只有当点击刷新按钮才展示cell的动画；其余均不展示）
    
    FKXUserInfoModel *userModel;
    
    FKXBindPhone *phone;
    UIView *view2;
    
    NSInteger times;
    NSTimer * timer;
}
@property   (nonatomic,strong)NSMutableArray *contentArr;

@property (nonatomic,strong) NSNumber *timeNum;

@property (nonatomic,assign) NSInteger status;

@property (nonatomic,assign) NSInteger yanzhengCode;

@property (nonatomic,copy) NSString *requestClientNum;
@property (nonatomic,copy) NSString *requestClientPwd;

@property (nonatomic,copy) NSString *mimaStr;

@end

@implementation FKXCareListController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    beginRefreshBtn.hidden = NO;

//    [self setUpNavBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"voiceReplySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bangdingPhone" object:nil];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    beginRefreshBtn.hidden = YES;
    showCellAni = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //基本数据赋值
    showCellAni = YES;
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = 4;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceReplySuccess) name:@"voiceReplySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bangdingPhone) name:@"bangdingPhone" object:nil];

    self.navTitle = @"关怀列表";
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = kLineSpacing;
    oneLineH = [@"哈" heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:nil];
    
    //ui设置
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //每日提醒
    [self setUptransViewRemind];
    
    //ui创建
    [self createbeginRefreshBtn];
    
    //创建bariten
    [self setUpNavBar];
    
    //第一次初始化界面的时候置为0，表明从第0页开始
//    [FKXUserManager shareInstance].noReadOrder = self.timeNum;
    [self headerRefreshEvent];
    //刚一开始进来，请求最新的之后，记录这个最初的时间，在下次点击刷新按钮的时候使用
    NSString *time = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]];
    NSTimeInterval timeInter = [time integerValue]*1000;
    [FKXUserManager shareInstance].noReadOrder = @(timeInter);
}

- (void)setUpNavBar {
    
    //请求在线状态
    UIButton *sendB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 18)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"申请课程" attributes:@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],NSForegroundColorAttributeName : UIColorFromRGB(0x333333), NSFontAttributeName : [UIFont systemFontOfSize:13]}];
    [sendB setAttributedTitle:str forState:UIControlStateNormal];
    [sendB addTarget:self action:@selector(beginApply) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendB];
    
    
    UIButton *statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    statusBtn.frame = CGRectMake(0, 0, 60, 44);
    
    [statusBtn setImage:[UIImage imageNamed:@"img_status_live"] forState:UIControlStateNormal];
    [statusBtn setImage:[UIImage imageNamed:@"img_status_on"] forState:UIControlStateSelected];
    [statusBtn addTarget:self action:@selector(changStatus:) forControlEvents:UIControlEventTouchUpInside];
   
    NSDictionary *params = @{};
    [AFRequest sendGetOrPostRequest:@"listener/select_status" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0){
            _status = [data[@"data"] integerValue];
            if (_status == 0) {
                statusBtn.selected = NO;
            }else {
                statusBtn.selected = YES;
            }
        }else{
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:statusBtn];

}


- (void)bangdingPhone {
    
    userModel = [FKXUserManager getUserInfoModel];
    
    phone = [FKXBindPhone creatBangDing];
    phone.frame = CGRectMake(0, 0, 235, 345);
    CGPoint center = self.view.center;
    center.y = center.y - 20;
    phone.center = center;
    phone.bindPhoneDelegate = self;
    
    //已经绑定手机号，无需再设置密码
    if (![NSString isEmpty:userModel.mobile]) {
        phone.phoneStr = userModel.mobile;
        phone.pwdTF.hidden = YES;
    }
    
    view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    [view2 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide2)]];
    
    view2.alpha = 0;
    phone.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:view2];
    [[UIApplication sharedApplication].keyWindow addSubview:phone];
    
    [UIView animateWithDuration:0.5 animations:^{
        view2.alpha = 1;
        phone.alpha = 1;
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
    if(secret) {
        self.mimaStr = [NSString md532BitUpper:secret];
    }
    //开始申请client
    [self requsetClient];
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
             
         }else{
             [self showHint:data[@"message"]];
         }
         [self hideHud];
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
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
#pragma mark - nav 点击

- (void)beginApply
{
    FKXPublishCourseController *vc = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil]instantiateViewControllerWithIdentifier:@"FKXPublishCourseController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changStatus:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
       NSDictionary *params = @{@"status":@1};
        [AFRequest sendGetOrPostRequest:@"listener/update_status" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
            [self hideHud];
            if ([data[@"code"] integerValue] == 0){
                _status = [data[@"data"] integerValue];
                btn.selected = YES;
            }else{
                [self showHint:data[@"message"]];
            }
        } failure:^(NSError *error) {
            [self showHint:@"网络出错"];
            [self hideHud];
}];
    }else {
        NSDictionary *params = @{@"status":@0};
        [AFRequest sendGetOrPostRequest:@"listener/update_status" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
            [self hideHud];
            if ([data[@"code"] integerValue] == 0){
                _status = [data[@"data"] integerValue];
                btn.selected = NO;
            }else{
                [self showHint:data[@"message"]];
            }
        } failure:^(NSError *error) {
            [self showHint:@"网络出错"];
            [self hideHud];
        }];
    }
    
  
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 刷新按钮
- (void)createbeginRefreshBtn
{
    UIImage *image = [UIImage imageNamed:@"img_care_list_refresh_bac_normal"];
    UIImage *imageS = [UIImage imageNamed:@"img_care_list_refresh_bac_selected"];
    UIImage *ima = [UIImage imageNamed:@"img_care_list_refresh_normal"];
    UIImage *imaS = [UIImage imageNamed:@"img_care_list_refresh_selected"];
    beginRefreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    beginRefreshBtn.frame = CGRectMake(self.view.width - image.size.width - 12, self.view.height - image.size.height - 30 - 60, image.size.width, image.size.height);
    [beginRefreshBtn setBackgroundImage:imageS forState:UIControlStateSelected];
    [beginRefreshBtn setBackgroundImage:image forState:UIControlStateNormal];
    [beginRefreshBtn setImage:ima forState:UIControlStateNormal];
    [beginRefreshBtn setImage:imaS forState:UIControlStateSelected];
    [beginRefreshBtn addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:beginRefreshBtn];
}
- (void)beginRefresh:(UIButton *)butt
{
    showCellAni = YES;
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveLinear];
    }
    butt.selected = YES;
    [self headerRefreshEvent];
    
    NSString *time = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]];
    NSTimeInterval timeInter = [time integerValue]*1000;
    [FKXUserManager shareInstance].noReadOrder = @(timeInter);
}
- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}
- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         beginRefreshBtn.transform = CGAffineTransformRotate(beginRefreshBtn.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             }
                         }
                     }];
}
#pragma  mark - 每日提醒
- (void)setUptransViewRemind
{
    NSDate *date = [NSDate date];
    NSString *dateS = [date.description substringToIndex:10];
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@CareList", dateS]];
    if (!key) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"%@CareList", dateS]];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (!transViewRemind)
        {
            //透明背景
            transViewRemind = [[UIView alloc] initWithFrame:screenBounds];
            transViewRemind.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            transViewRemind.alpha = 0.0;
            [[UIApplication sharedApplication].keyWindow addSubview:transViewRemind];
            
            mindRemindV = [[[NSBundle mainBundle] loadNibNamed:@"CareRemindView" owner:nil options:nil] firstObject];
            [mindRemindV.btnDone addTarget:self action:@selector(hiddentransViewRemind) forControlEvents:UIControlEventTouchUpInside];
            [transViewRemind addSubview:mindRemindV];
            mindRemindV.center = transViewRemind.center;
            [UIView animateWithDuration:0.5 animations:^{
                transViewRemind.alpha = 1.0;
            }];
        }
    }
}
- (void)hiddentransViewRemind
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewRemind.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewRemind removeFromSuperview];
        transViewRemind = nil;
        NSString *imageName = @"user_guide_refresh";
        [FKXUserManager showUserGuideWithKey:imageName];
    }];
}
#pragma mark - UI 创建
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        [emptyDataView.btnDeal addTarget:self action:@selector(clickBtnDeal) forControlEvents:UIControlEventTouchUpInside];
        emptyDataView.titleLab.text = @"还没有人发心事";
        [emptyDataView.btnDeal setTitle:@"获得更多曝光" forState:UIControlStateNormal];
        [self.tableView addSubview:emptyDataView];
    }
}
- (void)clickBtnDeal
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - ---网络请求---
- (void)voiceReplySuccess
{
    start -= size;//当用户加载数据成功后，start会 ＋＝ size，但回复成功后还是需要刷新当前页，
    [self loadData];
}
- (void)headerRefreshEvent
{
    
    [self loadData];
}
- (void)loadData
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setObject:@(start) forKey:@"start"];
    [paramDic setObject:@(4) forKey:@"size"];
    if (!self.timeNum) {
        [paramDic setObject:@(0) forKey:@"time"];
    }else {
        [paramDic setObject:self.timeNum forKey:@"time"];

    }
    
//    if ([[FKXUserManager shareInstance].noReadOrder integerValue]) {
//        [paramDic setObject:[FKXUserManager shareInstance].noReadOrder forKey:@"time"];
//    }
    [FKXSameMindModel sendGetOrPostRequest:@"worry/worryList" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         beginRefreshBtn.selected = NO;
         //停止“刷新按钮”的动画
         [self stopSpin];
         
         NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
         NSTimeInterval a=[dat timeIntervalSince1970]*1000;
         NSString *timeString = [NSString stringWithFormat:@"%f", a];
         self.timeNum = [NSNumber numberWithInteger:[timeString integerValue]];

         if (data)
         {
             if (_contentArr.count) {//如果原来就有数据，就先移除再加载新的
                 NSInteger count = _contentArr.count;//_coutentArr的个数会随着remove而减少，所以要记录count
                 
                 if (showCellAni)
                 {
                     for (int i = 0; i < count; i++) {//移除老的数据
                         [_contentArr removeObjectAtIndex:0];
                         [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
                             [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                             
                         } completion:^(BOOL finished) {
                             if (i == count - 1) {//将之前老的都移除之后，加载新的列表
                                 [_contentArr addObjectsFromArray:data];
                                 [self.tableView reloadData];
                             }
                         }];
                         
                     }
                 }
                 else
                 {
                     [_contentArr removeAllObjects];
                     [_contentArr addObjectsFromArray:data];
                     [self.tableView reloadData];
                 }
             }else{
                 [_contentArr addObjectsFromArray:data];
                 [self.tableView reloadData];
             }
             if ([data count] == 0)
             {
                 if (start == 0) {//需要创建空数据
                     [self createEmptyData];
                 }else
                 {
                     //循环了一圈，从头开始循环
                     start = 0;
                     [FKXUserManager shareInstance].noReadOrder = @(0);
                     [self headerRefreshEvent];
                     NSString *time = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]];
                     NSTimeInterval timeInter = [time integerValue]*1000;
                     [FKXUserManager shareInstance].noReadOrder = @(timeInter);
                 }
             }else{
                 start += size;
                 if (emptyDataView) {
                     [emptyDataView removeFromSuperview];
                     emptyDataView = nil;
                 }
             }
             if (start == 0) {
                 for (FKXSameMindModel *model in data) {
                     [FKXUserManager shareInstance].noReadOrder = model.worryId;
                     break;
                 }
             }
             start += size;
         }else if (errorModel)
         {
             NSInteger index = [errorModel.code integerValue];
             if (index == 4)
             {
                 [self showAlertViewWithTitle:errorModel.message];
                 [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
             }else
             {
                 [self showHint:errorModel.message];
             }
         }
     }];
}
#pragma mark - 协议
- (void)goToDynamicVC:(FKXSameMindModel*)cellModel sender:(UIButton*)sender
{
    if ([cellModel.isPublic integerValue] || [FKXUserManager shareInstance].currentUserId == [cellModel.uid integerValue]) {
        FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
        vc.userId = cellModel.uid;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - tableView代理
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showCellAni) {
        CGPoint point = cell.center;
        switch (indexPath.row) {
            case 0:
            {
                cell.center = CGPointMake(-cell.width*3/2, point.y);
                [UIView animateWithDuration:1 delay:0.2 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                    cell.center = CGPointMake(cell.width/2, cell.center.y);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
            case 1:
            {
                cell.center = CGPointMake(-cell.width*3/2, point.y);
                [UIView animateWithDuration:1 delay:0.4 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                    cell.center = CGPointMake(cell.width/2, cell.center.y);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
            case 2:
            {
                cell.center = CGPointMake(-cell.width*3/2, point.y);
                [UIView animateWithDuration:1 delay:0.7 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                    cell.center = CGPointMake(cell.width/2, cell.center.y);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
            case 3:
            {
                cell.center = CGPointMake(-cell.width*3/2, point.y);
                [UIView animateWithDuration:1 delay:1.1 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                    cell.center = CGPointMake(cell.width/2, cell.center.y);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
                
            default:
                break;
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSameMindModel *model = _contentArr[indexPath.row];
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = kLineSpacing;
    CGFloat height = [model.text heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    CGFloat heightA = oneLineH*3 + kLineSpacing*2;
    if (height > heightA)//文字高度大于3行
    {
        CGFloat heightB = oneLineH*3 + kLineSpacing*2 + 103 + kTextVTopInset*2;
        return heightB;
    }else{
        CGFloat heightC = height + 103 + kTextVTopInset*2;
        return heightC;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSameMindModel *model = _contentArr[indexPath.row];
    FKXCareListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXCareListCell" forIndexPath:indexPath];// forIndexPath加上跟不加，都不会崩溃
    cell.delegate = self;
    cell.model = model;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSameMindModel *model = _contentArr[indexPath.row];
    FKXCareDetailController *vc = [[UIStoryboard storyboardWithName:@"FKXCare" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXCareDetailController"];
    [vc setHidesBottomBarWhenPushed:YES];
    vc.careDetailType = care_detail_type_mind;
    vc.sameModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
