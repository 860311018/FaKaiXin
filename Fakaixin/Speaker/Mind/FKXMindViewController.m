//
//  FKXMindViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMindViewController.h"
#import "FKXResonance_homepage_model.h"
#import "FKXCommitHtmlViewController.h"
#import "SDCycleScrollView.h"
#import "FKXBannerModel.h"
#import "UIImage+Color.h"
#import "FKXBaseShareView.h"
#import "FKXRemoteNoticationView.h"
#import "FKXSignInVC.h"
#import "FKXMindCell.h"
#import "FKXCourseModel.h"
#import "FKXConsulterPageVC.h"
#import "FKXSearchTitleView.h"
#import "FKXSearchVC.h"
#import "STypeSignInView.h"
#import "FKXSignInView.h"
#import "FKXPsyTestCell.h"
#import "FKXBeginTestVC.h"
#import "FKXArticleCell.h"
#import "FKXRecommendListener.h"
#import "FKXPsyListModel.h"
#import "FKXPublishLetterVC.h"
#import "FKXConsulterPageVC.h"
#import "FKXFreeYuYueVC.h"
#import "FKXQingsuVC.h"
@interface FKXMindViewController ()<SDCycleScrollViewDelegate,
    UIScrollViewDelegate, UISearchBarDelegate,UINavigationControllerDelegate>
{
    NSInteger start;
    NSInteger size;
    
    FKXRemoteNoticationView *remoteNoticationView;
    UIView *transparentNotifiV;
    
    SDCycleScrollView *cycleScrollView2;    //轮播图
    NSMutableArray *imagesURLStrings;  //轮播图片
    NSMutableArray *bannerArrays;   //轮播数据
    
    BOOL isDisappear;   //当视图消失的时候，会走scrollview的代理方法，导致导航栏ui变化，所以控制一下
    UIView *tableHeaderV;//区头

    NSInteger currentTag;//0文章，1测试，2分享会
    FKXSearchTitleView *myCustomTitleView;//自定义titleview
    
    UIView *transViewSignIn;   //透明图
    NSInteger numToClean;//多少天清空
    FKXSignInView *signView;//签到总图
    STypeSignInView *sTypeView;//s型图
    NSInteger daysSignIn;//签到天数,传给s型图
}
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property   (nonatomic,strong)NSMutableArray *contentArrArticle;
@property   (nonatomic,strong)NSMutableArray *contentArrShare;
@property   (nonatomic,strong)NSMutableArray *contentArrTest;

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

//

@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;

@property (weak, nonatomic) IBOutlet UILabel *freeL;
@property (weak, nonatomic) IBOutlet UILabel *sendLetterL;
@property (weak, nonatomic) IBOutlet UILabel *yuyueL;
@property (weak, nonatomic) IBOutlet UILabel *qingsuL;


@property (weak, nonatomic) IBOutlet UIView *mySearchView;

@end

@implementation FKXMindViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadBannerImage];//加载banner图，

    isDisappear = NO;
    //签到动画
//    [UIView animateWithDuration:1 animations:^{
//        [UIView setAnimationRepeatCount:3];
//        _btnSignIn.transform = CGAffineTransformScale(_btnSignIn.transform, 1.2, 1.2);
//    } completion:^(BOOL finished) {
//        _btnSignIn.transform = CGAffineTransformIdentity;
//    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isDisappear = YES;
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    cycleScrollView2.frame = _myScrollView.bounds;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置导航控制器的代理为self
    self.navigationController.delegate = self;
    
    //默认赋值
    currentTag = 0;
    _contentArrArticle = [NSMutableArray arrayWithCapacity:1];
    _contentArrShare = [NSMutableArray arrayWithCapacity:1];
    _contentArrTest = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    
    [_freeL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(freeYuyue:)]];
    [_yuyueL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuanjiaYuyue:)]];
    [_qingsuL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(qingsu:)]];
    [_sendLetterL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(writeLetter:)]];
    
    //设置搜索UI
    _mySearchView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [_mySearchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginToSearch)]];
    
    //轮播图
    imagesURLStrings = [NSMutableArray arrayWithCapacity:1];
    bannerArrays = [NSMutableArray arrayWithCapacity:1];
    
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //判断是否需要加载对应的弹出界面
//    NSString *guideKey =[NSString stringWithFormat:@"user_guide_book_listener%@", AppVersionBuild];
//    if ([[NSUserDefaults standardUserDefaults] stringForKey:guideKey]) {
        //加载用户是否签到
//        if (![FKXUserManager needShowLoginVC]) {
////            [self loadSignDays];
//        }
//    }
    //创建提醒用户开启通知的UI
    NSString *transKey = [NSString stringWithFormat:@"hasTransparentNotifiV%@", AppVersionBuild];
    if (![[NSUserDefaults standardUserDefaults] stringForKey:transKey])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults  standardUserDefaults];
        [userDefaults setObject:transKey forKey:transKey];
        [userDefaults synchronize];
        [self setUpTransparentNotifiV];//创建通知提醒
    }
    //加载数据
    [self headerRefreshEvent];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 按钮点击
- (IBAction)freeYuyue:(id)sender {
    FKXFreeYuYueVC *vc = [[FKXFreeYuYueVC alloc]initWithNibName:@"FKXFreeYuYueVC" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)zhuanjiaYuyue:(id)sender {
    FKXConsulterPageVC *vc = [[FKXConsulterPageVC alloc]init];
    vc.navTitle = @"预约专家";
    vc.hidesBottomBarWhenPushed = YES;
    
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 3;
//    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)qingsu:(id)sender {
    FKXQingsuVC *vc = [[FKXQingsuVC alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)writeLetter:(id)sender {
    FKXPublishLetterVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishLetterVC"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    nav.hidesBottomBarWhenPushed = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
     //判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}
#pragma mark - 每天弹出签到
//加载用户是否已经签到
- (void)loadSignDays
{
    NSDictionary *paramDic = @{};
    //isCheckIn  0 没有签到  1已经签到了
    [AFRequest sendGetOrPostRequest:@"user/signDays" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            daysSignIn = [data[@"data"][@"signDays"] integerValue];
            _btnSignIn.selected = [data[@"data"][@"isCheckIn"] integerValue] ? YES : NO;
            if (!_btnSignIn.selected) {
                [self remindUserSign];
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
- (void)remindUserSign
{
    NSDate *date = [NSDate date];
    NSString *dateS = [date.description substringToIndex:10];
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@SignIn", dateS]];
    if (!key) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"%@SignIn", dateS]];
        if (!transViewSignIn)
        {
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            //透明背景
            transViewSignIn = [[UIView alloc] initWithFrame:screenBounds];
            transViewSignIn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            transViewSignIn.alpha = 0.0;
            [[UIApplication sharedApplication].keyWindow addSubview:transViewSignIn];
            
            signView = [[[NSBundle mainBundle] loadNibNamed:@"FKXSignInView" owner:nil options:nil] firstObject];
            signView.labTodays.text = [NSString stringWithFormat:@"%ld天之后清空签到",(long)numToClean];
            sTypeView = [[STypeSignInView alloc] initWithFrame:CGRectMake(10, 75,  signView.width - 20, 300)];
            sTypeView.haveDays = daysSignIn;
            [sTypeView updateSubviews];
            [signView addSubview:sTypeView];
            [signView.btnClose addTarget:self action:@selector(hiddentransViewSignIn) forControlEvents:UIControlEventTouchUpInside];
            [signView.btnSignIn addTarget:self action:@selector(rightNowSignIn) forControlEvents:UIControlEventTouchUpInside];
            [signView.btnAddSign addTarget:self action:@selector(addSignIn) forControlEvents:UIControlEventTouchUpInside];
            [transViewSignIn addSubview:signView];
            signView.center = transViewSignIn.center;
            [UIView animateWithDuration:0.5 animations:^{
                transViewSignIn.alpha = 1.0;
            }];
        }

    }
}
//立即签到
- (void)rightNowSignIn
{
    [self loadUserCheckIn];
}
//补签
- (void)addSignIn
{
    [self loadUserAddCheckIn];
}

#pragma mark - 点击三个按钮

- (IBAction)clickSignIn:(id)sender {
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    FKXSignInVC *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSignInVC"];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)hiddentransViewSignIn
{
    [UIView animateWithDuration:0.5 animations:^{
        transViewSignIn.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transViewSignIn removeFromSuperview];
        transViewSignIn = nil;
    }];
}
- (void)loadUserCleanLog
{
    NSDictionary *paramDic = @{};
    
    [AFRequest sendGetOrPostRequest:@"user/cleanLog" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            numToClean = [data[@"data"] integerValue];
            if (signView) {
                signView.labTodays.text = [NSString stringWithFormat:@"%ld天之后清空签到",(long)numToClean];
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
- (void)loadUserCheckIn
{
    [self showHudInView:signView hint:@"正在签到..."];
    NSDictionary *paramDic = @{};//补签 传type ＝ 1
    
    [AFRequest sendGetOrPostRequest:@"user/checkIn" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 500)
        {
            [self showHint:data[@"message"] yOffset:-300];
            [self loadUserCleanLog];
            [self loadSignDays];
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"] yOffset:-300];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
- (void)loadUserAddCheckIn
{
    [self showHudInView:signView hint:@"正在签到..."];
    NSDictionary *paramDic = @{@"type":@(1)};//补签 传type ＝ 1
    
    [AFRequest sendGetOrPostRequest:@"user/checkIn" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 500)
        {
            [self showHint:data[@"message"] yOffset:-300];
            [self loadUserCleanLog];
            [self loadSignDays];
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"] yOffset:-300];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
#pragma mark - 用户引导
- (void)anotherGuide:(UITapGestureRecognizer *)tap
{
    [tap.view removeFromSuperview];
    
    //调用引导图
    NSString *imageName = @"user_guide_publish_mind";
    [FKXUserManager showUserGuideWithKey:imageName withTarget:self action:@selector(goToPublishMind:)];
}
#pragma mark -点击事件
- (void)beginToSearch
{
    FKXSearchVC *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXSearchVC"];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:NO completion:nil];
}

//婚恋出轨 失恋阴影 。。。
- (IBAction)goToListener:(UIButton *)btn
{
    FKXRecommendListener *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXRecommendListener"];
    vc.type = btn.tag - 100;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goToPublishMind:(UITapGestureRecognizer *)tap
{
    [tap.view removeFromSuperview];

    FKXPublishMindViewController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishMindViewController"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -通知提示
- (void)setUpTransparentNotifiV
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transparentNotifiV) {
        //透明背景
        transparentNotifiV = [[UIView alloc] initWithFrame:screenBounds];
        transparentNotifiV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];//[UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:transparentNotifiV];
        remoteNoticationView = [[[NSBundle mainBundle] loadNibNamed:@"FKXRemoteNoticationView" owner:nil options:nil] firstObject];
        remoteNoticationView.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:0 alpha:0];
        [remoteNoticationView.btnClose addTarget:self action:@selector(hiddenTransparentNotifiV) forControlEvents:UIControlEventTouchUpInside];
        [remoteNoticationView.btnConfirm addTarget:self action:@selector(hiddenTransparentNotifiV) forControlEvents:UIControlEventTouchUpInside];
        remoteNoticationView.center = transparentNotifiV.center;
        [transparentNotifiV addSubview:remoteNoticationView];
    }
}
- (void)hiddenTransparentNotifiV
{
    [UIView animateWithDuration:0.5 animations:^{
        [transparentNotifiV removeAllSubviews];
        [transparentNotifiV removeFromSuperview];
        transparentNotifiV = nil;
        
        //请求用户权限
        [ApplicationDelegate beginRegisterRemoteNot];
    
//        //创建用户指引
//        NSString *imageName = @"user_guide_book_listener";
//        [FKXUserManager showUserGuideWithKey:imageName withTarget:self action:@selector(anotherGuide:)];
    }];
}
#pragma mark - uisearchBardelegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}
#pragma mark - 加载banner图
- (void)loadBannerImage
{
    NSDictionary *paramDic = @{};
    
    [FKXBannerModel sendGetOrPostRequest:@"sys/banner" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         if (data)
         {
             [imagesURLStrings removeAllObjects];
             [bannerArrays removeAllObjects];
             [bannerArrays addObjectsFromArray:data];
             for (FKXBannerModel *mod in bannerArrays) {
                 [imagesURLStrings addObject:mod.bannerUrl];
             }
             // 网络加载 --- 创建带标题的图片轮播器
             [cycleScrollView2 removeAllSubviews];
             cycleScrollView2 = nil;
             if (!cycleScrollView2) {
                 cycleScrollView2 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
                 cycleScrollView2.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
                 cycleScrollView2.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
                 [_myScrollView addSubview:cycleScrollView2];
                 cycleScrollView2.imageURLStringsGroup = imagesURLStrings;
             }
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];
}
#pragma mark - 循环滚动 SDCycleScrollViewDelegate
//循环滚动视图点击代理方法
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    //0:专题  1:分享会; 2: 课程; 3:心事; 4:相同心情评论页面;
    FKXBannerModel *bannerM = bannerArrays[index];
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    switch ([bannerM.type integerValue]) {
        case 0:
        {
            FKXCourseModel *model = [[FKXCourseModel alloc] init];
            model.keyId = bannerM.attachEventId;
            model.background = bannerM.bannerUrl;
            vc.shareType = @"topic_2";
            vc.pageType = MyPageType_nothing;
            vc.urlString = [NSString stringWithFormat:@"%@front/QA_q_detail.html?topicId=%@&uid=%ld&token=%@",kServiceBaseURL, model.keyId,(long)[FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
            vc.courseModel = model;
        }
            break;
        case 1:
        {
            FKXCourseModel *model = [[FKXCourseModel alloc] init];
            model.keyId = bannerM.attachEventId;
            model.background = bannerM.bannerUrl;
            model.uid = bannerM.uid;
            vc.shareType = @"discovery";
            vc.pageType = MyPageType_nothing;
            vc.urlString = [NSString stringWithFormat:@"%@front/discovery.html?keyId=%@&uid=%@&token=%@",kServiceBaseURL,model.keyId, model.uid, [FKXUserManager shareInstance].currentUserToken];
            vc.courseModel = model;
        }
            break;
        case 2:
        {
            FKXCourseModel *model = [[FKXCourseModel alloc] init];
            model.keyId = bannerM.attachEventId;
            model.background = bannerM.bannerUrl;
            model.uid = bannerM.uid;
            vc.shareType = @"course";
            vc.urlString = [NSString stringWithFormat:@"%@front/course.html?keyId=%@&uid=%@&token=%@",kServiceBaseURL, model.keyId,model.uid, [FKXUserManager shareInstance].currentUserToken];
            vc.courseModel = model;
            vc.pageType = MyPageType_course;
        }
            break;
        case 3:
        {
            FKXResonance_homepage_model *model = [[FKXResonance_homepage_model alloc] init];
            model.hotId = [bannerM.attachEventId stringValue];
            model.url = bannerM.bannerUrl;
            model.background = bannerM.bannerUrl;
            vc.shareType = @"mind";
            vc.urlString = [NSString stringWithFormat:@"%@front/mind_detail.html?shareId=%@&uid=%ld&token=%@",kServiceBaseURL, model.hotId, (long)[FKXUserManager shareInstance].currentUserId,[FKXUserManager shareInstance].currentUserToken];
            vc.pageType = MyPageType_hot;
            vc.resonanceModel = model;
        }
            break;
        case 4:
        {
            FKXSameMindModel *model = [[FKXSameMindModel alloc] init];
            model.worryId = bannerM.attachEventId;
            model.head = bannerM.bannerUrl;
            vc.pageType = MyPageType_nothing;
            vc.shareType = @"comment";
            vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,model.worryId, (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
            vc.sameMindModel = model;
        }
            break;
        default:
            break;
    }
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"yyyy=%f",scrollView.contentOffset.y);
    //280出现字
    if (!isDisappear) {
        if ([scrollView isMemberOfClass:[UITableView class]])
        {
            if (scrollView.contentOffset.y >= 140)
            {
                if (self.navigationController.isNavigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:NO animated:YES];
                }
                if (!self.navigationItem.titleView) {
                    myCustomTitleView = [[[NSBundle mainBundle] loadNibNamed:@"FKXSearchTitleView" owner:nil options:nil] firstObject];
                    myCustomTitleView.frame = CGRectMake(0, 0,self.view.width - 10,30);
                    [myCustomTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginToSearch)]];
                    self.navigationItem.titleView = myCustomTitleView;
                }
            }
            
            if (scrollView.contentOffset.y < 140)
            {
                if (self.navigationItem.titleView) {
                    self.navigationItem.titleView = nil;
                }
                if (!self.navigationController.isNavigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:YES animated:YES];
                }
            }
        }
    }
}
#pragma mark - ---网络请求---
- (void)headerRefreshEvent
{
//    [_contentArrArticle removeAllObjects];
//    [_contentArrShare removeAllObjects];
//    [self.tableView reloadData];
    start = 0;
    switch (currentTag) {
        case 0:
            [self loadArticle];
            break;
        case 1:
            [self loadTest];
            break;
        case 2:
            [self loadShare];
            break;
            
        default:
            break;
    }
}
- (void)footRefreshEvent
{
    start += size;
    switch (currentTag) {
        case 0:
            [self loadArticle];
            break;
        case 1:
            [self loadTest];
            break;
        case 2:
            [self loadShare];
            break;
            
        default:
            break;
    }
}

- (void)loadTest {
    //必须加上，否则，当切换文章和分享会的时候，用户滑动tableview的时候会崩溃，因为tableview的复用，
    
    NSDictionary *paramDic = @{@"start" : @(start), @"size": @(size)};
    
    [FKXPsyListModel sendGetOrPostRequest:@"psy/title_list" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
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
                 [_contentArrTest removeAllObjects];
             }
             [_contentArrTest addObjectsFromArray:data];
             
             [self.tableView reloadData];
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];
}

- (void)loadArticle
{
    //必须加上，否则，当切换文章和分享会的时候，用户滑动tableview的时候会崩溃，因为tableview的复用，
    
    NSDictionary *paramDic = @{@"start" : @(start), @"size": @(size)};
    
    [FKXResonance_homepage_model sendGetOrPostRequest:@"share/list" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
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
                 [_contentArrArticle removeAllObjects];
             }
             [_contentArrArticle addObjectsFromArray:data];
             
             [self.tableView reloadData];
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];
}
- (void)loadShare
{
    NSDictionary *paramDic = @{@"start" : @(start), @"size": @(size)};
    
    [FKXCourseModel sendGetOrPostRequest:@"course/apply_list" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
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
                 [_contentArrShare removeAllObjects];
             }
             [_contentArrShare addObjectsFromArray:data];
             
             [self.tableView reloadData];
             
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];
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

#pragma mark - tableView代理
- (void)clickSetionBtn:(UIButton *)sender
{
    start = 0;
    currentTag = sender.tag - 100;
    
    for (UIView *subV in [tableHeaderV subviews]) {
        if (subV.tag >= 200 && subV.tag <= 202) {
            subV.hidden = YES;
        }
    }
    UIView *line = [tableHeaderV viewWithTag:sender.tag + 200];
    line.hidden = NO;
    
    [self headerRefreshEvent];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat margin = (self.view.width - 50*3)/4;
    tableHeaderV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    tableHeaderV.backgroundColor = [UIColor whiteColor];
    UIButton *sectionBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    sectionBtn1.tag = 100;
    sectionBtn1.frame = CGRectMake(margin, 0, 50, tableHeaderV.height);
    [sectionBtn1 setTitle:@"读文章" forState:UIControlStateNormal];
    [sectionBtn1 setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateNormal];
    sectionBtn1.titleLabel.font = [UIFont systemFontOfSize:14];
    [tableHeaderV addSubview:sectionBtn1];
    [sectionBtn1 addTarget:self action:@selector(clickSetionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * sectionLine1 = [[UIView alloc] initWithFrame:CGRectMake(sectionBtn1.left + 5, tableHeaderV.height - 3, sectionBtn1.width - 10, 2)];
    sectionLine1.tag = 200;
    sectionLine1.backgroundColor = UIColorFromRGB(0x51b5ff);
    [tableHeaderV addSubview:sectionLine1];
//
    UIButton *sectionBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    sectionBtn2.tag = 101;
    sectionBtn2.frame = CGRectMake(sectionBtn1.right + margin, sectionBtn1.top,sectionBtn1.width, sectionBtn1.height);
    [sectionBtn2 setTitle:@"做测试" forState:UIControlStateNormal];
    [sectionBtn2 setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateNormal];
    sectionBtn2.titleLabel.font = [UIFont systemFontOfSize:14];
    [tableHeaderV addSubview:sectionBtn2];
    [sectionBtn2 addTarget:self action:@selector(clickSetionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *sectionLine2 = [[UIView alloc] initWithFrame:CGRectMake(sectionBtn2.left + 5, sectionLine1.top, sectionLine1.width, sectionLine1.height)];
    sectionLine2.tag = 201;
    sectionLine2.backgroundColor = UIColorFromRGB(0x51b5ff);
    [tableHeaderV addSubview:sectionLine2];
    
    
    UIButton *sectionBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    sectionBtn3.tag = 102;
    sectionBtn3.frame = CGRectMake(sectionBtn2.right + margin, sectionBtn2.top,sectionBtn2.width, sectionBtn2.height);
    [sectionBtn3 setTitle:@"学课程" forState:UIControlStateNormal];
    [sectionBtn3 setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateNormal];
    sectionBtn3.titleLabel.font = [UIFont systemFontOfSize:14];
    [tableHeaderV addSubview:sectionBtn3];
    [sectionBtn3 addTarget:self action:@selector(clickSetionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *sectionLine3 = [[UIView alloc] initWithFrame:CGRectMake(sectionBtn3.left + 5, sectionLine1.top, sectionLine1.width, sectionLine1.height)];
    sectionLine3.tag = 202;
    sectionLine3.backgroundColor = UIColorFromRGB(0x51b5ff);
    [tableHeaderV addSubview:sectionLine3];
    
    for (UIView *subV in [tableHeaderV subviews]) {
        if (subV.tag >= 200 && subV.tag <= 202) {
            subV.hidden = YES;
        }
    }
    UIView *line = [tableHeaderV viewWithTag:currentTag + 200];
    line.hidden = NO;
    return tableHeaderV;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (currentTag) {
        case 0:
            return _contentArrArticle.count;
            break;
        case 1:
            return _contentArrTest.count;
            break;
        case 2:
            return _contentArrShare.count;
            break;
        default:
            return 0;
            break;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (currentTag) {
        case 0:
        {
            if (indexPath.row == 1) {
                //文章列表第二个展示分享会的cell
                FKXMindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMindCell" forIndexPath:indexPath];
                
                FKXResonance_homepage_model *model = [self.contentArrArticle objectAtIndex:indexPath.row];
                FKXCourseModel *course = [[FKXCourseModel alloc] init];
                course.background = model.background;
                course.uid = model.uid;
                course.url = model.url;
                course.expectCost = model.expectCost;
                course.status = model.status;
                course.keyId = model.keyId;
                course.startTime = model.startTime;
                course.title = model.title;
                cell.courseModel = course;
                return cell;
//                FKXPsyTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXPsyTestCell" forIndexPath:indexPath];
//                
//                return cell;
            }else
            {
                FKXArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXArticleCell" forIndexPath:indexPath];
                
                FKXResonance_homepage_model *model = [self.contentArrArticle objectAtIndex:indexPath.row];
                cell.model = model;
                
                return cell;
            }
        }
            break;
        case 1:
        {
            FKXPsyTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXPsyTestCell" forIndexPath:indexPath];
            FKXPsyListModel *model = [self.contentArrTest objectAtIndex:indexPath.row];
            cell.model = model;
            return cell;
        }
            break;
        case 2:
        {
            FKXMindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMindCell" forIndexPath:indexPath];
            
            //    cell.delegate = self;
            FKXCourseModel *model = [self.contentArrShare objectAtIndex:indexPath.row];
            cell.courseModel = model;
            
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (currentTag) {
        case 0:
        {
            if (indexPath.row == 1) {
                FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
                
                FKXResonance_homepage_model *model = [self.contentArrArticle objectAtIndex:indexPath.row];
                FKXCourseModel *course = [[FKXCourseModel alloc] init];
                course.background = model.background;
                course.uid = model.uid;
                course.url = model.url;
                course.expectCost = model.expectCost;
                course.status = model.status;
                course.keyId = model.keyId;
                course.startTime = model.startTime;
                course.title = model.title;
                if (course.expectCost)
                {
                    vc.shareType = @"course";
                    vc.urlString = [NSString stringWithFormat:@"%@front/course.html?keyId=%@&uid=%@&token=%@",kServiceBaseURL, model.keyId,model.uid, [FKXUserManager shareInstance].currentUserToken];
                    vc.pageType = MyPageType_course;
                }
                else
                {
                    vc.shareType = @"discovery";
                    vc.urlString = [NSString stringWithFormat:@"%@front/discovery.html?keyId=%@&uid=%@&token=%@",kServiceBaseURL,model.keyId, model.uid, [FKXUserManager shareInstance].currentUserToken];
                    vc.pageType = MyPageType_nothing;
                }
                
                vc.courseModel = course;
                //push的时候隐藏tabbar
                [vc setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                FKXResonance_homepage_model *model = [self.contentArrArticle objectAtIndex:indexPath.row];
                
                FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
                vc.shareType = @"mind";
                vc.urlString = [NSString stringWithFormat:@"%@?shareId=%@&uid=%ld&token=%@",model.url, model.hotId, (long)[FKXUserManager shareInstance].currentUserId,[FKXUserManager shareInstance].currentUserToken];
                vc.pageType = MyPageType_hot;
                vc.resonanceModel = model;
                //push的时候隐藏tabbar
                [vc setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
#pragma mark - 开始测试
        case 1:
        {
            FKXBeginTestVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXBeginTestVC"];
            vc.listModel = self.contentArrTest[indexPath.row];
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            
            FKXCourseModel *model;
            model = _contentArrShare[indexPath.row];
            if (model.expectCost)
            {
                vc.shareType = @"course";
                vc.urlString = [NSString stringWithFormat:@"%@front/course.html?keyId=%@&uid=%@&token=%@",kServiceBaseURL, model.keyId,model.uid, [FKXUserManager shareInstance].currentUserToken];
                vc.pageType = MyPageType_course;
            }
            else
            {
                vc.shareType = @"discovery";
                vc.urlString = [NSString stringWithFormat:@"%@front/discovery.html?keyId=%@&uid=%@&token=%@",kServiceBaseURL,model.keyId, model.uid, [FKXUserManager shareInstance].currentUserToken];
                vc.pageType = MyPageType_nothing;
            }
            
            vc.courseModel = model;
            //push的时候隐藏tabbar
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}
@end
