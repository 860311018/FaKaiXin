//
//  FKXReportTwoStepController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/6.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXReportTwoStepController.h"
#import "FKXUserInfoModel.h"

@interface FKXReportTwoStepController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation FKXReportTwoStepController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"举报";
    
    //按钮
    UIButton * rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItem.frame = CGRectMake(0,0,30,12);
    rightItem.backgroundColor = [UIColor clearColor];
    [rightItem setTitle:@"提交" forState:UIControlStateNormal];
    rightItem.titleLabel.font = kFont_F4();
    [rightItem setTitleColor:kColorMainBlue forState:UIControlStateNormal];
    [rightItem addTarget:self action:@selector(clickCommit:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItem];
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
#pragma mark - textViewDele
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark - 点击事件
- (IBAction)clickCommit:(id)sender {

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDic setValue:@(_reportType) forKey:@"type"];
    [paramDic setValue:_toUid forKey:@"uid"];
    [paramDic setValue:_textView.text ? _textView.text : @"" forKey:@"reason"];
    [self showHudInView:self.view hint:@"正在提交..."];
    [AFRequest sendGetOrPostRequest:@"sys/report"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
             
         {
             NSArray *vcs = [self.navigationController viewControllers];
             NSInteger index = vcs.count - 4;
             [self.navigationController popToViewController:vcs[index] animated:YES];
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
}

@end
