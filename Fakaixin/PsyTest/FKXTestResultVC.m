//
//  FKXTestResultVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/27.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXTestResultVC.h"
#import "NSString+Extension.h"
#import "FKXBaseShareView.h"
@interface FKXTestResultVC ()
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *resultTitle;

@property (weak, nonatomic) IBOutlet UITextView *resultDesc;

@property (weak, nonatomic) IBOutlet UIButton *zhunBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UITextView *inputTexV;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentCount;

@property (nonatomic,copy) NSString *resultTitleStr;
@property (nonatomic,copy) NSString *resultDesStr;

@end

@implementation FKXTestResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"心理测试";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self loadData];
    
}

- (void)loadData {
    NSDictionary *paramDic = @{@"type" : self.type,@"psyId":self.psyId};

    [AFRequest sendGetOrPostRequest:@"psy/result"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        NSLog(@"%@",data);
        NSDictionary *dic = data[@"data"];
        [self.headImgV sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"testBackground"]] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
        
        self.resultTitleStr = [dic objectForKey:@"result"];
        
        self.resultTitle.text = self.resultTitleStr;

        
        self.resultDesStr = [dic objectForKey:@"resultDescribe"];
        self.resultDesc.text = self.resultDesStr;
        
        int commentCountN = (int)[dic objectForKey:@"commentNum"];
        [self.commentCount setTitle:[NSString stringWithFormat:@"%d",commentCountN] forState:UIControlStateNormal];
        [self hideHud];

    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];

}
- (IBAction)zhunClick:(id)sender {
    
    NSDictionary *paramDic = @{@"psyId":self.psyId};

    [AFRequest sendGetOrPostRequest:@"psy/praise" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
        [self hideHud];
        if ([data[@"code"] integerValue] == 0)
        {
            [self showHint:@"成功"];
            
        }
        else if ([data[@"code"] integerValue] == 4)
        {
            [self showAlertViewWithTitle:data[@"message"]];
            [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        }else{
            [self showAlertViewWithTitle:data[@"message"]];
        }
     } failure:^(NSError *error) {
         [self showHint:@"网络出错"];
         [self hideHud];
     }];
}
- (IBAction)shareClick:(id)sender {
   
    NSString *title = self.testTitle;
    NSString *content = [NSString stringWithFormat:@"我的结果竟然是%@",self.resultTitleStr];
    NSString *imageUrl = @"";
    NSString *urlString = [NSString stringWithFormat:@"%@%@?token=%@",kServiceBaseURL, @"front/share.html?", kToken ? kToken : @""];

    FKXBaseShareView *shareV = [[FKXBaseShareView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrlStr:imageUrl urlStr:urlString title:title text:content];
    [shareV createSubviews];
}
- (IBAction)sendComment:(id)sender {
    if (![NSString isEmpty:_inputTexV.text]) {
       
        NSDictionary *paramDic = @{@"text" : _inputTexV.text,@"psyId":self.psyId};
        
        [AFRequest sendGetOrPostRequest:@"psy/comment" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
            [self hideHud];
            if ([data[@"code"] integerValue] == 0)
            {
                [self showHint:@"发表评论成功"];
                _inputTexV.text = @"";
//                [self headerRefreshEvent];
            }
            else if ([data[@"code"] integerValue] == 4)
            {
                [self showAlertViewWithTitle:data[@"message"]];
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
            }else{
                [self showAlertViewWithTitle:data[@"message"]];
            }
        } failure:^(NSError *error) {
            [self showHint:@"网络出错"];
            [self hideHud];
        }];
    }else {
        [self showAlertViewWithTitle:@"评论不能为空"];
    }

}

- (void)back {
    NSArray *vcArray = self.navigationController.viewControllers;
    [self.navigationController popToViewController:[vcArray objectAtIndex:1] animated:YES];
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
