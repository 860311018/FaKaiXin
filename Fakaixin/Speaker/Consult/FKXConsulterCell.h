//
//  FKXConsulterCell.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol  FKXConsulterCellDelegate<NSObject>
//
//- (void)goToDynamicVC:(FKXUserInfoModel*)cellModel sender:(UIButton*)sender;
//
//@end

@protocol ConsultCallProDelegate <NSObject>

- (void)consultCallPro:(FKXUserInfoModel *)proModel;

@end

@interface FKXConsulterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *desL;
@property (weak, nonatomic) IBOutlet UILabel *zhiyuL;
@property (weak, nonatomic) IBOutlet UILabel *zhiyeL;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

@property (weak, nonatomic) IBOutlet UIImageView *imgVip;

@property (weak, nonatomic) IBOutlet UIImageView *tagImgV;
@property (weak, nonatomic) IBOutlet UILabel *tagL;

@property(nonatomic, strong)FKXUserInfoModel * model;
@property(nonatomic, assign)BOOL isVip;

@property(nonatomic,weak)id<ConsultCallProDelegate>delegate;


@end
