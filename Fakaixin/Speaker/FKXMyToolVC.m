//
//  FKXMyToolVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/5.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyToolVC.h"
#import "FKXMyToolCell.h"
#import "FKXShopModel.h"
#import "FKXPayView.h"

@interface FKXMyToolVC ()<FKXMyToolCellProtocol,BeeCloudDelegate>
{
    NSMutableArray *dataSources;
    UIView *transViewPay;   //支付的透明图
    FKXPayView *payView;    //支付界面
    NSMutableDictionary *_payParameterDic;//支付参数
}

@end

@implementation FKXMyToolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置支付代理,记得要在支付页面写上这句话，否则支付成功后不走代理方法
    [BeeCloud setBeeCloudDelegate:self];
    _payParameterDic = [NSMutableDictionary dictionaryWithCapacity:1];
    dataSources = [NSMutableArray arrayWithCapacity:1];
    
    [self loveMarketInfo];
    
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 网络请求
- (void)headerRefreshEvent
{
    [self loveMarketInfo];
}
- (void)buyStamp:(FKXMyToolCell *)cell
{
    [self showHudInView:self.view hint:@"正在处理"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    paramDic[@"marketId"] = cell.model.marketId;
    paramDic[@"money"] = cell.model.money;
    [AFRequest sendGetOrPostRequest:@"loveMarket/buyStamp" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             _payParameterDic[@"billNo"] = data[@"data"][@"billNo"];
             _payParameterDic[@"money"] = data[@"data"][@"money"];
             _payParameterDic[@"isAmple"] = data[@"data"][@"isAmple"];
             [self setUpTransViewPay];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else{
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
- (void)loveMarketBuy:(FKXMyToolCell *)cell
{
    [self showHudInView:self.view hint:@"正在兑换"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    paramDic[@"marketId"] = cell.model.marketId;
    [AFRequest sendGetOrPostRequest:@"loveMarket/buy" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"兑换成功"];
             [self loveMarketInfo];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else{
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
- (void)loveMarketInfo
{
    NSDictionary *paramDic = @{@"uid":@([FKXUserManager shareInstance].currentUserId),
                               @"type":@(_type)};
    
    [FKXShopModel sendGetOrPostRequest:@"loveMarket/info" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.tableView.header.state = MJRefreshHeaderStateIdle;
         if ([data[@"code"] integerValue] == 0)
         {
             NSString *love = [NSString stringWithFormat:@"爱心值：%@",[data[@"data"][@"currentLove"] stringValue]];
             _shopVC.love = data[@"data"][@"currentLove"];
             NSMutableAttributedString * attS = [[NSMutableAttributedString alloc] initWithString:love];
             [attS addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xfe9595) range:[love rangeOfString:[data[@"data"][@"currentLove"] stringValue]]];
             [_shopVC.labLoveValue setAttributedText:attS];
             
             [dataSources removeAllObjects];
             NSError *err = nil;
             for (NSDictionary *subDic in data[@"data"][@"list"]) {
                 FKXShopModel *model = [[FKXShopModel alloc] initWithDictionary:subDic error:&err];
                 [dataSources addObject:model];
             }
             [self.tableView reloadData];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else{
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
     }];
}
/*- (void)loveMarketUse:(FKXMyToolCell *)cell
{
    [self showHudInView:self.view hint:@"正在使用..."];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    paramDic[@"marketId"] = cell.model.marketId;
    [AFRequest sendGetOrPostRequest:@"loveMarket/use" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             [self showHint:@"使用成功"];
             [self loveMarketInfo];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}*/
#pragma mark - cell 自定义代理
- (void)clickCellBtn:(UIButton *)butt withCell:(FKXMyToolCell *)cell
{
    if ([cell.btnChange.titleLabel.text isEqualToString:@"兑换"]) {
        [self loveMarketBuy:cell];
    }else
    {
        //点击需要支付的界面，如果没有安装微信，不进行下一步
//        if (![WXApi isWXAppInstalled]) {
//            [self showHint:@"当前不在线"];
//            return;
//        }
        [self buyStamp:cell];
    }
}
#pragma mark - tableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSources.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXShopModel *model = dataSources[indexPath.row];
    FKXMyToolCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXMyToolCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = model;
    return cell;
}
#pragma mark - 支付流程  --start
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
        [payView.myPayBtn addTarget:self action:@selector(confirmToPay) forControlEvents:UIControlEventTouchUpInside];
        
        if (_payParameterDic[@"isAmple"]) {
            if (![_payParameterDic[@"isAmple"] integerValue]) {
                payView.btnRemain.enabled = NO;
                [payView.btnRemain setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
        
        [transViewPay addSubview:payView];
        payView.center = transViewPay.center;
        
        [UIView animateWithDuration:0.5 animations:^{
            transViewPay.alpha = 1.0;
        }];
        
        payView.labTitle.text = @"邮票";
        payView.labPrice.text = [NSString stringWithFormat:@"%.2f", [_payParameterDic[@"money"] doubleValue]/100];
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
            [paramDic setValue:_payParameterDic[@"billNo"] forKey:@"billNo"];
            NSString *methodName = @"sys/balancePay";
            [AFRequest sendGetOrPostRequest:methodName param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
             {
                 [self hideHud];
                 if ([data[@"code"] integerValue] == 0)
                 {
                     [self showHint:@"邮票购买成功，去写一封信吧"];
                     [self loveMarketInfo];
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
    [self doPay:channel billNo:_payParameterDic[@"billNo"] money:_payParameterDic[@"money"]];

    [self hiddentransViewPay];
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
#pragma mark - 支付流程  --end
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
                switch (_type) {
                    case 0:
                        [self showHint:@"兑换成功"];
                        break;
                    case 2:
                        [self showHint:@"邮票购买成功，去写一封信吧"];
                        break;
                        
                    default:
                        break;
                }
                [self loveMarketInfo];
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
