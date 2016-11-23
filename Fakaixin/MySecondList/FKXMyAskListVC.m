//
//  FKXMyAskListVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyAskListVC.h"
#import "NSString+HeightCalculate.h"
#import "FKXMyAskListCell.h"
#import "FKXPayView.h"
#import "FKXCommitHtmlViewController.h"
#import "ContinueAskView.h"
#import "UITextView+Placeholder.h"
#import "FKXPublishMindViewController.h"
#import "FKXProfessionInfoVC.h"
#import "MindRemindView.h"
#import "FKXCustomAcceptHtmlVC.h"
#import "FKXMyAskListLetterCell.h"
#import "FKXReplyLetterVC.h"

#define kFontOfContent 15

@interface FKXMyAskListVC ()<FKXMyAskListCellDelegate,BeeCloudDelegate, UIAlertViewDelegate>
{
    NSInteger start;
    NSInteger size;
    CGFloat oneLineH;   //一行的高度
    
    UIView *transViewPay;   //支付的透明图
    FKXPayView *payView;    //支付界面
    
    UIView *transView;   //透明图
    ContinueAskView *continueAskView;    //追问界面
    FKXEmptyData *emptyDataView;    //空数据
    
    UIView *transViewRemind;   //透明图
    MindRemindView *mindRemindV;    //每日提醒界面
    FKXSecondAskModel *currentModel;//当前点击的model
    
    NSString *alertStr;//支付成功的提示，需要展示后台返回的
}
@property(nonatomic, strong)NSMutableDictionary * payParameterDic;

@property   (nonatomic,strong)NSMutableArray *contentArr;

@end

@implementation FKXMyAskListVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self headerRefreshEvent];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [BeeCloud setBeeCloudDelegate:self];
    //基本赋值
    _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
    _contentArr = [NSMutableArray arrayWithCapacity:1];
    size = kRequestSize;
    CGRect screen = [UIScreen mainScreen].bounds;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    oneLineH = [@"哈" heightForWidth:screen.size.width - 24 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    
    //ui设置
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    
    [self setUptransViewRemind];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSDictionary *paramDic;
    
    paramDic = @{@"type":@(0),@"start":@(start), @"size":@(size)};
    [AFRequest sendGetOrPostRequest:@"voice/meQuestion" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         self.tableView.footer.state = MJRefreshFooterStateIdle;
         
         NSError *err = nil;
         if ([data[@"code"] integerValue] == 0)
         {
             if (start == 0)
             {
                 [_contentArr removeAllObjects];
                 
                 if ([data[@"data"][@"list"] count] == 0) {
                     [self createEmptyData];
                 }else{
                     if (emptyDataView) {
                         [emptyDataView removeFromSuperview];
                         emptyDataView = nil;
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
#pragma  mark - 每日提醒
- (void)setUptransViewRemind
{
    NSDate *date = [NSDate date];
    NSString *dateS = [date.description substringToIndex:10];
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@AskList", dateS]];
    if (!key) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"%@AskList", dateS]];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (!transViewRemind)
        {
            //透明背景
            transViewRemind = [[UIView alloc] initWithFrame:screenBounds];
            transViewRemind.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            transViewRemind.alpha = 0.0;
            [[UIApplication sharedApplication].keyWindow addSubview:transViewRemind];
            
            mindRemindV = [[[NSBundle mainBundle] loadNibNamed:@"MindRemindView" owner:nil options:nil] firstObject];
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
    }];
}
#pragma mark - UI
- (void)createEmptyData
{
    if (!emptyDataView) {
        emptyDataView = [[NSBundle mainBundle] loadNibNamed:@"FKXEmptyData" owner:nil options:nil][0];
        emptyDataView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
        [emptyDataView.btnDeal addTarget:self action:@selector(clickBtnDeal) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:emptyDataView];
        emptyDataView.titleLab.text = @"你还没有提问哦~";
        [emptyDataView.btnDeal setTitle:@" 去问一个" forState:UIControlStateNormal];
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
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [model.text heightForWidth:screen.size.width - 52 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    switch ([model.isAccept integerValue]) {
        case -1:
        case -2:
        case 2://没有倾听者的信息
            return 44 + height;
            break;
        case 4:
        case 5:
            return 140;
            break;
        default://有倾听者的信息
            return 106 + height;
            break;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];

    if ([model.isAccept integerValue] == 4 || [model.isAccept integerValue] == 5) {
        FKXMyAskListLetterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyAskListLetterCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else{
        
        FKXMyAskListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyAskListCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.model = model;
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];
    if ([model.isAccept integerValue] == 0) {//需要展示认可
        FKXCustomAcceptHtmlVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXCustomAcceptHtmlVC"];
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
        vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=%d&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, model.voiceId,0, [FKXUserManager shareInstance].currentUserToken];
        vc.secondModel = model;
        
        //传相关的支付需要的参数
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
        dic[@"voiceId"] = model.voiceId;
        vc.payParameterDic = dic;
        
        vc.isShowAlert = [model.isAccept integerValue] ? NO : YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([model.isAccept integerValue] == 4 || [model.isAccept integerValue] == 5)
    {
         FKXReplyLetterVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil]instantiateViewControllerWithIdentifier:@"FKXReplyLetterVC"];
        vc.secondAskModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        if (!([model.isAccept integerValue] == 2 ||[model.isAccept integerValue] == -1)) {
            FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
            vc.isNeedTwoItem = YES;
            FKXSecondAskModel *model = [self.contentArr objectAtIndex:indexPath.row];
            vc.shareType = @"second_ask";
            vc.pageType = MyPageType_agree;
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
            NSInteger agree = 1;
            if ([model.isAccept integerValue] == -1 ||[model.isAccept integerValue] == -2) {
                agree = 0;
            }
            vc.urlString = [NSString stringWithFormat:@"%@front/QA_a_detail.html?%@=%@&uid=%ld&voiceId=%@&IsAgree=%ld&token=%@",kServiceBaseURL,paraStr, paraId, (long)[FKXUserManager shareInstance].currentUserId, model.voiceId,agree, [FKXUserManager shareInstance].currentUserToken];
            vc.secondModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
#pragma mark - cell自定义代理
- (void)goToAgree:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender
{
    if ([sender.titleLabel.text isEqualToString:@"去追问"])
    {
        [self setUpTransViewWithModel:cellModel];
    }
}
- (void)goToReport:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender
{
    UIAlertController *alV = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action2;
    if (cellModel.worryId) {
        action2 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                   {
                       currentModel = cellModel;
                       UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"确定要删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                       alert.tag = 100;
                       [alert show];
                   }];
    }
    
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                          {
                              NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
                              [paramDic setValue:@(11) forKey:@"type"];
                              [paramDic setValue:cellModel.listenerId forKey:@"uid"];
                              [paramDic setValue:@"用户举报了“我问”列表" forKey:@"reason"];
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
    
    UIAlertAction *ac3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                          {
                              
                          }];
    
    if (cellModel.worryId) {
        [alV addAction:action2];
    }
    [alV addAction:ac1];
    [alV addAction:ac3];
    //如果这条是心事，并且没有过期
    if (cellModel.worryId && ([cellModel.isAccept integerValue] != -1 && [cellModel.isAccept integerValue] != -2)) {
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
    
    [self presentViewController:alV animated:YES completion:nil];
}
- (void)goToDynamicVC:(FKXSecondAskModel*)cellModel sender:(UIButton*)sender
{
    FKXProfessionInfoVC *vc = [[FKXProfessionInfoVC alloc]init];
    [vc setHidesBottomBarWhenPushed:YES];
    if (cellModel.worryId) {
        vc.userId = cellModel.userId;
    }else{
        vc.userId = cellModel.listenerId;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:currentModel.worryId forKey:@"worryId"];
            [self showHudInView:self.view hint:@"正在删除..."];
            [AFRequest sendGetOrPostRequest:@"worry/delete"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     [self showHint:@"已删除"];
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
        }
    }
}
#pragma  mark - 追问界面
- (void)setUpTransViewWithModel:(FKXSecondAskModel*)cellModel
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (!transView)
    {
        //透明背景
        transView = [[UIView alloc] initWithFrame:screenBounds];
        transView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        transView.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow addSubview:transView];
        
        continueAskView = [[[NSBundle mainBundle] loadNibNamed:@"ContinueAskView" owner:nil options:nil] firstObject];
        continueAskView.model = cellModel;
        continueAskView.myTeV.placeholder = [NSString stringWithFormat:@"向%@提问，等ta语音回答；公开问题公开追问",cellModel.listenerNickName];
        [continueAskView.btnDone addTarget:self action:@selector(clickToContinueAsk) forControlEvents:UIControlEventTouchUpInside];
        [continueAskView.btnClose addTarget:self action:@selector(hiddentransView) forControlEvents:UIControlEventTouchUpInside];
        [transView addSubview:continueAskView];
        continueAskView.center = transView.center;
        CGRect frame = continueAskView.frame;
        frame.origin.y = 150;
        continueAskView.frame = frame;
        [UIView animateWithDuration:0.5 animations:^{
            transView.alpha = 1.0;
        }];
    }
}
- (void)hiddentransView
{
    [UIView animateWithDuration:0.5 animations:^{
        transView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transView removeFromSuperview];
        transView = nil;
    }];
}
- (void)clickToContinueAsk
{
    /**
     *  url: 	voice/question_closely
     request:{
     uid: 12,      //倾听者的id，被追问人
     text："追问的内容"
     }
     response:{
     code: 0,
     message:""
     
     }
     */
    
    [continueAskView.myTeV resignFirstResponder];
    NSString *con = [continueAskView.myTeV.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!con.length) {
        [self showAlertViewWithTitle:@"请输入内容"];
        return;
    }
    [self hiddentransView];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:continueAskView.model.worryId forKey:@"worryId"];
    [paramDic setValue:continueAskView.myTeV.text forKey:@"text"];
    [paramDic setValue:continueAskView.model.listenerId forKey:@"uid"];
    NSString *methodName = @"voice/question_closely";
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"追问成功"];
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
}
#pragma mark - 支付流程 start
- (void)setUpTransViewPay:(NSNumber *)money
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
        [payView.myPayBtn addTarget:self action:@selector(confirmToPay) forControlEvents:UIControlEventTouchUpInside];
        [transViewPay addSubview:payView];
        payView.center = transViewPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewPay.alpha = 1.0;
        }];
        payView.labTitle.text = @"认可";
        payView.labPrice.text = [NSString stringWithFormat:@"￥%@", money];
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
- (void)confirmToPay
{
    [self hiddentransViewPay];
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
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [paramDic setValue:_payParameterDic[@"voiceId"] forKey:@"voiceId"];
            [paramDic setValue:_payParameterDic[@"acceptMoney"] forKey:@"acceptMoney"];
            
            NSString *methodName = @"voice/accept";
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     alertStr = data[@"data"][@"alert"];
                     //获取billNO成功后，调用余额支付
                     NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
                     [paramDic setValue:data[@"data"][@"billNo"] forKey:@"billNo"];
                     NSString *methodName = @"sys/balancePay";
                     [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                      {
                          [self hideHud];
                          if ([data[@"code"] integerValue] == 0)
                          {
                              [self showHint:alertStr];
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
        }
            break;
        default:
            break;
    }
    if (payView.myPayChannel == MyPayChannel_remain) {
        return;
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_payParameterDic[@"acceptMoney"] forKey:@"acceptMoney"];
    [paramDic setValue:_payParameterDic[@"voiceId"] forKey:@"voiceId"];
    NSString *methodName = @"voice/accept";
    [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             alertStr = data[@"data"][@"alert"];
             [self doPay:channel billNo:data[@"data"][@"billNo"] money:data[@"data"][@"money"]];
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
}
//微信、支付宝
- (void)doPay:(PayChannel)channel billNo:(NSString *)billNo money:(NSNumber *)money {
    
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"伐开心订单";//billTitle;
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
#pragma mark - 支付流程  --end
#pragma mark - BeeCloudDelegate
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    switch (resp.type) {
        case BCObjsTypePayResp:
        {
            // 支付请求响应
            BCPayResp *tempResp = (BCPayResp *)resp;
            if (tempResp.resultCode == 0)
            {
                [self showHint:alertStr];
                [self headerRefreshEvent];
                //微信、支付宝、银联支付成功
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
@end
