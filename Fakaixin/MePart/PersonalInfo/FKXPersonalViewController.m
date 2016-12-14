//
//  FKXPersonalViewController.m
//  Fakaixin
//
//  Created by Connor on 10/10/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXPersonalViewController.h"
#import "FKXOpenSecondAskController.h"
#import "FKXSetTableViewController.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXMyAskListPageVC.h"
#import "FKXMyAnswerPageVC.h"
#import "FKXChatListController.h"
#import "FKXAboutMeVC.h"
#import "FKXMyShopVC.h"
#import "FKXProfessionInfoVC.h"

#import "FKXMineDetailVC.h"

#import "FKXMyLoveValueController.h"

#import "FKXSignInView.h"
#import "STypeSignInView.h"
#import "FKXSignInVC.h"

#import "FKXMyOrderVC.h"

#import "FKXZiXunShiV.h"

@interface FKXPersonalViewController ()
{
    FKXUserInfoModel *userModel;
    UIView *changePatternBacView;
    UIImageView *rotateImageView;
    NSInteger noReadNum;
    UILabel *newMessageLab;
    
    UIView *transViewSignIn;   //透明图
    NSInteger numToClean;//多少天清空
    FKXSignInView *signView;//签到总图
    STypeSignInView *sTypeView;//s型图
    NSInteger daysSignIn;//签到天数,传给s型图
    
    UIView *transViewPay;   //透明图
    FKXZiXunShiV *payView;    //界面
}
@property (weak, nonatomic) IBOutlet UILabel *labUserName;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenAsk;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UIView *viewAboutMe;
@property (weak, nonatomic) IBOutlet UIImageView *iconAboutMe;
@property (weak, nonatomic) IBOutlet UIButton *numAboutMe;

//排行
@property (weak, nonatomic) IBOutlet UIImageView *paiHangImgV;
@property (weak, nonatomic) IBOutlet UIView *lineV;
@property (weak, nonatomic) IBOutlet UILabel *paiMing;
@property (weak, nonatomic) IBOutlet UIImageView *downImgV;
@property (weak, nonatomic) IBOutlet UIImageView *upImgV;
@property (weak, nonatomic) IBOutlet UILabel *bLabel;
@property (weak, nonatomic) IBOutlet UILabel *zLabel;

@property (weak, nonatomic) IBOutlet UILabel *bangzhuL;
@property (weak, nonatomic) IBOutlet UILabel *zanL;

//上升下降名次
@property (weak, nonatomic) IBOutlet UILabel *downCount;
@property (weak, nonatomic) IBOutlet UILabel *upCount;

//点击区域
@property (weak, nonatomic) IBOutlet UIView *tapV1;

@property (weak, nonatomic) IBOutlet UIView *tapV2;

@property (nonatomic,strong)UIBarButtonItem *left;
@property (nonatomic,strong)UIBarButtonItem *left2;

@property (nonatomic,strong) UIView *qianDaoView;
@property (nonatomic,strong) UIView *yiQianDaoView;

//点击区域

@end

@implementation FKXPersonalViewController

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    // Initialization code
//    [self.paiHangImgV addSubview:self.lineV];
//}


-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    
  
    if (![FKXUserManager needShowLoginVC]) {//每次界面出现都要调用，刷新界面
        
        [self loadInfo];
       
        
    }
    
    //关怀模式不需要加消息
    if ([FKXUserManager isUserPattern]) {
        [self setUpNavigationBar];
    }
    
    NSString *imageName = @"user_guide_to_listener";
    [FKXUserManager showUserGuideWithKey:imageName];
    if ([FKXUserManager isUserPattern]) {
        [_btnOpenAsk setTitle:@"切换至关怀模式" forState:UIControlStateNormal];
        _btnOpenAsk.backgroundColor = kColorMainBlue;
    }else{
        [_btnOpenAsk setTitle:@"切换至倾诉模式" forState:UIControlStateNormal];
        _btnOpenAsk.backgroundColor = kColorMainRed;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _redViewAsk.hidden = YES;
    _redViewAnswer.hidden = YES;
    
//    self.qianDaoView.hidden = YES;
//    self.yiQianDaoView.hidden = YES;

}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccessAndNeedRefreshAllUI object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QianDaoBack object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginOutNoSign" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FirstEditBackShare" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fkxReceiveEaseMobMessage" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //收到环信消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewMessageLab) name:@"fkxReceiveEaseMobMessage" object:nil];
    //ui赋值
    self.navTitle = @"我";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessAndNeedRefreshAllUI:) name:kNotificationLoginSuccessAndNeedRefreshAllUI object:nil];
    //签到
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpsignIn) name:QianDaoBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutNoSign) name:@"loginOutNoSign" object:nil];

    //第一次编辑资料分享
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView) name:@"FirstEditBackShare" object:nil];

    //添加手势
    [_viewAboutMe addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToAboutMeVC)]];
    [self.tableView.tableHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToEditInfo)]];
    
    [_tapV1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToBangZhuVC)]];
    [_tapV2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToZanVC)]];

    
    
    //需要登录
    if ([FKXUserManager needShowLoginVC]) {
        [self setUpDataToSubviews];
    }
    //关怀模式不需要加消息
    if ([FKXUserManager isUserPattern]) {
        [self setUpNavigationBar];
    }
    
    [self loadTheAnimationView];
    //为了在程序启动后调用一次需要写在viewdidload里边
    if (![FKXUserManager needShowLoginVC]) {
        [self loadInfo];
    }
   
    //签到
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.qianDaoView];
    
    NSString *guideKey =[NSString stringWithFormat:@"user_guide_book_listener%@", AppVersionBuild];
    
//    [self setUpsignIn];
 
    if ([[NSUserDefaults standardUserDefaults] stringForKey:guideKey]) {
        //加载用户是否签到
        if (![FKXUserManager needShowLoginVC]) {
            [self setUpsignIn];
        }
    }

}

- (UIBarButtonItem *)left {
    if (!_left) {
        _left =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:nil];
    }
    return _left;
}
- (UIBarButtonItem *)left2 {
    if (!_left2) {
        _left2 =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:nil];
    }
    return _left2;
}

- (UIView *)qianDaoView {
    if (!_qianDaoView) {
        _qianDaoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 20)];
        UIImageView *imgV1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        UIImageView *imgV2 = [[UIImageView alloc]initWithFrame:CGRectMake(25, 2, 30, 16)];
        imgV1.image = [UIImage imageNamed:@"qianDao_no1"];
        imgV2.image = [UIImage imageNamed:@"qianDao_no2"];
        [_qianDaoView addSubview:imgV1];
        [_qianDaoView addSubview:imgV2];
        _qianDaoView.hidden = NO;
        [_qianDaoView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signInClick)]];
    }
    return _qianDaoView;
}

- (UIView *)yiQianDaoView {
    if (!_yiQianDaoView) {
        
        _yiQianDaoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 20)];
        UIImageView *imgV1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2, 20, 16)];
        UIImageView *imgV2 = [[UIImageView alloc]initWithFrame:CGRectMake(25, 2, 30, 16)];
        imgV1.image = [UIImage imageNamed:@"qianDao_yes1"];
        imgV2.image = [UIImage imageNamed:@"qianDao_yes2"];
        _yiQianDaoView.hidden = NO;
        [_yiQianDaoView addSubview:imgV1];
        [_yiQianDaoView addSubview:imgV2];
        
        [_yiQianDaoView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signedClick)]];

    }
    return _yiQianDaoView;
}

#pragma mark - 退出登录后改变成未签到状态
- (void)loginOutNoSign {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.qianDaoView];
}

#pragma mark - 判断签到
- (void)setUpsignIn {

    NSDictionary *paramDic = @{};
    //isCheckIn  0 没有签到  1已经签到了
    [AFRequest sendGetOrPostRequest:@"user/signDays" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            daysSignIn = [data[@"data"][@"signDays"] integerValue];
            BOOL isQianDao = [data[@"data"][@"isCheckIn"] integerValue] ? YES : NO;
            if (isQianDao) {
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.yiQianDaoView];

            }else {
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.qianDaoView];
            }
            if (sTypeView) {
                sTypeView.haveDays = daysSignIn;
                [sTypeView updateSubviews];
            }
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}


//签到
- (void)signInClick {
    
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    FKXSignInVC *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSignInVC"];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

//已经签到
- (void)signedClick {
    [self showHint:@"您已签到"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 通知，收到环信消息更新UI
- (void)refreshNewMessageLab
{
    [self loadNewNotice];
}
#pragma mark - 请求
#pragma mark - 加载未读通知的红点
- (void)loadNewNotice
{
    NSNumber *lastId = [FKXUserManager shareInstance].unReadNotification ? [FKXUserManager shareInstance].unReadNotification : @(0);
    NSDictionary *paramDic = @{@"lastId" : lastId};
    [AFRequest sendGetOrPostRequest:@"user/newNotice" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            NSInteger con = [data[@"data"][@"newTotal"] integerValue];
            NSInteger total = [[FKXUserManager shareInstance].unReadEaseMobMessage integerValue];
            if (con) {
                total += con;
            }
            if (total > 0) {
                newMessageLab.hidden = NO;
                newMessageLab.text = [NSString stringWithFormat:@"%@", total > 99 ? @"99+":@(total)];
            }else{
                newMessageLab.hidden = YES;
            }
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
- (void)loadUnreadRelMe
{
    NSDictionary *paramDic = @{@"time" : [FKXUserManager shareInstance].unreadRelMe ?[FKXUserManager shareInstance].unreadRelMe : @(0),@"uid":@([FKXUserManager shareInstance].currentUserId)};
    
    [AFRequest sendGetOrPostRequest:@"user/unreadRelMe" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
        
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            NSInteger con = [data[@"data"][@"number"] integerValue];
            NSString *headUrl = data[@"data"][@"headUrl"];
            if (con) {
                noReadNum = con;
                if ([FKXUserManager isUserPattern]) {
                    _viewAboutMe.hidden = NO;
                }else {
                    _viewAboutMe.hidden = YES;
                }
                
                if ([FKXUserManager isUserPattern]) {
                    self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", con];
                }
                UIView *view = self.tableView.tableHeaderView;
                view.height = 233 + 41 + 48;
                [self.tableView setTableHeaderView:view];
                NSString *tit = [NSString stringWithFormat:@"%ld",con];
                [_iconAboutMe sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",headUrl,cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                [_numAboutMe setTitle:tit forState:UIControlStateNormal];
            }else{
                self.tabBarItem.badgeValue = nil;
                _viewAboutMe.hidden = YES;
                UIView *view = self.tableView.tableHeaderView;
                view.height = 233 + 41;
                [self.tableView setTableHeaderView:view];
            }
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}

//加载倾听者资料
- (void)loadInfo
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"uid"];
    [FKXUserInfoModel sendGetOrPostRequest:@"listener/info"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             _labUserName.userInteractionEnabled = NO;
             _imgIcon.userInteractionEnabled = YES;
             
             userModel = data;
             //保存用户信息（更新）
             [FKXUserManager archiverUserInfo:userModel toUid:[userModel.uid stringValue]];
             
             [_imgIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",userModel.head, cropImageW]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
             _labUserName.text = userModel.name;
             
             _viewAboutMe.hidden = YES;
             UIView *view = self.tableView.tableHeaderView;
             view.height = 233 + 41;
             [self.tableView setTableHeaderView:view];
             
             if ([[FKXUserManager getUserInfoModel].role integerValue] == 0)
             {
                 [self setUpPaiHang:NO];
                 _paiHangImgV.image = [UIImage imageNamed:@"mine_paiHang_blue"];
                 _paiMing.textColor = kColorMainBlue;
                 
                 _bangzhuL.textColor = kColorMainBlue;
                 _zanL.textColor = kColorMainBlue;
                 _labContent.textAlignment = NSTextAlignmentCenter;
                 [_btnOpenAsk setTitle:@"成为心理关怀师" forState:UIControlStateNormal];
             }else {
                 _viewAboutMe.hidden = YES;
                 UIView *view = self.tableView.tableHeaderView;
                 view.height = 233 + 41;
                 [self.tableView setTableHeaderView:view];
                 
                 [self setUpPaiHang:NO];
                 //倾诉模式
                 if ([FKXUserManager isUserPattern]) {
                     _paiHangImgV.image = [UIImage imageNamed:@"mine_paiHang_blue"];
                     
                     _paiMing.textColor = kColorMainBlue;
                     
                     _bangzhuL.textColor = kColorMainBlue;
                     _zanL.textColor = kColorMainBlue;
                 }else {
                     _paiHangImgV.image = [UIImage imageNamed:@"mine_paiHang_red"];
                     
                     _paiMing.textColor = kColorMainRed;
                     
                     _bangzhuL.textColor = kColorMainRed;
                     _zanL.textColor = kColorMainRed;
                     
                     _paiMing.text = @"";
                     _downCount.text = @"";
                     _upCount.text = @"";
                     
                     _bangzhuL.text = [userModel.cureCount stringValue];
                     _bLabel.text = @"治愈人数";
                     
                     _zanL.text = [NSString stringWithFormat:@"%.2f", [userModel.inCome doubleValue]/100];

                     _zLabel.text = @"总收入";
                 }
             }
             
             
             NSDictionary *params = @{};

             [AFRequest sendPostRequestTwo:@"user/ranking" param:params success:^(id data) {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0) {
                     if ([[FKXUserManager getUserInfoModel].role integerValue] == 0 || [FKXUserManager isUserPattern])
                     {
                         _paiMing.text = @"排\n名";
                         _bLabel.text = @"评论数量";
                         _zLabel.text = @"被点赞数";

                         if ([data[@"data"][@"commentFloat"] integerValue] >0) {
                             _downImgV.image = [UIImage imageNamed:@"mine_paiHang_up"];
                             _downCount.text = [data[@"data"][@"commentDistance"] stringValue];
                         }else if([data[@"data"][@"commentFloat"] integerValue] <0){
                             _downImgV.image = [UIImage imageNamed:@"mine_paiHang_down"];
                             _downCount.text = [data[@"data"][@"commentDistance"] stringValue];
                         }
                         
                         if ([data[@"data"][@"praiseFloat"] integerValue] >0) {
                             _upImgV.image = [UIImage imageNamed:@"mine_paiHang_up"];
                             _upCount.text = [data[@"data"][@"praiseDistance"] stringValue];
                             
                         }else if([data[@"data"][@"praiseFloat"] integerValue] <0){
                             _upImgV.image = [UIImage imageNamed:@"mine_paiHang_down"];
                             _upCount.text = [data[@"data"][@"praiseDistance"] stringValue];
                         }
                         
                         
                         _bangzhuL.text =[data[@"data"][@"commentNum"] stringValue];
                         _zanL.text =[data[@"data"][@"praiseNum"] stringValue];

                     }
                 }else{
                     [self showHint:data[@"message"]];
                 }
             } failure:^(NSError *error) {
                 [self hideHud];
                [self showHint:@"网络出错"];
             }];
             
             [self.tableView reloadData];
            //加载与我相关的条数
             [self loadUnreadRelMe];
             [self loadNewNotice];
         } else if (errorModel)
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


#pragma mark - 设置排行榜状态
- (void)setUpPaiHang:(BOOL)isHiddenP {
    //隐藏排行版
    if (isHiddenP) {
        _labContent.hidden = NO;
        
        _paiHangImgV.hidden = YES;
        _lineV.hidden = YES;
        _paiMing.hidden = YES;
        _downImgV.hidden = YES;
        _upImgV.hidden = YES;
        
        _bLabel.hidden = YES;
        _zLabel.hidden = YES;
        
        _bangzhuL.hidden = YES;
        _zanL.hidden = YES;
        
        _upCount.hidden = YES;
        _downCount.hidden = YES;
        
    }
    else {
        _labContent.hidden = YES;
        
        _paiHangImgV.hidden = NO;
        _lineV.hidden = NO;
        _paiMing.hidden = NO;
        _downImgV.hidden = NO;
        _upImgV.hidden = NO;

        _bLabel.hidden = NO;
        _zLabel.hidden = NO;

        _bangzhuL.hidden = NO;
        _zanL.hidden = NO;
        
        _upCount.hidden = NO;
        _downCount.hidden = NO;
    }
}


#pragma mark - 点击事件
- (void)goToEditInfo
{
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
    }else{
        FKXOpenSecondAskController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXOpenSecondAskController"];
        vc.userModel = userModel;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)goToAboutMeVC
{
    FKXAboutMeVC *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXAboutMeVC"];
    vc.noReadNum = noReadNum;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 跳转排行详情界面
- (void)goToBangZhuVC {
    
    //判断身份
    if ([FKXUserManager isUserPattern]) {
        FKXMineDetailVC *detail = [[FKXMineDetailVC alloc]init];
        detail.type = MyDetailTypeHelp;
        detail.myhead = [NSString stringWithFormat:@"%@%@",userModel.head, cropImageW];
        [detail setHidesBottomBarWhenPushed:YES];

        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)goToZanVC {
    if ([FKXUserManager isUserPattern]) {
        FKXMineDetailVC *detail = [[FKXMineDetailVC alloc]init];
        detail.type = MyDetailTypeZan;
        detail.myhead = [NSString stringWithFormat:@"%@%@",userModel.head, cropImageW];
        [detail setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (IBAction)clickOpenAsk:(id)sender {
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    //role 非0 
    if ([[FKXUserManager getUserInfoModel].role integerValue]) {
        [ApplicationDelegate.window addSubview:changePatternBacView];
        
        [self performSelector:@selector(showTheAnimation) withObject:nil afterDelay:0.1];
    }else{
        FKXOpenSecondAskController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXOpenSecondAskController"];
        vc.userModel = userModel;
        vc.isOpen = YES;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)clickRightBtn
{
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    FKXChatListController *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXChatListController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 切换模式
- (void)loadTheAnimationView
{
    if (!changePatternBacView) {
        changePatternBacView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//
        changePatternBacView.backgroundColor = [UIColor whiteColor];
        UIImage *image = [UIImage imageNamed:@"rotate_animate_blue"];
        
        rotateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((changePatternBacView.width - image.size.width)/2, changePatternBacView.center.y - image.size.height/2, image.size.width, image.size.height)];
        rotateImageView.image = image;
        [changePatternBacView addSubview:rotateImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, rotateImageView.bottom + 20, changePatternBacView.width, 30)];
        label.backgroundColor = [UIColor clearColor];
        [changePatternBacView addSubview:label];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = UIColorFromRGB(0x0092ff);
        if ([FKXUserManager isUserPattern]) {
            label.text = @"正在切换至关怀模式...";
        }else{
            label.text = @"正在切换至倾诉模式...";
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
    }
}
- (void)showTheAnimation
{
    [UIView beginAnimations:nil context:nil];
    //渲染内存一般写 yes
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:rotateImageView cache:YES];
    [UIView setAnimationDuration:1];
    //[UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:0];
    
    [UIView commitAnimations];
    [self performSelector:@selector(showTheTabBar) withObject:nil afterDelay:1.1];
}
- (void)showTheTabBar
{
    //倾诉转关怀
    if ([FKXUserManager isUserPattern]) {
        [FKXUserManager setUserPatternToListener];
        [[FKXLoginManager shareInstance] showTabBarListenerController];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadUnreadRelMeOF" object:nil];
        
        ListenerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarListenerVC;
        tab.selectedIndex = 0;
    
        if (![FKXUserManager getUserInfoModel].clientNum) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bangdingPhone" object:nil];
        }
    
    }
    //关怀转倾诉
    else{
        [FKXUserManager setUserPatternToUser];
        [[FKXLoginManager shareInstance] showTabBarController];
        [changePatternBacView removeFromSuperview];
        SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
        tab.selectedIndex = 0;
    }
}
#pragma mark - 通知
- (void)loginSuccessAndNeedRefreshAllUI:(NSNotification *)not
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    if ([not.userInfo[@"status"] isEqualToString:@"logout"]) {
        self.tabBarItem.badgeValue = nil;
        _viewAboutMe.hidden = YES;
        
        [self setUpPaiHang:YES];
        
        UIView *view = self.tableView.tableHeaderView;
        view.height = 233 + 41;
        [self.tableView setTableHeaderView:view];
        _chatListVC.tabBarItem.badgeValue = nil;
        NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"让你智慧的价值变现。\n回答被认可后即可持续获得收入。"] attributes:@{NSParagraphStyleAttributeName:style}];
        [_labContent setAttributedText:attStr
         ];
        _labContent.textAlignment = NSTextAlignmentCenter;
        _labUserName.text = @"点击登录";
        _labUserName.userInteractionEnabled = YES;
        _imgIcon.userInteractionEnabled = NO;
        _imgIcon.image = [UIImage imageNamed:@"avatar_default"];
        [_btnOpenAsk setTitle:@"成为心理关怀师" forState:UIControlStateNormal];
    }else if([not.userInfo[@"status"] isEqualToString:@"login"])
    {
        //获取数据库中数据
        [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
//        NSLog(@"加载数据库数据错误:%@", loadError.description);
        
        NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
        NSUInteger unreadCount = 0;
        for (EMConversation *conversation in conversations) {
            unreadCount += conversation.unreadMessagesCount;
        }
        if (unreadCount > 0)
        {
            _chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", unreadCount];
        }else
        {
            _chatListVC.tabBarItem.badgeValue = nil;
        }
    }
    [self.tableView reloadData];
}
#pragma mark - ui 赋值
//未登录
- (void)setUpDataToSubviews
{
    _viewAboutMe.hidden = YES;
    
    [self setUpPaiHang:YES];
    
    UIView *view = self.tableView.tableHeaderView;
    view.height = 233 + 41;
    [self.tableView setTableHeaderView:view];
    [_btnOpenAsk setTitle:@"成为心理关怀师" forState:UIControlStateNormal];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"让你智慧的价值变现。\n回答被认可后即可持续获得收入。"] attributes:@{NSParagraphStyleAttributeName:style}];
    [_labContent setAttributedText:attStr
     ];
    _labContent.textAlignment = NSTextAlignmentCenter;
}
#pragma mark - Navigation
- (void)setUpNavigationBar
{
    UIImage *imageMind = [UIImage imageNamed:@"img_mine_message"];
    
    UIView *itemV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageMind.size.width/2 + 2 + 18,imageMind.size.width/2 + 2 + 18)];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, itemV.height - imageMind.size.height - 5, imageMind.size.width, imageMind.size.height)];
    imgV.image = imageMind;
    [itemV addSubview:imgV];
    
    newMessageLab = [[UILabel alloc] initWithFrame:CGRectMake(itemV.width - 18, 0, 18, 18)];
    newMessageLab.textAlignment = NSTextAlignmentCenter;
    newMessageLab.textColor = [UIColor whiteColor];
    [newMessageLab setAdjustsFontSizeToFitWidth:YES];
    newMessageLab.backgroundColor = UIColorFromRGB(0xfe9595);
    newMessageLab.font = [UIFont systemFontOfSize:12];
    newMessageLab.layer.cornerRadius = newMessageLab.width/2;
    newMessageLab.clipsToBounds = YES;
    [itemV addSubview:newMessageLab];
    
    newMessageLab.hidden = YES;
    
    [itemV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRightBtn)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:itemV];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0://我的主页
        {
            if ([FKXUserManager needShowLoginVC]) {
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                return;
            }
            FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
            vc.userId = @([FKXUserManager shareInstance].currentUserId);
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1://我答
        {
            FKXMyAnswerPageVC *vc = [[FKXMyAnswerPageVC alloc] init];
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2://我问
        {
            if ([FKXUserManager needShowLoginVC]) {
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                return;
            }
            //与我相关
            FKXMyAskListPageVC *vc = [[FKXMyAskListPageVC alloc] init];
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
 
            //我的订单
        case 3:
        {

            if ([FKXUserManager needShowLoginVC]) {
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                return;
            }
            FKXMyOrderVC *vc = [[FKXMyOrderVC alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
           
            //我的财富
        case 4:
        {
            if ([FKXUserManager needShowLoginVC]) {
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                return;
            }
//            FKXMyRichesVC *vc = [[FKXMyRichesVC alloc]init];
//            [vc setHidesBottomBarWhenPushed:YES];
//            [self.navigationController pushViewController:vc animated:YES];
            FKXMyLoveValueController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyLoveValueController"];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 5:
        {
            if ([FKXUserManager needShowLoginVC]) {
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
                return;
            }
            FKXMyShopVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyShopVC"];
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 7://消息列表
        {
            FKXSetTableViewController *vc = [[UIStoryboard storyboardWithName:@"My" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSetTableViewController"];
            FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([FKXUserManager isUserPattern]) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            return 0;
        }
        else{
            return 50;
        }
    }else{
        if (indexPath.row == 2 || indexPath.row == 3) {
            return 0;
        }
        else{
            return 50;
        }
    }
}

- (void)showView {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transViewPay)
    {
        //透明背景
        transViewPay = [[UIView alloc] initWithFrame:screenBounds];
        transViewPay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transViewPay.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transViewPay];
        
        payView = [[[NSBundle mainBundle] loadNibNamed:@"FKXZiXunShiV" owner:nil options:nil] firstObject];
        [payView.closeBtn addTarget:self action:@selector(hiddentransViewPay) forControlEvents:UIControlEventTouchUpInside];
        [payView.shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        
        [transViewPay addSubview:payView];
        payView.center = transViewPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewPay.alpha = 1.0;
        }];
        
    }
    
}

- (void)share {
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[NSURL URLWithString:@""]];
    NSString *urlStr;
    if ([FKXUserManager shareInstance].inviteCode) {
        urlStr = [NSString stringWithFormat:@"%@front/share.html?inviteCode=%@", kServiceBaseURL,[FKXUserManager shareInstance].inviteCode];
    }else{
        urlStr = [NSString stringWithFormat:@"%@front/share.html", kServiceBaseURL];
    }
    [shareParams SSDKSetupShareParamsByText:@"安抚你的小情绪"
                                     images:imageArray
     
                                        url:[NSURL URLWithString:urlStr]
                                      title:@"如何安全优雅地呵呵"
                                       type:SSDKContentTypeAuto];
    //单个分享
    SSDKPlatformType type = SSDKPlatformSubTypeWechatSession;
    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 [self shareSuccessCallBack];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享取消"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
         }
     }];
}

- (void)shareSuccessCallBack
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@([FKXUserManager shareInstance].currentUserId) forKey:@"uid"];
    [AFRequest sendGetOrPostRequest:@"sys/share_app" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hiddentransViewPay];
    } failure:^(NSError *error) {
    }];
}

- (void)hiddentransViewPay
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewPay.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewPay removeFromSuperview];
        transViewPay = nil;
        
        SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
        //展示切换模式动画
        FKXBaseNavigationController *nav = [tab.viewControllers lastObject];
        FKXPersonalViewController *vc = [nav viewControllers][0];
        [vc clickOpenAsk:nil];
        
        ListenerTabBarViewController *lis = [FKXLoginManager shareInstance].tabBarListenerVC;
        lis.selectedIndex = 0;
    }];
    
    
}

@end
