//
//  FKXServiceVC.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/30.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXServiceVC.h"

@interface FKXServiceVC ()

@property (weak, nonatomic) IBOutlet UITextField *tfAskPrice;
@property (weak, nonatomic) IBOutlet UITextField *tfConsultPrice;
@property (weak, nonatomic) IBOutlet UITextField *phonePrice;

@end

@implementation FKXServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"服务";
    _tfAskPrice.text = [NSString stringWithFormat:@"%ld", [_model.price integerValue]/100];
    _tfConsultPrice.text = [NSString stringWithFormat:@"%ld", [_model.consultingFee integerValue]/100];
    _phonePrice.text = [NSString stringWithFormat:@"%ld", [_model.phonePrice integerValue]/100];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
- (IBAction)btnSave:(id)sender {
    [_tfConsultPrice resignFirstResponder];
    [_tfAskPrice resignFirstResponder];
    [_phonePrice resignFirstResponder];
    
    if ([_tfAskPrice.text integerValue] < 1|| [_tfAskPrice.text integerValue] > 100) {
        [self showHint:@"提问价格需在1到100元之间"];
        return;
    }else if ([_tfConsultPrice.text integerValue] <= 0) {
        [self showHint:@"咨询费需大于0元"];
        return;
    }else if ([_phonePrice.text integerValue] <= 20) {
        [self showHint:@"咨询费需大于20元"];
        return;
    }
    
    NSDictionary *paramDic = @{@"price":@([_tfAskPrice.text integerValue]*100), @"consultingFee" : @([_tfConsultPrice.text integerValue]*100), @"phonePrice" : @([_phonePrice.text integerValue]*100)};
    
    [AFRequest sendGetOrPostRequest:@"user/edit"param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         if ([data[@"code"] integerValue] == 0)
         {
             FKXUserInfoModel *model = _model;
             model.price = @([_tfAskPrice.text integerValue]*100);
             model.consultingFee = @([_tfConsultPrice.text integerValue]*100);
             model.phonePrice = @([_phonePrice.text integerValue]*100);
             
             [FKXUserManager archiverUserInfo:model toUid:[model.uid stringValue]];
             [self.navigationController popViewControllerAnimated:YES];
         }else if ([data[@"code"] integerValue] == 4)
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    if (![string isEqualToString:@""])
    {
        const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
        if (*ch < 48 || *ch > 57) {
            return NO;
        }
    }
    return YES;
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

@end
