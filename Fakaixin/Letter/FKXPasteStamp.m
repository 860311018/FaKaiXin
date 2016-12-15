//
//  FKXPasteStamp.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPasteStamp.h"
#import "FKXMyShopVC.h"
#import "FKXPublishLetterVC.h"

@interface FKXPasteStamp ()
{
    UIButton *navSaveItem;
}
@property (weak, nonatomic) IBOutlet UILabel *labRemind;
@property (weak, nonatomic) IBOutlet UIButton *btnExchange;

@end

@implementation FKXPasteStamp

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadStampNum];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitle = @"贴邮票";
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"没有邮票了？点击这里兑换" attributes:@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
    [_btnExchange.titleLabel setAttributedText:str];
    
    [self setUpNavBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpNavBar
{
    navSaveItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 18)];
    [navSaveItem setTitle:@"发送" forState:UIControlStateNormal];
    navSaveItem.titleLabel.font = [UIFont systemFontOfSize:15];
    //有邮票了发送颜色是 51b5ff
    [navSaveItem addTarget:self action:@selector(sendLetter) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navSaveItem];
    [navSaveItem setTitleColor:UIColorFromRGB(0xd2d2d2) forState:UIControlStateNormal];
    [navSaveItem setTitleColor:UIColorFromRGB(0x51b5ff) forState:UIControlStateSelected];
    navSaveItem.userInteractionEnabled = NO;
}
- (IBAction)goToBuyStamp:(id)sender
{
    FKXMyShopVC *vc = [[UIStoryboard storyboardWithName:@"Consulting" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXMyShopVC"];
    [vc clickTool:nil];
    [vc clickStamp:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)loadStampNum
{
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [AFRequest sendGetOrPostRequest:@"write/stampNum"param:paraDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             NSInteger num = [data[@"data"][@"stampNum"] integerValue];
             NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
             style.lineSpacing = 9;
             if (num) {
                 navSaveItem.userInteractionEnabled = YES;
                 navSaveItem.selected = YES;
                 NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"邮票已经贴好，现在点击寄信明天就能收到我们的回信了。以及在故事区看看别人怎么说。" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x333333)}];
                 _labRemind.attributedText = attStr;
             }else{
                 navSaveItem.userInteractionEnabled = NO;
                 navSaveItem.selected = NO;
                 NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"你没有邮票了需要购买噢！" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorFromRGB(0x333333)}];
                 _labRemind.attributedText = attStr;
             }
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }
         else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
- (void)sendLetter
{
    [self showHudInView:self.view hint:@"正在发送..."];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [paraDic setObject:_paraDic[@"writeId"] forKey:@"id"];
    [AFRequest sendGetOrPostRequest:@"write/useStamp"param:paraDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data)
     {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         if ([data[@"code"] integerValue] == 0)
         {
             //移除保存在本地的信件内容
             NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
             [def removeObjectForKey:@"myLetterContent"];
             [def synchronize];
             FKXPublishLetterVC *vc = [self.navigationController viewControllers][0];
             [vc dismissViewControllerAnimated:YES completion:^{
                 [self showAlertViewWithTitle:@"信件已发出，明天您就能收到回信了"];
             }];
         }else if ([data[@"code"] integerValue] == 4)
         {
             [self showAlertViewWithTitle:data[@"message"]];
             [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
         }
         else
         {
             [self showHint:data[@"message"]];
         }
     } failure:^(NSError *error) {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [self hideHud];
         [self showAlertViewWithTitle:@"网络出错"];
     }];
}
@end
