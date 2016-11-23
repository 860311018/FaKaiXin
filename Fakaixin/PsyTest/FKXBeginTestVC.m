//
//  FKXBeginTestVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXBeginTestVC.h"
#import "FKXTestEvaluateVC.h"
#import "FKXTestingVC.h"
#import "NSString+Extension.h"

#import "FKXPsyListModel.h"
#import "FKXPsyCommentModel.h"
#import "FKXPsyCommentCell.h"

@interface FKXBeginTestVC ()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnOpenDetail;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;

@property (weak, nonatomic) IBOutlet UIImageView *bacImg;
@property (weak, nonatomic) IBOutlet UILabel *myTextV;
@property (weak, nonatomic) IBOutlet UITextView *myInputTV;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic,strong) NSMutableArray *commentArr;

@end

@implementation FKXBeginTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"心理测试";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _myInputTV.textContainerInset = UIEdgeInsetsMake(7, 10, 7, 10);
    
    [self setUpTableView];
    
    
    //获取评论
    if (self.listModel) {
        
        _labTitle.text = self.listModel.testTitle;
        _myTextV.text = self.listModel.testDescribe;
        [_bacImg sd_setImageWithURL:[NSURL URLWithString:self.listModel.startTestBackground] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];

        [self loadData];
    }

}

- (void)loadData {
    
    NSDictionary *paramDic = @{@"start" : @(0), @"size": @(4),@"psyId":self.listModel.psyId};
    
    [FKXPsyCommentModel sendGetOrPostRequest:@"psy/comment_list" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         if (data)
         {
             [self.commentArr removeAllObjects];
             
             [self.commentArr addObjectsFromArray:data];
             [_myTableView reloadData];
             
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];
}


#pragma mark -  点击事件
- (IBAction)clickBeginTest:(UIButton *)sender {
    if ([FKXUserManager needShowLoginVC]) {
        [[FKXLoginManager shareInstance] showLoginViewControllerFromViewController:self withSomeObject:nil];
        return;
    }
    
    FKXTestingVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXTestingVC"];
    vc.psyId = self.listModel.psyId;
    vc.psyTitle = self.listModel.testTitle;
    vc.page = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickOpenDetail:(UIButton *)sender {
    static BOOL isOpen = NO;
    isOpen = !isOpen;
    if (isOpen) {
        _myTextV.numberOfLines = 0;
        [_btnOpenDetail setImage:[UIImage imageNamed:@"img_btn_up_arrow"] forState:UIControlStateNormal];
        [_myTableView reloadData];
    }else {
        _myTextV.numberOfLines = 5;
        [_btnOpenDetail setImage:[UIImage imageNamed:@"img_btn_down_arrow"] forState:UIControlStateNormal];
        [_myTableView reloadData];
    }
}

- (IBAction)clickSend:(UIButton *)sender {
    if (![NSString isEmpty:_myInputTV.text]) {
        NSDictionary *paramDic = @{@"text" : _myInputTV.text,@"psyId":self.listModel.psyId};
        
        [AFRequest sendGetOrPostRequest:@"psy/comment" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
            [self hideHud];
            if ([data[@"code"] integerValue] == 0)
            {
                [self showHint:@"发表评论成功"];
                _myInputTV.text = @"";
                [self loadData];
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



#pragma mark - tableviewdelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.commentArr.count == 0) {
        return 1;
    }
    return self.commentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.commentArr.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXPsyNoCommentCell" forIndexPath:indexPath];
        return cell;
    }else {
        FKXPsyCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXPsyCommentCell" forIndexPath:indexPath];
        cell.model = self.commentArr [indexPath.row];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FKXTestEvaluateVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXTestEvaluateVC"];
    vc.psyId = self.listModel.psyId;
    vc.commentImg = self.listModel.testBackground;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableArray *)commentArr {
    if (!_commentArr) {
        _commentArr = [[NSMutableArray alloc]init];
    }
    return _commentArr;
}

- (void)setUpTableView {
    _myTableView.estimatedRowHeight = 44;
    _myTableView.rowHeight = UITableViewAutomaticDimension;
    _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-60, 10)];
    _myTableView.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
    _myTableView.layer.borderWidth = 1.0;
    _myTableView.layer.cornerRadius = 10;
    [_myTableView registerNib:[UINib nibWithNibName:@"FKXPsyCommentCell" bundle:nil] forCellReuseIdentifier:@"FKXPsyCommentCell"];
    [_myTableView registerNib:[UINib nibWithNibName:@"FKXPsyNoCommentCell" bundle:nil] forCellReuseIdentifier:@"FKXPsyNoCommentCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - seperator insets 设置
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.myTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self.myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.myTableView setSeparatorInset:UIEdgeInsetsZero];
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
