//
//  FKXTestingVC.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXTestingVC.h"
#import "FKXPsyInfoModel.h"

#import "NSString+Extension.h"
#import "FKXTestResultVC.h"

@interface FKXTestingVC ()
@property (weak, nonatomic) IBOutlet UIImageView *questionBack;



@property (weak, nonatomic) IBOutlet UIButton *bigPreTestBtn;
@property (weak, nonatomic) IBOutlet UIButton *littlePreTestBtn;
@property (weak, nonatomic) IBOutlet UIButton *resultBtn;

@property (weak, nonatomic) IBOutlet UILabel *labProcess;
@property (weak, nonatomic) IBOutlet UIProgressView *myProcessV;
@property (weak, nonatomic) IBOutlet UILabel *myTextV;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIImageView *imgBottom;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;

@property (strong, nonatomic)NSMutableArray *testArr;
@property (strong, nonatomic)NSMutableArray *answerArr;
@property (copy, nonatomic)NSString *selectStr;

@end

@implementation FKXTestingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle = @"心理测试";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpTableView];
  
    
    [self loadData];
    
 
}

- (void)loadData {
    if (!self.psyId) {
        return;
    }
    NSDictionary *paramDic = @{@"psyId":self.psyId};
    
    [FKXPsyInfoModel sendGetOrPostRequest:@"psy/question_list" param:paramDic requestStyle:HTTPRequestTypePost setSerializer:HTTPResponseTypeJSON handleBlock:^(id data, NSError *error, FMIErrorModelTwo *errorModel)
     {
//         [self hideHud];
         if (data)
         {
             [self.testArr removeAllObjects];
             [self.answerArr removeAllObjects];

             [self.testArr addObjectsFromArray:data];
             
             if (self.testArr.count !=0) {
                 FKXPsyInfoModel *model = self.testArr[self.page];
                 _myTextV.text = model.question;
                 [_questionBack sd_setImageWithURL:[NSURL URLWithString:model.questionBackground] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
                 
                 if (![NSString isEmpty:model.answer1]) {
                         [self.answerArr addObject:model.answer1];
                     }
                 if (![NSString isEmpty:model.answer2]) {
                     [self.answerArr addObject:model.answer2];
                 }if (![NSString isEmpty:model.answer3]) {
                     [self.answerArr addObject:model.answer3];
                 }if (![NSString isEmpty:model.answer4]) {
                     [self.answerArr addObject:model.answer4];
                 }
                 
                 
                 //最后一题显示查看结果
                 if (self.page+1 == self.testArr.count) {
                     self.bigPreTestBtn.hidden = YES;
                     self.littlePreTestBtn.hidden = NO;
                     self.resultBtn.hidden = NO;
                 }
                 
                 //进度条
                 
                 CGFloat f = (CGFloat)(self.page+1)/self.testArr.count;
                 NSString *fstr = [NSString stringWithFormat:@"%.f%%",f*100];
                 
                 self.myProcessV.progress =f;
                 self.labProcess.text = fstr;
                 
                 CGFloat width = CGRectGetWidth(self.myProcessV.frame)-CGRectGetWidth(self.labProcess.frame);
                 CGRect frame = self.labProcess.frame;
                 frame.origin.x = width *f;
                 self.labProcess.frame = frame;
                 
                 [_myTableView reloadData];

             }
             
             
         }else if (errorModel)
         {
             [self showHint:errorModel.message];
         }
     }];
}


- (void)goBack
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - clickEvent
- (IBAction)goBackPreTest:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)clickLookResult:(UIButton *)sender {
    if (![NSString isEmpty:self.selectStr]) {
        FKXTestResultVC *vc = [[FKXTestResultVC alloc]initWithNibName:@"FKXTestResultVC" bundle:nil];
        vc.hidesBottomBarWhenPushed = YES;
        vc.psyId = self.psyId;
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        vc.type = [numberFormatter numberFromString:self.selectStr];
        vc.testTitle = self.psyTitle;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        [self showHint:@"请选择答案"];
    }
}

#pragma mark - tableviewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.answerArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    FKXPsyInfoModel *model = self.testArr[self.page];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FKXTestingCell" forIndexPath:indexPath];//
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = self.answerArr[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.page < self.testArr.count-1) {
        FKXTestingVC *vc = [[UIStoryboard storyboardWithName:@"Letter" bundle:nil] instantiateViewControllerWithIdentifier:@"FKXTestingVC"];
        vc.page = self.page +1;
        vc.psyId = self.psyId ;
        
        vc.psyTitle = self.psyTitle;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (self.page == self.testArr.count-1){
        self.selectStr = [NSString stringWithFormat:@"%ld",indexPath.row];
    }
    
}


- (void)setUpTableView {
    _myTableView.estimatedRowHeight = 44;
    _myTableView.rowHeight = UITableViewAutomaticDimension;
    _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-60, 10)];
    _myTableView.layer.borderColor = UIColorFromRGB(0xd2d2d2).CGColor;
    _myTableView.layer.borderWidth = 1.0;
    _myTableView.layer.cornerRadius = 10;
 
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

- (NSMutableArray *)testArr {
    if (!_testArr) {
        _testArr = [[NSMutableArray alloc]init];
    }
    return _testArr;
}

- (NSMutableArray *)answerArr {
    if (!_answerArr) {
        _answerArr = [[NSMutableArray alloc]init];
    }
    return _answerArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

