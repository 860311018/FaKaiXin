//
//  FKXContactUsTableViewController.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/1/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXContactUsTableViewController.h"
#import "FKXUserInfoModel.h"
#import "UITextView+Placeholder.h"


@interface FKXContactUsTableViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *tfInput;
@property (weak, nonatomic) IBOutlet UIButton *btnCommit;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation FKXContactUsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _btnCommit.layer.cornerRadius = 3.0;
    _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setTitleViewOfNavigationItem:@"吐槽我们"];
    _textView.placeholder = @"我们非常重视您提出的任何意见,请鞭挞我吧!";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 点击事件
- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clickCommit:(id)sender {
    [_tfInput resignFirstResponder];
    [_textView resignFirstResponder];
    
    if (!_textView.text.length) {
        [self showHint:@"请输入意见"];
        return;
    }
    
    NSDictionary *paramDic = @{@"text" : _textView.text};
    
    [AFRequest sendGetOrPostRequest:@"sys/feedback"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         [self hideHud];
            if ([data[@"code"] integerValue] == 0) {
                [self showAlertViewWithTitle:@"吐槽成功"];

                [self.navigationController popViewControllerAnimated:YES];
            }
            else if ([data[@"code"] integerValue] == 4)
            {
                [self showAlertViewWithTitle:data[@"message"]];
                [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
            }else
            {
                [self showAlertViewWithTitle:data[@"message"]];
            }
    } failure:^(NSError *error) {
        [self showHint:@"网络出错"];
        [self hideHud];
    }];
}
@end
