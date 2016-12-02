//
//  FKXMyOderDetailVC.m
//  Fakaixin
//
//  Created by apple on 2016/12/1.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyOderDetailVC.h"
#import "FKXOrderModel.h"

#import "FKXEvaluateVC.h"
#import "FKXCommitHtmlViewController.h"
#import "FKXNotifcationModel.h"

@interface FKXMyOderDetailVC ()

@property (weak, nonatomic) IBOutlet UILabel *yuyueTimeL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *zixunL;
@property (weak, nonatomic) IBOutlet UILabel *zixunDetail;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;

@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation FKXMyOderDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navTitle = @"我的订单";
    
    [self setUpBtn];
    
}

- (IBAction)oneBtnClick:(id)sender {
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 1){
            //去服务
            if (self.model.callLength && [self.model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:self.model];
            }else {
                //图文咨询
                [self toTuWen:self.model];
            }
        }else if ([self.model.status integerValue] == 4) {
            //去看评价
            [self toCommenViewt:self.model];
        }
    }else{
        if ([self.model.status integerValue] == 0){
            //私信
            [self toChatVC:self.model];
        }
         else if ([self.model.status integerValue] == 1) {
            //立即咨询
            if (self.model.callLength && [self.model.callLength integerValue]!=0) {
                //电话咨询
                [self toCall:self.model];
            }else {
                //图文咨询
                [self toTuWen:self.model];
            }
        }
        else if ([self.model.status integerValue] == 2) {
            //立即评价
            [self toComment:self.model];

        }else if ([self.model.status integerValue] == 4) {
            //再次预约
            if (self.model.callLength && [self.model.callLength integerValue]!=0) {
                //电话咨询
                [self callOrder:self.model];
            }else {
                //图文咨询
                [self tuwenOrder:self.model];
            }
        }
    }
}

- (IBAction)cancelClick:(id)sender {
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 0){
            //拒绝订单
            [self operationOrder:self.model status:@3];
        }
    }
}

- (IBAction)confirmBtnClick:(id)sender {
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 0){
            //确认订单
            [self operationOrder:self.model status:@1];
        }
    }
}

- (void)setUpBtn {
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:self.model.headUrl] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nameL.text = self.model.nickName;
    
    
    if (self.model.callLength) {
        self.zixunL.text = @"电话咨询";
        NSInteger minute = [self.model.callLength integerValue];
        self.yuyueTimeL.text = [NSString stringWithFormat:@"预约时间：%ld分钟",minute];

    }else {
        self.zixunL.text = @"图文咨询";
        self.yuyueTimeL.text = @"预约时间：60分钟";
    }
    
    
    if (self.isWorkBench) {
        if ([self.model.status integerValue] == 0) {
            self.statusL.text = @"已付款";
            
            self.bottomView.hidden = NO;
            self.oneBtn.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.commentBtn.hidden = NO;
            [self.cancelBtn setTitle:@"拒绝订单" forState:UIControlStateNormal];
            [self.commentBtn setTitle:@"接受订单" forState:UIControlStateNormal];
        }else if ([self.model.status integerValue] == 1) {
            
            self.statusL.text = @"进行中";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"去服务" forState:UIControlStateNormal];

        }else if ([self.model.status integerValue] == 2) {
            self.statusL.text = @"待评价";
            
            self.bottomView.hidden = YES;
            
        }else if ([self.model.status integerValue] == 3) {
            self.statusL.text = @"已拒绝";

            self.bottomView.hidden = YES;

        }else if ([self.model.status integerValue] == 4) {
            self.statusL.text = @"已评价";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"去看评价" forState:UIControlStateNormal];
 
        }
    }else {
        if ([self.model.status integerValue] == 0) {
            self.statusL.text = @"待确认";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"私信TA" forState:UIControlStateNormal];
            
        }else if ([self.model.status integerValue] == 1) {
            self.statusL.text = @"进行中";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"立即咨询" forState:UIControlStateNormal];
        }else if ([self.model.status integerValue] == 2) {
            self.statusL.text = @"待评价";

            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"立即评价" forState:UIControlStateNormal];
        }else if ([self.model.status integerValue] == 3) {
            self.statusL.text = @"已拒绝";

            self.bottomView.hidden = YES;
        }else if ([self.model.status integerValue] == 4) {
            self.statusL.text = @"已完成";
            
            self.bottomView.hidden = NO;
            self.oneBtn.hidden = NO;
            self.cancelBtn.hidden = YES;
            self.commentBtn.hidden = YES;
            [self.oneBtn setTitle:@"再次预约" forState:UIControlStateNormal];
        }
    }
    
}


#pragma mark - 操作订单（拒绝、接受）
- (void)operationOrder:(FKXOrderModel *)model status:(NSNumber *)status {
    NSNumber *type = @0;
    if (model.callLength && [model.callLength integerValue]!=0) {
        type = @1;
    }
    NSDictionary *params = @{@"orderId":model.orderId,@"type":type,@"status":status};
    
    [AFRequest sendGetOrPostRequest:@"listener/updateOrders" param:params requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue]==0) {
            self.model.status = status;
            [self setUpBtn];
        }else {
            [self showHint:data[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:@"网络出错"];
    }];
}

#pragma mark - 电话咨询（已经付款）
- (void)toCall:(FKXOrderModel *)model {
    
}

#pragma mark - 图文咨询（聊天页，已确认订单）
- (void)toTuWen:(FKXOrderModel *)model {
    
}

#pragma mark - 下电话订单 （再次预约）
- (void)callOrder:(FKXOrderModel *)model {
    
}

#pragma mark - 下图文订单 （再次预约）
- (void)tuwenOrder:(FKXOrderModel *)model {
    
}

#pragma mark - 私信（未确认订单）
- (void)toChatVC:(FKXOrderModel *)model {
    
}

#pragma mark - 去评价
- (void)toComment:(FKXOrderModel *)model {
    FKXEvaluateVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXEvaluateVC"];
    FKXNotifcationModel *noModel = [[FKXNotifcationModel alloc]init];
    noModel.fromId =model.listenerId;
    noModel.fromHeadUrl = model.headUrl;
    noModel.fromNickname = model.nickName;
    if (model.callLength && [model.callLength integerValue]!=0) {
        noModel.type = @2;
    }else {
        noModel.type = @1;
    }
    vc.model = noModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 去看评价
- (void)toCommenViewt:(FKXOrderModel *)model {
    FKXCommitHtmlViewController *vc = [[FKXCommitHtmlViewController alloc] init];
    vc.shareType = @"user_center_yu_yue";//预约
    vc.pageType = MyPageType_consult;
    FKXUserInfoModel *userModel = [FKXUserManager getUserInfoModel];
    vc.urlString = [NSString stringWithFormat:@"%@front/user_center.html?uid=%@&token=%@",kServiceBaseURL, userModel.uid, [FKXUserManager shareInstance].currentUserToken];
    vc.userModel = userModel;
    //push的时候隐藏tabbar
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
