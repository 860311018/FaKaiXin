//
//  FKXMyOderDetailVC.m
//  Fakaixin
//
//  Created by apple on 2016/12/1.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyOderDetailVC.h"

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


@end

@implementation FKXMyOderDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navTitle = @"我的订单";
    
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
