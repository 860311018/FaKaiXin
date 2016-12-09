
//
//  FKXMyOrdersCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyOrdersCell.h"
#import "FKXOrderModel.h"

@implementation FKXMyOrdersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(FKXOrderModel *)model {
    _model = model;
    
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:model.headUrl] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nameL.text = model.nickName;
    
    self.priceL.text = [NSString stringWithFormat:@"￥%.2f",[model.money floatValue]/100.0];

//    if ([model.type integerValue] == 0) {
//        self.detailL.text = @"图文咨询";
//
//    }else {
//        self.detailL.text = @"电话咨询";
//    }
    
    if (model.callLength && [model.callLength integerValue]!=0) {
        self.detailL.text = @"电话咨询";
    }else {
        self.detailL.text = @"图文咨询";
    }
    
    self.shengyiTime.hidden = YES;
    
    if (self.isWorkBench) {
        switch ([model.status integerValue]) {
            case 0:
            {
                self.statusL.text = @"已付款";
                self.statusL.textColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1];
                [self.operationBtn setTitle:@"接受订单" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = NO;
                [self.cancelBtn setTitle:@"拒绝订单" forState:UIControlStateNormal];
                [self.cancelBtn setTitleColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1] forState:UIControlStateNormal];
                self.cancelBtn.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;

            }
                break;
            case 1:
            {
                self.statusL.text = @"进行中";
                self.statusL.textColor = [UIColor colorWithRed:244/255.0 green:143/255.0 blue:141/255.0 alpha:1];
                
                [self.operationBtn setTitle:@"去服务" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:244/255.0 green:143/255.0 blue:141/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:244/255.0 green:143/255.0 blue:141/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;
                
//                if ([model.type integerValue] !=0) {
//                    self.shengyiTime.hidden = NO;
//                    self.shengyiTime.text = [NSString stringWithFormat:@"还剩%ld分钟",[model.callLength integerValue]];
//                }
                

                
                if (model.callLength && [model.callLength integerValue]!=0) {
                    self.shengyiTime.hidden = NO;
                    self.shengyiTime.text = [NSString stringWithFormat:@"还剩%ld分钟",[model.callLength integerValue]];
                }
                
            }
                break;
            case 2:
            {
                self.statusL.text = @"待评价";
                self.statusL.textColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1];
                
                [self.operationBtn setTitle:@"查看详情" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;

            }
                break;
            case 3:
            {
                self.statusL.text = @"已拒绝";
                self.statusL.textColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
                
                [self.operationBtn setTitle:@"查看详情" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;

            }
                break;
            case 4:
            {
                self.statusL.text = @"已评价";
                self.statusL.textColor = [UIColor colorWithRed:130/255.0 green:240/255.0 blue:229/255.0 alpha:1];
                
                [self.operationBtn setTitle:@"去看评价" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:130/255.0 green:240/255.0 blue:229/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:130/255.0 green:240/255.0 blue:229/255.0 alpha:1].CGColor;
                self.cancelBtn.hidden = YES;

            }
                break;
                
            default:
                break;
        }
    }
 
    
    else {
        switch ([model.status integerValue]) {
            case 0:
            {
                self.statusL.text = @"待确认";
                self.statusL.textColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1];
                [self.operationBtn setTitle:@"私信TA" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;

            }
                break;
            case 1:
            {
                self.statusL.text = @"进行中";
                self.statusL.textColor = [UIColor colorWithRed:244/255.0 green:143/255.0 blue:141/255.0 alpha:1];
                
                [self.operationBtn setTitle:@"立即咨询" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:244/255.0 green:143/255.0 blue:141/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:244/255.0 green:143/255.0 blue:141/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;
                
                //                if ([model.type integerValue]!=0) {
                //                    self.shengyiTime.hidden = NO;
                //                    self.shengyiTime.text = [NSString stringWithFormat:@"还剩%ld分钟",[model.callLength integerValue]];
                //                }
                
                if (model.callLength && [model.callLength integerValue]!=0) {
                    self.shengyiTime.hidden = NO;
                    self.shengyiTime.text = [NSString stringWithFormat:@"还剩%ld分钟",[model.callLength integerValue]];
                }


            }
                break;
            case 2:
            {
                self.statusL.text = @"待评价";
                self.statusL.textColor = [UIColor colorWithRed:130/255.0 green:240/255.0 blue:229/255.0 alpha:1];
                
                [self.operationBtn setTitle:@"立即评价" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:130/255.0 green:240/255.0 blue:229/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:130/255.0 green:240/255.0 blue:229/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;

            }
                break;
            case 3:
            {
                self.statusL.text = @"已拒绝";
                self.statusL.textColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
                
                [self.operationBtn setTitle:@"查看详情" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;

            }
                break;
            case 4:
            {
                self.statusL.text = @"待确认";
                self.statusL.textColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1];
                [self.operationBtn setTitle:@"再次预约" forState:UIControlStateNormal];
                [self.operationBtn setTitleColor:[UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
                self.operationBtn.layer.borderColor = [UIColor colorWithRed:81/255.0 green:181/255.0 blue:255/255.0 alpha:1].CGColor;
                
                self.cancelBtn.hidden = YES;
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
