//
//  FKXTestEvaluateVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXTestEvaluateVC.h"
#import "FKXPsyCommentCell.h"
#import "FKXPsyCommentModel.h"
#import "NSString+Extension.h"

@interface FKXTestEvaluateVC ()
{
    NSInteger start;
    NSInteger size;
}
@property (weak, nonatomic) IBOutlet UIImageView *commentImgV;

@property (weak, nonatomic) IBOutlet UITextView *myInputTV;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;

@property (weak, nonatomic) IBOutlet UIView *viewBottom;

@property (nonatomic,strong) NSMutableArray *commentArr;

@end

@implementation FKXTestEvaluateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"心理测试";

    size = kRequestSize;

    [self setUpTableView];
    
    [self loadData];
}


#pragma mark - ---网络请求---
- (void)headerRefreshEvent
{
    start = 0;
    [self loadData];
}
- (void)footRefreshEvent
{
    start += size;
    [self loadData];

}

- (void)loadData {
    NSDictionary *paramDic = @{@"start" : @(start), @"size": @(size),@"psyId":self.psyId};
    
    [FKXPsyCommentModel sendGetOrPostRequest:@"psy/comment_list" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
         [self hideHud];
         _myTableView.header.state = MJRefreshHeaderStateIdle;
         _myTableView.footer.state = MJRefreshFooterStateIdle;
         
         if (data)
         {
             if ([data count] < kRequestSize) {
                 _myTableView.footer.hidden = YES;
             }else
             {
                 _myTableView.footer.hidden = NO;
             }
             
             if (start == 0)
             {
                 [self.commentArr removeAllObjects];
             }
             [self.commentArr addObjectsFromArray:data];
             
             [_myTableView reloadData];
             
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -  点击事件
- (IBAction)clickSend:(UIButton *)sender {
    if (![NSString isEmpty:_myInputTV.text]) {
        NSDictionary *paramDic = @{@"text" : _myInputTV.text,@"psyId":self.psyId};
        
        [AFRequest sendGetOrPostRequest:@"psy/comment" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON success:^(id data) {
            [self hideHud];
            if ([data[@"code"] integerValue] == 0)
            {
                [self showHint:@"发表评论成功"];
                _myInputTV.text = @"";
                [self headerRefreshEvent];
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
        cell.commentL.numberOfLines = 0;
        cell.model = self.commentArr [indexPath.row];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSMutableArray *)commentArr {
    if (!_commentArr) {
        _commentArr = [[NSMutableArray alloc]init];
    }
    return _commentArr;
}

-(void)setUpTableView {
    
    [_myTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefreshEvent) dateKey:@""];
    
    [_myTableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(footRefreshEvent)];
    
    _myTableView.estimatedRowHeight = 44;
    _myTableView.rowHeight = UITableViewAutomaticDimension;

    _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _myTableView.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
    _myTableView.layer.borderWidth = 1.0;
    _myTableView.layer.cornerRadius = 10;
    
    _labTitle.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    [_commentImgV sd_setImageWithURL:[NSURL URLWithString:self.commentImg] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
    
    [_myTableView registerNib:[UINib nibWithNibName:@"FKXPsyCommentCell" bundle:nil] forCellReuseIdentifier:@"FKXPsyCommentCell"];
    [_myTableView registerNib:[UINib nibWithNibName:@"FKXPsyNoCommentCell" bundle:nil] forCellReuseIdentifier:@"FKXPsyNoCommentCell"];
    
    
    
    //给图片加两个圆角
    //    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 60, _viewBottom.height) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    //
    //    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    //    maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 100, _viewBottom.height);
    //    maskLayer.path = path.CGPath;
    //    _viewBottom.layer.borderColor = [UIColor blueColor].CGColor;
    //    _viewBottom.layer.mask = maskLayer;
    //    _viewBottom.layer.masksToBounds = YES;
}
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
