//
//  FKXConsulterPageVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXConsulterPageVC.h"
#import "FKXConsultViewController.h"
#import "FKXChatListController.h"

//navBar navBar的按钮大小
#define kBtnW 48
#define kBtnH 20
//navBar 筛选按钮大小
#define kFilterBtnWidth 60
#define kFilterBtnHeight 16
//筛选视图的长度
#define kViewShaiXuanHeight 200



@interface FKXConsulterPageVC ()<UIScrollViewDelegate>//<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    UIPageViewController *myPageVC;
    UIImageView *bottomLineImg;//titleView中按钮下的线
    NSInteger currentTag;//控制页面向前跑还是向后跑
    UIView *titleV;//titleView
    
    //－－筛选的视图－－相关
    UIView *transparentView;
    UIView *viewShaiXuan;
    
    NSInteger mindType;
    NSInteger priceTag;//价格区间
    
//    NSMutableDictionary *toVC1Dic;//传递给子VC1的参数
    NSMutableDictionary *toVC2Dic;//传递给子VC2的参数
    
    FKXConsultViewController *currentVC;//存储当前展示的VC，方便调取VC的筛选刷新
    NSInteger currentIndex;
    
    UILabel *titleLab;//导航按钮title
    UILabel *newMessageLab;

}
@property (strong, nonatomic) NSArray *pageContent;//给pageVC的数据源

@property(nonatomic, strong)UIView *titleV;

@end

@implementation FKXConsulterPageVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fkxReceiveEaseMobMessage" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![FKXUserManager needShowLoginVC]) {//每次界面出现都要调用，刷新界面
        [self loadNewNotice];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor redColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewMessageLab) name:@"fkxReceiveEaseMobMessage" object:nil];

//    [currentVC.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];

    //默认值是第一个
    currentTag = 100;
//    if (!self.navTitle) {
//        self.navTitle = @"咨询师";
//
//    }

    //筛选赋初值
    priceTag = 0;
    if (!_goodAtsArr) {//从心事界面点击进来的
        _goodAtsArr = [NSMutableArray arrayWithCapacity:1];
    }
    //子视图
    [self setUpNavBar];
    [self setUpMyPageVC];
    
//    currentVC.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    [currentVC.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
//    
//    [currentVC.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
}

//- (void)headerRefreshEvent
//{
//    [currentVC headerRefreshEvent];
////    start = 0;
////    [self loadData];
//}
//- (void)footRefreshEvent
//{
//    [currentVC headerRefreshEvent];
//
////    start += size;
////    [self loadData];
//}

//- (void)headerRefreshEvent {
//    [currentVC loadData];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
#pragma mark - 导航栏
//- (void)setUpNavBar
//{
//    titleV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
//    NSArray *titleArr = @[@"关怀者", @"咨询师"];
//    CGFloat marginx = (titleV.width - kBtnW*titleArr.count)/(titleArr.count + 1);
//    
//    for (int i = 0; i < titleArr.count; i++) {
//        //g按钮
//        UIButton * gBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        gBtn.frame = CGRectMake(marginx + (marginx + kBtnW)*i, 10, kBtnW, kBtnH);
//        [gBtn setTitleColor:kColorMainBlue forState:UIControlStateNormal];
//        gBtn.backgroundColor = [UIColor whiteColor];
//        gBtn.tag = 100 + i;
//        [gBtn setTitle:titleArr[i] forState:UIControlStateNormal];
//        gBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//        [gBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
//        [titleV addSubview:gBtn];
//    }
//    UIButton *btn2 = [titleV viewWithTag:100];
//    bottomLineImg = [[UIImageView alloc] initWithFrame:CGRectMake(btn2.left, titleV.height - 3, btn2.width, 3)];
//    bottomLineImg.backgroundColor = kColorMainBlue;
//    [titleV addSubview:bottomLineImg];
//    self.navigationItem.titleView = titleV;
    
    //创建筛选按钮
//    UIImage *consultImage = [UIImage imageNamed:@"img_my_filter"];
//    UIButton *rightBarbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, consultImage.size.width, consultImage.size.height)];
//    [rightBarbtn setBackgroundImage:consultImage forState:UIControlStateNormal];
//    [rightBarbtn addTarget:self action:@selector(rightBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:rightBarbtn]];
//}



- (void)setUpNavBar
{
    //xioaxi
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
    
    [itemV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toXioxi)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:itemV];
    
    //title
    UIImage *leftI = [UIImage imageNamed:@"img_pro_title"];
    self.titleV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, leftI.size.height)];
    UIImageView *leftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, leftI.size.width, leftI.size.height)];
    leftIV.image = leftI;
    [self.titleV addSubview:leftIV];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(leftIV.right + 5, 0, 35, self.titleV.height)];
    titleLab.textColor = UIColorFromRGB(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.text = @"综合";
    [self.titleV addSubview:titleLab];
    //    if (_passMindType) {
    //        switch ([_passMindType integerValue]) {
    //            case 0:
    //                mindType = 0;
    //                titleLab.text = @"出轨";
    //                break;
    //            case 1:
    //                mindType = 1;
    //                titleLab.text = @"失恋";
    //                break;
    //            case 2:
    //                mindType = 2;
    //                titleLab.text = @"夫妻";
    //                break;
    //            case 3:
    //                mindType = 3;
    //                titleLab.text = @"婆媳";
    //                break;
    //
    //            default:
    //                break;
    //        }
    //    }
    UIImage *rightI = [UIImage imageNamed:@"img_change_mind_type"];
    UIImageView *rightIV = [[UIImageView alloc] initWithFrame:CGRectMake(titleLab.right + 1, (self.titleV.height - rightI.size.height)/2, rightI.size.width, rightI.size.height)];
    rightIV.image = rightI;
    [self.titleV addSubview:rightIV];
    
    self.navigationItem.titleView = self.titleV;
    
    [self.titleV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightBarButtonAction:)]];
}


#pragma mark - 点击事件
- (void)clicked:(UIButton *)btn{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = btn.frame.origin.x;
        bottomLineImg.frame = frame;
    }];
    
    if (btn.tag > currentTag) {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:btn.tag - 100]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }else if(btn.tag < currentTag) {
        [myPageVC setViewControllers:@[[self viewControllerAtIndex:btn.tag - 100]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    currentTag = btn.tag;
}
#pragma mark - pageVC相关
- (void)setUpMyPageVC
{
//    toVC1Dic = [NSMutableDictionary dictionaryWithCapacity:1];
//    toVC1Dic[@"role"] = @(1);
//    toVC1Dic[@"priceRange"] = @(priceTag);
//    toVC1Dic[@"goodAt"] = _goodAtsArr;
    toVC2Dic = [NSMutableDictionary dictionaryWithCapacity:1];
    toVC2Dic[@"role"] = @(3);
    toVC2Dic[@"priceOrder"] = @(priceTag);
    toVC2Dic[@"goodAt"] = _goodAtsArr;
    _pageContent = @[
                     toVC2Dic];//toVC1Dic,
    myPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]}];
//    myPageVC.delegate = self;
//    myPageVC.dataSource = self;
    myPageVC.view.frame = self.view.bounds;
    [self addChildViewController:myPageVC];
    [self.view addSubview:myPageVC.view];
    FKXConsultViewController *vc = [self viewControllerAtIndex:0];
    [myPageVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

// 得到相应的VC对象
- (FKXConsultViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    FKXConsultViewController *dataViewController = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXConsultViewController"];
    dataViewController.paraDic =[self.pageContent objectAtIndex:index];
    currentVC = dataViewController;
    currentIndex = index;
    return dataViewController;
}

// 返回上一个ViewController对象
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FKXConsultViewController *)viewController];
    NSLog(@"左：%ld", index);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = ((UIButton *)[titleV viewWithTag:100 + index]).origin.x;
        bottomLineImg.frame = frame;
    }];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index--;
    
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法，自动来维护次序。
    // 不用我们去操心每个ViewController的顺序问题。
    return [self viewControllerAtIndex:index];
}
- (NSUInteger)indexOfViewController:(FKXConsultViewController *)viewController
{
    NSUInteger index = [self.pageContent indexOfObject:viewController.paraDic];
    return index;
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FKXConsultViewController *)viewController];
    NSLog(@"右：%ld", index);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = bottomLineImg.frame;
        frame.origin.x = ((UIButton *)[titleV viewWithTag:100 + index]).origin.x;
        bottomLineImg.frame = frame;
    }];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [self.pageContent count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

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
#pragma mark - 通知，收到环信消息更新UI
- (void)refreshNewMessageLab
{
    [self loadNewNotice];
}

#pragma mark - UI 筛选
- (void)goBack
{
    [self removeTransparentView];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 消息
- (void)toXioxi {
    if (transparentView) {
        [self hiddenTransparent];
    }
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    FKXChatListController *vc = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXChatListController"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 筛选
-(void)rightBarButtonAction:(UIButton *)btn
{
    if (!transparentView) {
        //初始化筛选界面，将数组情况
        [_goodAtsArr removeAllObjects];
        //透明背景
        transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height)];
        transparentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        transparentView.alpha = 0;
        [[UIApplication sharedApplication].keyWindow addSubview:transparentView];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kViewShaiXuanHeight, kScreenWidth, self.view.height-kViewShaiXuanHeight)];
        view.backgroundColor = [UIColor clearColor];
        [transparentView addSubview:view];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTransparent)]];

        viewShaiXuan = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kViewShaiXuanHeight)];
        viewShaiXuan.backgroundColor = [UIColor whiteColor];
//        viewShaiXuan.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
//        viewShaiXuan.layer.borderWidth = 1.0;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:viewShaiXuan.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = viewShaiXuan.bounds;
        maskLayer.path = path.CGPath;
        viewShaiXuan.layer.mask = maskLayer;
        viewShaiXuan.layer.masksToBounds = YES;
        [transparentView addSubview:viewShaiXuan];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 12, 80, 15)];
        label.font = kFont_F3();
        label.textColor = UIColorFromRGB(0x5c5c5c);
        label.text = @"价格区间：";
        [viewShaiXuan addSubview:label];
//        CGFloat xMargin = (self.view.width - kFilterBtnWidth*4)/5;
        CGFloat xMargin = 60;
        CGFloat dMargin = 25;
        NSArray *arrTitle = @[@"从高到低", @"从低到高"];
        for (int i = 0; i < arrTitle.count; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(xMargin + (kFilterBtnWidth + dMargin)*i, label.bottom + 15, kFilterBtnWidth, kFilterBtnHeight);
            [btn setTitle:arrTitle[i] forState:UIControlStateNormal];
            btn.titleLabel.font = kFont_F4();
            btn.tag = 100 + i;
            [btn addTarget:self action:@selector(clickBtnPrice:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:UIColorFromRGB(0x5c5c5c) forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateSelected];
            [viewShaiXuan addSubview:btn];
        }
        
        UILabel *labelGoodAt = [[UILabel alloc] initWithFrame:CGRectMake(label.left, label.bottom + 30 + kFilterBtnHeight, 80, 15)];
        labelGoodAt.font = kFont_F3();
        labelGoodAt.textColor = UIColorFromRGB(0x5c5c5c);
        labelGoodAt.text = @"擅长领域：";
        [viewShaiXuan addSubview:labelGoodAt];;
        //婚恋出轨   失恋阴影  夫妻相处  婆媳关系
        NSArray *arrTitleGoodAt = @[@"婚恋出轨", @"失恋阴影", @"夫妻相处", @"婆媳关系"];
        CGFloat yBtn = labelGoodAt.bottom + 13;
        CGFloat btnMaX = 0.0 ;
        for (int i = 0; i < arrTitleGoodAt.count; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(xMargin + (kFilterBtnWidth + dMargin)*i, yBtn, kFilterBtnWidth, kFilterBtnHeight);

            if (i == 3) {

                if (btnMaX+ kFilterBtnWidth + dMargin > kScreenWidth) {

                    yBtn += 18 + kFilterBtnHeight;
                    btn.frame = CGRectMake(xMargin + (kFilterBtnWidth + dMargin)*(i%3), yBtn, kFilterBtnWidth, kFilterBtnHeight);
                }
            }
            
            btnMaX = CGRectGetMaxX(btn.frame);
            
            [btn setTitle:arrTitleGoodAt[i] forState:UIControlStateNormal];
            btn.titleLabel.font = kFont_F4();
            btn.tag = 200 + i;
            
            [btn addTarget:self action:@selector(clickBtnGoodAt:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:UIColorFromRGB(0x5c5c5c) forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateSelected];
            [viewShaiXuan addSubview:btn];
        }
        CGFloat xMarginDone = (self.view.width - 22 - 85*2)/2;
        UIButton *btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
        btnReset.frame = CGRectMake(xMarginDone, labelGoodAt.bottom + 45 + kFilterBtnHeight * 2, 85, 20);
        btnReset.tag = 302;
        btnReset.layer.cornerRadius = 5.0;
        btnReset.layer.borderColor = UIColorFromRGB(0x51b5ff).CGColor;
        btnReset.layer.borderWidth = 1.0;
        [btnReset setTitle:@"重置" forState:UIControlStateNormal];
        btnReset.titleLabel.font = kFont_F6();
        [btnReset setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateNormal];
        [btnReset addTarget:self action:@selector(clickedConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [viewShaiXuan addSubview:btnReset];
        
        UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDone.frame = CGRectMake(btnReset.right + 22, btnReset.top, btnReset.width, btnReset.height);
        btnDone.tag = 301;
        btnDone.layer.cornerRadius = 5.0;
        btnDone.layer.borderColor = UIColorFromRGB(0x51b5ff).CGColor;
        btnDone.layer.borderWidth = 1.0;
        [btnDone setTitle:@"确认" forState:UIControlStateNormal];
        btnDone.titleLabel.font = kFont_F6();
        [btnDone setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(clickedConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [viewShaiXuan addSubview:btnDone];
        
        [UIView animateWithDuration:0.3 animations:^{
            transparentView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            transparentView.alpha = !transparentView.alpha;
        } completion:^(BOOL finished) {
        }];
    }
}
- (void)hiddenTransparent
{
    [UIView animateWithDuration:0.3 animations:^{
        transparentView.alpha = !transparentView.alpha;
    } completion:^(BOOL finished) {
    }];
}
//6､创建手势处理方法：
- (void)removeTransparentView
{
    [transparentView removeFromSuperview];
    [transparentView removeAllSubviews];
    [viewShaiXuan removeAllSubviews];
    transparentView = nil;
    viewShaiXuan = nil;
}
- (void)clickBtnGoodAt:(UIButton *)btn
{
    [_goodAtsArr removeAllObjects];
//    if (_goodAtsArr.count == 3 && !btn.selected) {
//        [self showHint:@"最多选3个～"];
//        return;
//    }
    //btn.selected = !btn.selected;
//    if (btn.selected) {
//        [_goodAtsArr addObject:@(btn.tag - 200)];
//    }else{
//        [_goodAtsArr removeObject:@(btn.tag - 200)];
//    }
    for (UIButton *button in [viewShaiXuan subviews]) {
        if (button.tag >= 200 && button.tag <= 203) {
            button.selected = NO;
        }
    }
    btn.selected = YES;
//    btn.backgroundColor = kColorMainBlue;
    mindType = btn.tag - 200;
    [_goodAtsArr addObject:@(mindType)];
#pragma mark - 重置title
    NSString *btnTitle = @"";
    switch (btn.tag - 200) {
        
        case 0:
            btnTitle = @"出轨";
            break;
        case 1:
            btnTitle = @"失恋";
            break;
        case 2:
            btnTitle = @"夫妻";
            break;
        case 3:
            btnTitle = @"婆媳";
            break;
            
        default:
            break;
    }
    titleLab.text = btnTitle;
    
//    [self hiddenTransparent];
    
}
- (void)clickBtnPrice:(UIButton *)btn
{
    for (UIButton *button in [viewShaiXuan subviews]) {
        if (button.tag >= 100 && button.tag <= 103) {
            button.selected = NO;
        }
    }
    btn.selected = YES;
    priceTag = btn.tag - 100;
}
- (void)clickedConfirm:(UIButton *)butt
{
    if (butt.tag == 301) {//确认
//        toVC1Dic[@"priceRange"] = @(priceTag);
        toVC2Dic[@"priceOrder"] = @(priceTag);
//        toVC1Dic[@"goodAt"] = _goodAtsArr;
        toVC2Dic[@"goodAt"] = _goodAtsArr;
        
        currentVC.paraDic = [_pageContent objectAtIndex:currentIndex];
        //给tableview添加下拉刷新,上拉加载
        
        [currentVC loadData];//重新加载数据
        
        [UIView animateWithDuration:0.3 animations:^{
            transparentView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }else if (butt.tag == 302) {//重置
        priceTag = 0;
        [_goodAtsArr removeAllObjects];
//        toVC1Dic[@"priceRange"] = @(priceTag);
        toVC2Dic[@"priceOrder"] = @(priceTag);
//        toVC1Dic[@"goodAt"] = _goodAtsArr;
        toVC2Dic[@"goodAt"] = _goodAtsArr;
        
        titleLab.text = @"综合";
        
        for (UIButton *button in [viewShaiXuan subviews]) {
            if (button.tag >= 100 && button.tag <= 103) {
                button.selected = NO;
            }
            if (button.tag >= 200 && button.tag <= 205) {
                button.selected = NO;
            }
        }
        
    }
}
@end
