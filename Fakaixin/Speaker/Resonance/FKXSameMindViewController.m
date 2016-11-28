//
//  FKXSameMindViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXSameMindViewController.h"
#import "FKXSameMindModel.h"
#import "ChatViewController.h"
#import "FKXSameMindCell.h"
#import "FKXSameMindImgCell.h"
#import "NSString+HeightCalculate.h"
#import "FKXCommitHtmlViewController.h"
#import "SpeakerTabBarViewController.h"
#import "FKXBaseShareView.h"
#import "FKXProfessionInfoVC.h"
#import "FKXPublishMindViewController.h"
#import "FKXMyShopVC.h"
#import "FKXChatListController.h"
#import "FKXPublishMindViewController.h"

#import "FKXRongHeModel.h"

#define kFontOfContent 15

//navBar 筛选按钮大小
#define kFilterBtnWidth 80
#define kFilterBtnHeight 25
//筛选视图的长度
#define kViewShaiXuanHeight 100


@interface FKXSameMindViewController ()<FKXSameMindCellDelegate, FKXSameMindImgCellDelegate>
{
    NSInteger start;
    NSInteger size;
    CGFloat oneLineH;   //一行的高度
    FKXEmptyData *emptyDataView;    //空数据
    UILabel *titleLab;//导航按钮title
    
    //－－筛选的视图－－相关
    UIView *transparentView;
    UIView *viewShaiXuan;
    NSInteger mindType;
    
    UILabel *newMessageLab;
    
    UIView *transViewRemind;
}
@property   (nonatomic,strong)NSMutableArray *contentArr;
@property(nonatomic, strong)UIView *titleV;

@property (nonatomic,strong) UIButton *helpBtn;

@property (nonatomic,strong)NSDictionary *bannerDic;

@end

@implementation FKXSameMindViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectMind" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectMindType" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginBackToSameMind" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fkxReceiveEaseMobMessage" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.helpBtn removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [ApplicationDelegate.window addSubview:self.helpBtn];
    
    NSString *imageName = @"user_guide_commit_6";
    [FKXUserManager showUserGuideWithKey:imageName];
    if (![FKXUserManager needShowLoginVC]) {//每次界面出现都要调用，刷新界面
        [self loadNewNotice];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _bannerDic = [[NSDictionary alloc]init];
    //收到环信消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewMessageLab) name:@"fkxReceiveEaseMobMessage" object:nil];
    //增加改变心事类型的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshEvent) name:@"SelectMind" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMind:) name:@"SelectMindType" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshEvent) name:@"LoginBackToSameMind"  object:nil];

    
    //基本赋值
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    CGRect screen = [UIScreen mainScreen].bounds;
    oneLineH = [@"哈" heightForWidth:screen.size.width - 34 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    mindType = -1;
    
    //ui设置

    [self setUpNavBar];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
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
//        [transparentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTransparent)]];

        viewShaiXuan = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kViewShaiXuanHeight)];
        viewShaiXuan.backgroundColor = [UIColor whiteColor];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:viewShaiXuan.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = viewShaiXuan.bounds;
        maskLayer.path = path.CGPath;
        viewShaiXuan.layer.mask = maskLayer;
        viewShaiXuan.layer.masksToBounds = YES;
    
        [transparentView addSubview:viewShaiXuan];
        
        UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(0, kViewShaiXuanHeight, kScreenWidth, self.view.height-kViewShaiXuanHeight)];
        tapView.backgroundColor = [UIColor clearColor];
        [tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTransparent)]];
        [transparentView addSubview:tapView];
        
        
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

#pragma mark - UI
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        [emptyDataView.btnDeal addTarget:self action:@selector(clickBtnDeal) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:emptyDataView];
    }
}
- (void)clickBtnDeal
{
    FKXPublishMindViewController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishMindViewController"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:^{
    }];
}
- (void)goToPublishMind
{
    FKXPublishMindViewController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishMindViewController"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
    
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

- (void)refreshMind:(NSNotification *)not {
    mindType = [not.object integerValue];
    NSString *btnTitle = @"";
    switch (mindType) {
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
    [self loadData];
}


//加载相同心情的人
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
    paramDic[@"type"] = @(mindType);

    [AFRequest sendPostRequestTwo:@"voice/voice_worry" param:paramDic success:^(id data) {
        self.tableView.header.state = MJRefreshHeaderStateIdle;
        self.tableView.footer.state = MJRefreshFooterStateIdle;
        
        _bannerDic = data[@"data"][@"banner"];
        
        if ([data[@"code"] integerValue] == 0) {
            NSArray *listArr = data[@"data"][@"list"];
            if (listArr) {
                [self hideHud];
                if ([data count] < kRequestSize) {
                    self.tableView.footer.hidden = YES;
                }else{
                    self.tableView.footer.hidden = NO;
                }
                if (start == 0){
                    [_contentArr removeAllObjects];
                    if ([data count] == 0) {
                        [self createEmptyData];
                    }else{
                        if (emptyDataView) {
                            [emptyDataView removeFromSuperview];
                            emptyDataView = nil;
                        }
                    }
                }
                for (NSDictionary *dic in listArr) {
                    FKXRongHeModel * officalSources = [[FKXRongHeModel alloc] initWithDictionary:dic error:nil];
                    [_contentArr addObject:officalSources];
                }
                [self.tableView reloadData];
            }
        }else {
            [self showHint:data[@"message"]];
        }
        
        
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 155;
    }else {
        FKXRongHeModel *allModel = [self.contentArr objectAtIndex:indexPath.row];
        FKXSameMindModel *model = [[FKXSameMindModel alloc]init];
        if ([allModel.type integerValue]==0) {
            model = allModel.worryVO;
        }else{
            model = allModel.sendsAskVO;
        }
        
        CGRect screen = [UIScreen mainScreen].bounds;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8;
        CGFloat height = [model.text heightForWidth:screen.size.width - 34 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    
        if ([allModel.type integerValue] == 0) {
            if (model.imageArray.count) {//如果有图片
                if (height > oneLineH*3)//文字高度大于3行
                {
                    return oneLineH*3 + 354-20;
                }else{
                    return height + 354 - 14;
                }
            }else {
                //如果没有图片
                if (height > oneLineH*3)//文字高度大于3行
                {
                    return oneLineH*3 +142-20;
                }else{
                    return height + 142-14;//隐藏查看更多
                }
            }
        }else {
            if (height > oneLineH*3)//文字高度大于3行
            {
                return oneLineH*3 + 142-20 +20;
            }else{
                return height + 142 - 14 +20;//隐藏查看更多
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
    static NSString *Identifier = @"SameMindTitle";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        }
        
        UIImageView *titleImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
        titleImgV.contentMode = UIViewContentModeScaleAspectFill;
        titleImgV.clipsToBounds = YES;
        [titleImgV sd_setImageWithURL:[NSURL URLWithString:_bannerDic[@"background"]] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
        [cell addSubview:titleImgV];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 150, kScreenWidth, 5)];
        view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        [cell addSubview:view];
        
        return cell;
    }else {
        FKXRongHeModel *allModel = [self.contentArr objectAtIndex:indexPath.row];
        FKXSameMindModel *model = [[FKXSameMindModel alloc]init];
        if ([allModel.type integerValue]==0) {
            model = allModel.worryVO;
        }else {
            model = allModel.sendsAskVO;
        }
        if (!model.imageArray.count) {
            FKXSameMindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXSameMindCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.type = [allModel.type integerValue];
            cell.model = model;
            return cell;
        }else
        {
            FKXSameMindImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXSameMindImgCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.type = [allModel.type integerValue];
            cell.model = model;
            return cell;
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXRongHeModel *allModel = [self.contentArr objectAtIndex:indexPath.row];
    if ([allModel.type integerValue] == 0) {
        FKXSameMindModel *model = allModel.worryVO;
        [self toComment:model];

    }else {
        FKXSameMindModel *model = allModel.sendsAskVO;
        [self toVoice:model];
    }
}

#pragma mark - FKXSameMindCellDelegate 代理
- (void)clickToOpenDetail
{
    [self.tableView reloadData];
}


//抱抱
- (void)baobaoImg:(FKXSameMindModel*)cellModel {
    [self baobaoClick:cellModel];
}
- (void)baobao:(FKXSameMindModel*)cellModel {
    [self baobaoClick:cellModel];
}

//跳转评论HTML
- (void)comment:(FKXSameMindModel*)cellModel{
    [self toComment:cellModel];
}

- (void)commentImg:(FKXSameMindModel*)cellModel {
    [self toComment:cellModel];
}

//跳转语音HTML
- (void)voice:(FKXSameMindModel*)cellModel {
    [self toVoice:cellModel];
}

- (void)voiceImg:(FKXSameMindModel*)cellModel {
    [self toVoice:cellModel];
}


- (void)hugOrFeelDidSelect:(FKXSameMindModel*)cellModel type:(NSInteger)type andCellType:(NSInteger)cellType
{
     if (type == 2)
    {
        [self toShare:cellModel];
    }else if (type == 3)
    {
        [self toChang:cellModel];
    }else if (type == 4)
    {
        [self toPro:cellModel andCellType:cellType];
    }
}
- (void)hugOrFeelImgDidSelect:(FKXSameMindModel*)cellModel type:(NSInteger)type andCellType:(NSInteger)cellType
{
     if (type == 2)
    {
        [self toShare:cellModel];
    }else if (type == 3)
    {
        [self toChang:cellModel];
    }else if (type == 4)
    {
        [self toPro:cellModel andCellType:cellType];
    }
}

#pragma mark - 专家个人页面
- (void)toPro:(FKXSameMindModel *)cellModel andCellType:(NSInteger)cellType {
    if (cellType == 0) {
        if ([cellModel.isPublic integerValue] || [FKXUserManager shareInstance].currentUserId == [cellModel.uid integerValue]) {
            FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
            vc.userId = cellModel.uid;
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else {
        FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
        vc.userId = cellModel.listenerId;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 抱抱
- (void)baobaoClick:(FKXSameMindModel *)cellModel {
    if ([cellModel.hug boolValue]) {
        [self showHint:@"已经抱过了"];
        return;
    }
    [self showHudInView:self.view hint:@"正在抱抱..."];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:cellModel.worryId forKey:@"worryId"];
    [AFRequest sendGetOrPostRequest:@"worry/hug"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         
         if ([data[@"code"] integerValue] == 0)
         {
             cellModel.hug = @(YES);
             [self.tableView reloadData];
             //                 [self headerRefreshEvent];
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

#pragma mark - 分享
- (void)toShare:(FKXSameMindModel *)cellModel {
    FKXBaseShareView *shareV = [[FKXBaseShareView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrlStr:cellModel.head urlStr:[NSString stringWithFormat:@"%@front/comment.html?worryId=%@&token=%@&uid=%ld",kServiceBaseURL,cellModel.worryId,  [FKXUserManager shareInstance].currentUserToken, (long)[FKXUserManager shareInstance].currentUserId] title:[NSString stringWithFormat:@"伐开心|%@", cellModel.text] text:@"来自伐开心"];
    [shareV createSubviews];
}

#pragma mark - 举报，换头像，换北京
- (void)toChang:(FKXSameMindModel *)cellModel {
    UIAlertController *alV = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                          {
                              NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
                              [paramDic setValue:@(10) forKey:@"type"];
                              [paramDic setValue:cellModel.uid forKey:@"uid"];
                              [paramDic setValue:@"用户举报-共鸣" forKey:@"reason"];
                              [self showHudInView:self.view hint:@"正在举报..."];
                              [AFRequest sendGetOrPostRequest:@"sys/report"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                               {
                                   [self hideHud];
                                   if ([data[@"code"] integerValue] == 0)
                                   {
                                       [self showAlertViewWithTitle:@"举报成功"];
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
                              
                          }];
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                          {
                              
                          }];
    
    [alV addAction:ac1];
    [alV addAction:ac2];
    
    if ([FKXUserManager shareInstance].currentUserId == [cellModel.uid integerValue]) {
        UIAlertAction *ac3 = [UIAlertAction actionWithTitle:@"置顶" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
                                  [paramDic setValue:cellModel.worryId forKey:@"worryId"];
                                  [self showHudInView:self.view hint:@"正在处理..."];
                                  [AFRequest sendGetOrPostRequest:@"worry/top"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                                   {
                                       [self hideHud];
                                       if ([data[@"code"] integerValue] == 0)
                                       {
                                           [self showHint:@"已经置顶"];
                                           [self headerRefreshEvent];
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
                              }];
        [alV addAction:ac3];
    }
    else{
        if (cellModel.checkedPendant.length || cellModel.listenerPendant) {
            UIAlertAction *ac4 = [UIAlertAction actionWithTitle:@"使用ta的头饰" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                  {
                                      FKXMyShopVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyShopVC"];
                                      [vc setHidesBottomBarWhenPushed:YES];
                                      [self.navigationController pushViewController:vc animated:YES];
                                  }];
            [alV addAction:ac4];
        }
        if (cellModel.checkedBackground.length || cellModel.listenerBackground) {
            UIAlertAction *ac5 = [UIAlertAction actionWithTitle:@"使用ta的背景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                  {
                                      FKXMyShopVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyShopVC"];
                                      [vc setHidesBottomBarWhenPushed:YES];
                                      [self.navigationController pushViewController:vc animated:YES];
                                  }];
            [alV addAction:ac5];
        }
    }
    
    [self presentViewController:alV animated:YES completion:nil];

}

#pragma mark - 跳转评论HTML
- (void)toComment:(FKXSameMindModel *)cellModel {
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"comment";
    vc.pageType = MyPageType_nothing;
    vc.urlString = [NSString stringWithFormat:@"%@front/comment.html?worryId=%@&uid=%ld&token=%@",kServiceBaseURL,cellModel.worryId, (long)[FKXUserManager shareInstance].currentUserId,  [FKXUserManager shareInstance].currentUserToken];
    vc.sameMindModel = cellModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 跳转语音HTML
- (void)toVoice:(FKXSameMindModel *)cellModel {
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.isNeedTwoItem = YES;
    //这里都是已经被认可的，直接传1
    vc.pageType = MyPageType_nothing;
    vc.shareType = @"second_ask";
    NSString *paraStr = @"worryId";//默认传worryId
    NSNumber *paraId;
    if (cellModel.worryId) {
        paraId = cellModel.worryId;
    }
    if (cellModel.topicId) {
        paraStr = @"topicId";
        paraId = cellModel.topicId;
    }
    if (cellModel.lqId) {
        paraStr = @"lqId";
        paraId = cellModel.lqId;
    }
    vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=1&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, cellModel.voiceId, [FKXUserManager shareInstance].currentUserToken];
//    vc.secondModel = cellModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - 求助
- (void)ClickHelp {
    FKXPublishMindViewController *vc = [[UIStoryboard storyboardWithName:@"FKXMind" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXPublishMindViewController"];
    FKXBaseNavigationController *nav = [[FKXBaseNavigationController alloc] initWithRootViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (UIButton *)helpBtn {
    if (!_helpBtn) {
        _helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _helpBtn.frame = CGRectMake(kScreenWidth-40-17, kScreenHeight-49-26-40, 40, 40);
        _helpBtn.alpha = 0.7;
        [_helpBtn setBackgroundImage:[UIImage imageNamed:@"img_helpBtn"] forState:UIControlStateNormal];
        [_helpBtn addTarget:self action:@selector(ClickHelp) forControlEvents:UIControlEventTouchUpInside];
    }
    return _helpBtn;
}

@end
