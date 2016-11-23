//
//  FKXSecondAskController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXSecondAskController.h"
#import "FKXSecondAskCell.h"
#import "NSString+HeightCalculate.h"
#import "FKXSecondAskModel.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "FKXCourseModel.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXProfessionInfoVC.h"
#import "FKXChatListController.h"

#define kFontOfContent 15
//navBar 筛选按钮大小
#define kFilterBtnWidth 80
#define kFilterBtnHeight 25
//筛选视图的长度
#define kViewShaiXuanHeight 100

@interface FKXSecondAskController ()<FKXSecondAskCellDelegate>
{
    NSInteger start;
    NSInteger size;
    CGFloat oneLineH;   //一行的高度
    UIButton *currentBtn;
    UIButton *prePlayBtn;
    NSNumber *specialKeyId; //专题的id
    NSString *specialBackground; //专题的背景图
    FKXEmptyData *emptyDataView;    //空数据
    UILabel *titleLab;//导航按钮title

    NSDictionary *specialDic;//专题的model
    
    //－－筛选的视图－－相关
    UIView *transparentView;
    UIView *viewShaiXuan;
    
    NSInteger mindType;
    
    UILabel *newMessageLab;
}
@property   (nonatomic,strong)NSMutableArray *contentArr;
@property (nonatomic, assign) BOOL isPlaying;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property(nonatomic, strong)UIView *titleV;

@end

@implementation FKXSecondAskController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectMind" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fkxReceiveEaseMobMessage" object:nil];
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_isMyListenList) {
        self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    }
    else{
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *imageName = @"user_guide_listen_6";
    [FKXUserManager showUserGuideWithKey:imageName];
    
    if (![FKXUserManager needShowLoginVC]) {//每次界面出现都要调用，刷新界面
        [self loadNewNotice];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //收到环信消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewMessageLab) name:@"fkxReceiveEaseMobMessage" object:nil];
    //基本赋值
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    mindType = -1;
    //一行文字的高度，cell自适应高度用到
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    oneLineH = [@"哈" heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    if (_isMyListenList) {
        self.navTitle = @"我听";
        self.tableView.tableHeaderView.frame = CGRectZero;
    }
    //增加手势
    [self addGestureToBanner];
    //增加改变心事类型的通知(购买偷听后也调这个通知，因为都是刷新)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshEvent) name:@"SelectMind" object:nil];
    //ui设置
    [self setUpNavBar];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //加载数据
    [self headerRefreshEvent];

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
#pragma mark - 导航栏
- (void)clickRightBtn
{
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
- (void)setUpNavBar
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
    
    UIImage *leftI = [UIImage imageNamed:@"img_font_ask"];
    _titleV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, leftI.size.height)];
    UIImageView *leftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, leftI.size.width, leftI.size.height)];
    leftIV.image = leftI;
    [_titleV addSubview:leftIV];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(leftIV.right + 5, 0, 35, _titleV.height)];
    titleLab.textColor = UIColorFromRGB(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.text = @"综合";
    [_titleV addSubview:titleLab];
    
    if (_passMindType) {
        switch ([_passMindType integerValue]) {
            case 0:
                mindType = 0;
                titleLab.text = @"出轨";
                break;
            case 1:
                mindType = 1;
                titleLab.text = @"失恋";
                break;
            case 2:
                mindType = 2;
                titleLab.text = @"夫妻";
                break;
            case 3:
                mindType = 3;
                titleLab.text = @"婆媳";
                break;
                
            default:
                break;
        }
    }
    
    UIImage *rightI = [UIImage imageNamed:@"img_change_mind_type"];
    UIImageView *rightIV = [[UIImageView alloc] initWithFrame:CGRectMake(titleLab.right + 1, (_titleV.height - rightI.size.height)/2, rightI.size.width, rightI.size.height)];
    rightIV.image = rightI;
    [_titleV addSubview:rightIV];
    
    self.navigationItem.titleView = _titleV;
    
    [_titleV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMindType)]];
}
- (void)changeMindType
{
    if (!transparentView) {
        //透明背景
        transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height)];
        transparentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        transparentView.alpha = 0;
        [[UIApplication sharedApplication].keyWindow addSubview:transparentView];
        [transparentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTransparent)]];

        viewShaiXuan = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kViewShaiXuanHeight)];
        viewShaiXuan.backgroundColor = [UIColor whiteColor];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:viewShaiXuan.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = viewShaiXuan.bounds;
        maskLayer.path = path.CGPath;
        viewShaiXuan.layer.mask = maskLayer;
        viewShaiXuan.layer.masksToBounds = YES;
        [transparentView addSubview:viewShaiXuan];
        
        NSArray *arrTitleGoodAt = @[@"综合排序",@"婚恋出轨", @"失恋阴影", @"夫妻相处", @"婆媳关系"];
        CGFloat xMargin = (self.view.width - kFilterBtnWidth*4)/5;
        CGFloat yBtn = 19;
        for (int i = 0; i < arrTitleGoodAt.count; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            if (i == 4) {
                yBtn += 16 + kFilterBtnHeight;
            }
            btn.frame = CGRectMake(xMargin + (kFilterBtnWidth + xMargin)*(i%4), yBtn, kFilterBtnWidth, kFilterBtnHeight);
            [btn setTitle:arrTitleGoodAt[i] forState:UIControlStateNormal];
            btn.titleLabel.font = kFont_F4();
            if (i == 0) {
                btn.tag = 199;
            }else{
                btn.tag = 200 + i-1;
            }

            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.borderColor = kColorMainBlue.CGColor;
            btn.layer.cornerRadius = 5;
            btn.layer.borderWidth = 1.0;
            [btn addTarget:self action:@selector(clickBtnGoodAt:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:UIColorFromRGB(0x5c5c5c) forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [viewShaiXuan addSubview:btn];
        }
        [UIView animateWithDuration:0.3 animations:^{
            transparentView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }else{
        [self hiddenTransparent];
//        [UIView animateWithDuration:0.3 animations:^{
//            transparentView.alpha = !transparentView.alpha;
//        } completion:^(BOOL finished) {
//        }];
    }
}
- (void)hiddenTransparent
{
    [UIView animateWithDuration:0.3 animations:^{
        transparentView.alpha = 0;
    } completion:^(BOOL finished) {
        [transparentView removeFromSuperview];
        [transparentView removeAllSubviews];
        [viewShaiXuan removeAllSubviews];
        transparentView = nil;
        viewShaiXuan = nil;
    }];
}
//6､创建手势处理方法：
//- (void)removeTransparentView
//{
//    [transparentView removeFromSuperview];
//    [transparentView removeAllSubviews];
//    [viewShaiXuan removeAllSubviews];
//    transparentView = nil;
//    viewShaiXuan = nil;
//}
- (void)clickBtnGoodAt:(UIButton *)btn
{
    for (UIButton *subBtn in [viewShaiXuan subviews]) {
        subBtn.selected = NO;
        subBtn.backgroundColor = [UIColor whiteColor];
    }
    btn.selected = YES;
    btn.backgroundColor = kColorMainBlue;
    mindType = btn.tag - 200;
    NSString *btnTitle = @"";
    switch (btn.tag - 200) {
        case -1:
            btnTitle = @"综合";
            break;
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
    start = 0;
    
    [self hiddenTransparent];
    
    [self loadData];
}

#pragma mark - 创建手势
- (void)addGestureToBanner
{
    _imgHeader.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToSpecialDetail)];
    [_imgHeader addGestureRecognizer:tap];
}
#pragma mark - 手势
- (void)goToSpecialDetail
{
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    FKXCourseModel *model = [[FKXCourseModel alloc] init];
    model.background = specialDic[@"background"];
    model.keyId = specialDic[@"id"];
    model.title = specialDic[@"title"];
    model.content = specialDic[@"content"];
    vc.shareType = @"topic_2";
    vc.pageType = MyPageType_nothing;
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_q_detail.html?topicId=%@&uid=%ld&token=%@",kServiceBaseURL, model.keyId,(long)[FKXUserManager shareInstance].currentUserId, [FKXUserManager shareInstance].currentUserToken];
    vc.courseModel = model;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
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
//加载相同心情的人
- (void)loadData
{
    NSDictionary *paramDic;
    NSString *method;
    if (_isMyListenList) {
        paramDic = @{@"start":@(start), @"size":@(size)};
        method = @"voice/meListen";
    }else{
        paramDic = @{@"type" : @(mindType), @"start":@(start), @"size":@(size),@"uid":@([FKXUserManager shareInstance].currentUserId)};
        method = @"voice/selectVoice";
    }
    [AFRequest sendGetOrPostRequest:method param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
    {
        self.tableView.header.state = MJRefreshHeaderStateIdle;
        self.tableView.footer.state = MJRefreshFooterStateIdle;
        
        NSError *err = nil;
        if ([data[@"code"] integerValue] == 0)
        {
            if (data[@"data"][@"banner"]) {
                specialDic =
                @{
                  @"id":data[@"data"][@"banner"][@"id"],
                  @"background":data[@"data"][@"banner"][@"background"],
                  @"title":data[@"data"][@"banner"][@"title"],
                  @"content":data[@"data"][@"banner"][@"content"]};
                [_imgHeader sd_setImageWithURL:[NSURL URLWithString:data[@"data"][@"banner"][@"background"]] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
            }
            if (start == 0)
            {
                [_contentArr removeAllObjects];
                
                if (_isMyListenList) {
                    if ([data[@"data"][@"list"] count] == 0) {
                        [self createEmptyData];
                    }else{
                        if (emptyDataView) {
                            [emptyDataView removeFromSuperview];
                            emptyDataView = nil;
                        }
                    }
                }
            }
            for (NSDictionary *dic in data[@"data"][@"list"])
            {
                FKXSecondAskModel * officalSources =  [[FKXSecondAskModel alloc] initWithDictionary:dic error:&err];
                [_contentArr addObject:officalSources];
            }
            if ([data[@"data"][@"list"] count] < kRequestSize) {
                self.tableView.footer.hidden = YES;
            }else
            {
                self.tableView.footer.hidden = NO;
            }
            [self.tableView reloadData];
        }else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else
        {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"网络出错"];
    }];
}
#pragma mark - UI空数据
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        [emptyDataView.btnDeal addTarget:self action:@selector(clickBtnDeal) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:emptyDataView];
        emptyDataView.titleLab.text = @"你还没有悄悄听过别人的语音回复哦~";
        [emptyDataView.btnDeal setTitle:@"去听一下~" forState:UIControlStateNormal];
        if ([FKXUserManager isUserPattern]) {
            [emptyDataView.btnDeal setTitleColor:kColorMainBlue forState:UIControlStateNormal];
            emptyDataView.btnDeal.layer.borderColor = kColorMainBlue.CGColor;
        }else{
            [emptyDataView.btnDeal setTitleColor:kColorMainRed forState:UIControlStateNormal];
            emptyDataView.btnDeal.layer.borderColor = kColorMainRed.CGColor;
        }
    }
}
- (void)clickBtnDeal
{
    [[FKXLoginManager shareInstance] showTabBarController];
    [FKXUserManager setUserPatternToUser];
    SpeakerTabBarViewController *tab = [FKXLoginManager shareInstance].tabBarVC;
    tab.selectedIndex = 1;
}
#pragma mark - cell自定义代理
- (void)goToDynamicVC:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender
{
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    vc.userId = cellModel.listenerId;
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    CGFloat height = [model.text heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    if (height > oneLineH*3)//文字高度大于3行
    {
        return oneLineH*3 + 106;
    }else{
        return height + 106;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];
    FKXSecondAskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXSecondAskCell" forIndexPath:indexPath];
    cell.model = model;
    cell.delegate = self;
    if (_isMyListenList) {
        cell.imgMargin.hidden = NO;
    }else{
        cell.imgMargin.hidden = YES;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.isNeedTwoItem = YES;
    FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];
    //这里都是已经被认可的，直接传1
    vc.pageType = MyPageType_nothing;
    vc.shareType = @"second_ask";
    NSString *paraStr = @"worryId";//默认传worryId
    NSNumber *paraId;
    if (model.worryId) {
        paraId = model.worryId;
    }
    if (model.topicId) {
        paraStr = @"topicId";
        paraId = model.topicId;
    }
    if (model.lqId) {
        paraStr = @"lqId";
        paraId = model.lqId;
    }
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=1&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, model.voiceId, [FKXUserManager shareInstance].currentUserToken];
    vc.secondModel = model;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
