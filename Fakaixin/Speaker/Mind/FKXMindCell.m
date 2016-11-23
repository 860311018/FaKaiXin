//
//  FKXMindCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/9/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMindCell.h"
@interface FKXMindCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myBacImg;
@property (weak, nonatomic) IBOutlet UILabel *myTitleLab;
@property (weak, nonatomic) IBOutlet UILabel *myContentLab;

@end
@implementation FKXMindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //给图片加两个圆角
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 10, _myBacImg.height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 10, _myBacImg.height);
    maskLayer.path = path.CGPath;
    _myBacImg.layer.mask = maskLayer;
    _myBacImg.layer.masksToBounds = YES;
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.borderColor = UIColorFromRGB(0xe7e7e7).CGColor;
    self.contentView.layer.borderWidth = 1.0;
}
- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 6;//整体向下 移动6
    frame.size.height -= 12;//间隔为12
    frame.origin.x += 5;
    frame.size.width -= 10;
    [super setFrame:frame];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCourseModel:(FKXCourseModel *)courseModel
{
    _btnShare.hidden = NO;
    if (courseModel.expectCost) {
        switch ([courseModel.status integerValue]) {
            case 0:
            case 1:
                [_btnShare setTitle:@"参加课程" forState:UIControlStateNormal];
                break;
            case 2:
                [_btnShare setTitle:@"回顾课程" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }else{
        switch ([courseModel.status integerValue]) {
            case 0:
            case 1:
                [_btnShare setTitle:@"参加分享会" forState:UIControlStateNormal];
                break;
            case 2:
                [_btnShare setTitle:@"回顾分享会" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    _courseModel = courseModel;
    self.myTitleLab.text = courseModel.title;
    _myContentLab.text = [NSString stringWithFormat:@"时间：%@", courseModel.startTime];
//    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
//    sty.lineSpacing = 5;
//    NSString *content = courseModel.startTime? courseModel.startTime : @"";
//    NSAttributedString *att = [[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName : sty}];
//    _myContentLab.attributedText = att;
    
    [self.myBacImg sd_setImageWithURL:[NSURL URLWithString:courseModel.background] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
}

//- (IBAction)goToShareSession:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(clickToShareSession:withModel:)]) {
//        [self.delegate clickToShareSession:self withModel:self.courseModel];
//    }
//}
@end
