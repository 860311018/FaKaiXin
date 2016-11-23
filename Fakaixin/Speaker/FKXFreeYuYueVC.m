//
//  FKXFreeYuYueVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/14.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXFreeYuYueVC.h"
#import "NSString+Extension.h"

@interface FKXFreeYuYueVC ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (weak, nonatomic) IBOutlet UIButton *menBtn;
@property (weak, nonatomic) IBOutlet UIButton *womenBtn;

@property (weak, nonatomic) IBOutlet UIButton *hunlianBtn;
@property (weak, nonatomic) IBOutlet UIButton *shilianBtn;

@property (weak, nonatomic) IBOutlet UIButton *fuqiBtn;
@property (weak, nonatomic) IBOutlet UIButton *poxiBtn;

@property (nonatomic,strong) NSString *male;
@property (nonatomic,strong) NSNumber *sel;

@end

@implementation FKXFreeYuYueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navTitle = @"情感挽回";
    
    [self setUpUI];
}

- (void)nameChanged:(UITextField *)textField {
    
}

- (void)phoneChanged:(UITextField *)textField {
}

- (IBAction)selectMen:(id)sender {

    self.menBtn.selected = YES;
    self.womenBtn.selected = NO;
    self.male = @"男";
    
}
- (IBAction)selecWomen:(id)sender {

    self.menBtn.selected = NO;
    self.womenBtn.selected = YES;
    self.male = @"女";

}

- (IBAction)selectHunLian:(id)sender {
    self.hunlianBtn.selected = YES;
    self.shilianBtn.selected = NO;
    self.fuqiBtn.selected = NO;
    self.poxiBtn.selected = NO;
    self.sel = @1;
}
- (IBAction)selectShiLian:(id)sender {
    self.hunlianBtn.selected = NO;
    self.shilianBtn.selected = YES;
    self.fuqiBtn.selected = NO;
    self.poxiBtn.selected = NO;
    self.sel = @2;

}
- (IBAction)selectFuqi:(id)sender {
    self.hunlianBtn.selected = NO;
    self.shilianBtn.selected = NO;
    self.fuqiBtn.selected = YES;
    self.poxiBtn.selected = NO;
    self.sel = @3;

}
- (IBAction)selectPoxi:(id)sender {
    self.hunlianBtn.selected = NO;
    self.shilianBtn.selected = NO;
    self.fuqiBtn.selected = NO;
    self.poxiBtn.selected = YES;
    self.sel = @4;

}

- (IBAction)yuyueClick:(id)sender {
    if ([FKXUserManager needShowLoginVC]) {
         [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    
    if (![NSString isEmpty:self.nameTF.text]) {
        if (![NSString isEmpty:self.phoneTF.text]) {
            if ([self.phoneTF.text isRealPhoneNumber]) {
                if (self.male && self.sel) {
                    NSLog(@"%@",self.male);
                    NSLog(@"%@",self.sel);
                    NSLog(@"%@",self.nameTF.text);
                    NSLog(@"%@",self.phoneTF.text);

                }else {
                    [self showHint:@"请完善信息"];
   
                }
                
            }else {
                [self showHint:@"请输入正确手机号"];
  
            }
        }else {
            [self showHint:@"请输入您的手机号"];
        }
    }else {
        [self showHint:@"请输入您的姓名"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpUI {

    [self.menBtn setImage:[UIImage imageNamed:@"free_men_sel"] forState:UIControlStateSelected];
    [self.menBtn setTitleColor:[UIColor colorWithRed:73/255.0 green:182/255.0 blue:249/255.0 alpha:1] forState:UIControlStateSelected];


    [self.womenBtn setImage:[UIImage imageNamed:@"free_women_sel"] forState:UIControlStateSelected];
    [self.womenBtn setTitleColor:[UIColor colorWithRed:249/255.0 green:120/255.0 blue:152/255.0 alpha:1] forState:UIControlStateSelected];

    [self.hunlianBtn setImage:[UIImage imageNamed:@"free_sel"] forState:UIControlStateSelected];
    
    [self.shilianBtn setImage:[UIImage imageNamed:@"free_sel"] forState:UIControlStateSelected];
    
    [self.fuqiBtn setImage:[UIImage imageNamed:@"free_sel"] forState:UIControlStateSelected];
    
    [self.poxiBtn setImage:[UIImage imageNamed:@"free_sel"] forState:UIControlStateSelected];
    
    [self.phoneTF addTarget:self action:@selector(phoneChanged:) forControlEvents:UIControlEventEditingChanged];
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
