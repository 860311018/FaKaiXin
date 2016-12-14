//
//  FKXEvaluateVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/9/1.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXEvaluateVC.h"

@interface FKXEvaluateVC ()<BeeCloudDelegate>
{
    NSInteger score;
    NSInteger money;
    NSInteger payType;
}
@property (weak, nonatomic) IBOutlet UIButton *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextView *myTextV;

@end

@implementation FKXEvaluateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"评价";
    score = 0;
    //设置支付代理
    [BeeCloud setBeeCloudDelegate:self];
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_model.fromHeadUrl, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _userName.text = _model.fromNickname;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击事件
//态度
- (IBAction)clickAttitude:(UIButton *)sender {
    //所有支付相关重置
    money = 0;
    payType = 0;
    [self clickReward:nil];
    [self clickPay:nil];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    for (UIView *sub in cell.contentView.subviews) {
        if ([sub isMemberOfClass:[UIView class]]) {
            for (UIButton *subBtn in sub.subviews) {
                if ([subBtn isMemberOfClass:[UIImageView class]]) {
                    continue;
                }
                subBtn.selected = NO;
            }
            break;
        }
    }
    sender.selected = YES;
    score = sender.tag - 101;
    
    [self.tableView reloadData];
}
//打赏
- (IBAction)clickReward:(UIButton *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    for (UIView *sub in cell.contentView.subviews) {
        if ([sub isMemberOfClass:[UIView class]]) {
            for (UIButton *subBtn in sub.subviews) {
                if ([subBtn isMemberOfClass:[UIImageView class]]) {
                    continue;
                }
                subBtn.selected = NO;
            }
            break;
        }
    }
    sender.selected = YES;
    switch (sender.tag) {
        case 100:
            money = 2;
            break;
        case 101:
            money = 5;
            break;
        case 102:
            money = 10;
            break;
        default:
            break;
    }
}
//支付方式
- (IBAction)clickPay:(UIButton *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    for (UIView *sub in cell.contentView.subviews) {
        if ([sub isMemberOfClass:[UIView class]]) {
            for (UIButton *subBtn in sub.subviews) {
                if ([subBtn isMemberOfClass:[UIImageView class]]) {
                    continue;
                }
                subBtn.selected = NO;
            }
            break;
        }
    }
    sender.selected = YES;
    payType = sender.tag;
}
- (IBAction)clickEvaluate:(UIButton *)sender {
    [_myTextV resignFirstResponder];
    NSString *string = [_myTextV.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!string.length) {
        [self showHint:@"请输入您的想法~"];
        return;
    }
    if (money &&!payType)//如果选择了金额
    {
        [self showHint:@"请选择支付方式"];
        return;
    }
    else if(!money && payType)
    {
        [self showHint:@"请选择打赏金额"];
        return;
    }
    [self showHudInView:self.view hint:@"正在评价..."];
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paraDic setValue:_model.fromId forKey:@"listenerId"];
    [paraDic setValue:string forKey:@"text"];
    [paraDic setValue:@(score) forKey:@"score"];
    [paraDic setValue:_type forKey:@"type"];

    
    [AFRequest sendGetOrPostRequest:@"listener/comment"param:paraDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
            if (money && payType)
                 [self loadReward:@(money)];
             else
                 [self.navigationController popViewControllerAnimated:YES];
         }
         else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }else
         {
             [self showHint:data[@"message"]];
         }
         [self hideHud];
         
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
#pragma mark - 打赏
- (void)loadReward:(NSNumber *)mon
{
    [self showHudInView:self.view hint:@"正在打赏..."];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:_model.fromId forKey:@"uid"];
    [paramDic setValue:@([mon integerValue]*100) forKey:@"money"];
    [AFRequest sendGetOrPostRequest:@"listener/reward" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             PayChannel channel;
             switch (payType) {
                case 100:
                    channel = PayChannelWxApp;
                     [self doPay:channel billNo:data[@"data"][@"billNo"] money:@([mon integerValue]*100)];
                     break;
                case 101://支付宝
                    channel = PayChannelAliApp;
                    [self doPay:channel billNo:data[@"data"][@"billNo"] money:@([mon integerValue]*100)];
                    break;
                case 102:
                {
                    NSString *methodName = @"sys/balancePay";
                    NSMutableDictionary *parD = [NSMutableDictionary dictionaryWithCapacity:1];
                    [parD setValue:data[@"data"][@"billNo"] forKey:@"billNo"];
                    [AFRequest sendGetOrPostRequest:methodName param:parD requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
                     {
                         [self hideHud];
                         if ([data[@"code"] integerValue] == 0)
                         {
                             [self showHint:@"支付成功"];
                             [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark - textViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}
#pragma mark - UITableViewcelldelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (score == -1) {
        if (indexPath.row == 2 || indexPath.row == 3) {
            return 0;
        }else if (indexPath.row == 0) {
            return 142;
        }else
            return 81;
    }else{
        if (indexPath.row == 0) {
            return 142;
        }else
            return 81;
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGPoint point = cell.center;
    switch (indexPath.row) {
        case 2:
        {
            cell.center = CGPointMake(-cell.width*3/2, point.y);
            [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                cell.center = CGPointMake(cell.width/2, cell.center.y);
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case 3:
        {
            cell.center = CGPointMake(cell.width*3/2, point.y);
            [UIView animateWithDuration:1 delay:0.5 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                cell.center = CGPointMake(cell.width/2, cell.center.y);
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case 4:
        {
            NSTimeInterval timeIn = 1;
            if (score == -1) {
                timeIn = 0;
            }
            cell.center = CGPointMake(-cell.width*3/2, point.y);
            [UIView animateWithDuration:1 delay:timeIn usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                cell.center = CGPointMake(cell.width/2, cell.center.y);
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - BeeCloudDelegate
//微信、支付宝
- (void)doPay:(PayChannel)channel billNo:(NSString *)billNo money:(NSNumber *)mon {
    [self showHudInView:self.view hint:@"正在支付..."];
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"伐开心订单";
    payReq.totalFee = [NSString stringWithFormat:@"%ld",[mon integerValue]];
    payReq.billNo = billNo;
    if (channel == PayChannelAliApp) {
        payReq.scheme = @"Zhifubaozidingyi001test";
    }
    payReq.billTimeOut = 360;
    payReq.viewController = self;
    payReq.optional = nil;
    [BeeCloud sendBCReq:payReq];
}
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    [self hideHud];
    switch (resp.type) {
        case BCObjsTypePayResp:
        {
            // 支付请求响应
            BCPayResp *tempResp = (BCPayResp *)resp;
            if (tempResp.resultCode == 0)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }else
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
