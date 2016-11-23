//
//  FKXMineDetailVC.m
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMineDetailVC.h"

#import "PaiMingFirstCell.h"
#import "PaiMingOtherCell.h"
#import "MyPaiMingCell.h"


#define btnW     (kScreenWidth-16-2)/3

@interface FKXMineDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)UIView *lineW;



@end

@implementation FKXMineDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.type == MyDetailTypeHelp) {
        self.navTitle = @"帮助排行榜";
    }else if (self.type == MyDetailTypeZan) {
        self.navTitle = @"点赞排行榜";
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PaiMingFirstCell" bundle:nil] forCellReuseIdentifier:@"PaiMingFirstCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PaiMingOtherCell" bundle:nil] forCellReuseIdentifier:@"PaiMingOtherCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyPaiMingCell" bundle:nil] forCellReuseIdentifier:@"MyPaiMingCell"];
    
}

#pragma mark - 点击排行
- (void)selectPaiHang:(UIButton *)button {
    
    [self.lineW removeFromSuperview];
    [button addSubview:self.lineW];
}


#pragma mark - tableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 75; //sectionHeaderHeight
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0) {
        return 3;
    }else if (section == 1) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 75;
    }else if (section == 1) {
        return 20;
    }
    return 0;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 75)];
        view.userInteractionEnabled = YES;
        UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 15, kScreenWidth-16, 50)];
        backImgV.userInteractionEnabled = YES;
        backImgV.image = [UIImage imageNamed:@"mine_paihang_headV1"];
        [view addSubview:backImgV];
        
        
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(btnW, 10, 1, 30)];
        line1.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(btnW *2+1, 10, 1, 30)];
        line2.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
        
        [backImgV addSubview:line1];
        [backImgV addSubview:line2];
        
        for (int i=0; i<3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((btnW +1)*i, 0, btnW, 50);
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor colorWithRed:116/255.0 green:116/255.0 blue:116/255.0 alpha:1] forState:UIControlStateNormal];
            button.userInteractionEnabled = YES;
            [button addTarget:self action:@selector(selectPaiHang:) forControlEvents:UIControlEventTouchUpInside];
            
            button.tag = 100+i;
            
            if (i==0) {
                [button setTitle:@"日榜" forState:UIControlStateNormal];
                button.selected = YES;
                [button addSubview:self.lineW];
            }else if (i==1) {
                [button setTitle:@"周榜" forState:UIControlStateNormal];
                
            }else if (i==2) {
                [button setTitle:@"月榜" forState:UIControlStateNormal];
                
            }
            
            [button setTitleEdgeInsets:UIEdgeInsetsMake(-5, 0,0, 0)];
            
            [backImgV addSubview:button];
        }
        
        
        
        return view;
        
    }else if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(6, -3, kScreenWidth-12, 26)];
        imageV.image = [UIImage imageNamed:@"mine_paihang_headV2"];
        [view addSubview:imageV];
        return view;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //排名第一
        if (indexPath.row == 0) {
            PaiMingFirstCell * cell =[tableView dequeueReusableCellWithIdentifier:@"PaiMingFirstCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
            //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.headImgV.backgroundColor = [UIColor blackColor];
            return cell;
        }
        //其他排名
        else {
            PaiMingOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaiMingOtherCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
            if (indexPath.row == 1) {
                cell.headIcon.image = [UIImage imageNamed:@"mine_King2"];
                
                cell.paiMingBackImgV.image = [UIImage imageNamed:@"mine_mingciBack2"];            }
            else if (indexPath.row == 2) {
                cell.headIcon.image = [UIImage imageNamed:@"mine_King3"];
                
                cell.paiMingBackImgV.image = [UIImage imageNamed:@"mine_mingciBack3"];
            }
            
            return cell;
        }
        
    }
    //我的排名
    else if (indexPath.section == 1) {
        MyPaiMingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyPaiMingCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    return nil;
}



- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UIView *)lineW {
    if (!_lineW) {
        _lineW = [[UIView alloc]initWithFrame:CGRectMake(10, 38, 80, 4)];
        _lineW.backgroundColor = [UIColor colorWithRed:248/255.0 green:227/255.0 blue:146/255.0 alpha:1];
        
    }
    return _lineW;
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
