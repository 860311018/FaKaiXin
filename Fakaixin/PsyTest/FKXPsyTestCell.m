//
//  FKXPsyTestCell.m
//  Fakaixin
//
//  Created by liushengnan on 16/10/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXPsyTestCell.h"

#import "FKXPsyListModel.h"

@interface FKXPsyTestCell ()
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labNum;
@property (weak, nonatomic) IBOutlet UILabel *labAccurate;
@property (weak, nonatomic) IBOutlet UIView *bacView;
@property (weak, nonatomic) IBOutlet UIImageView *psyBackImgV;

@end

@implementation FKXPsyTestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _bacView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    
    self.contentView.layer.cornerRadius = 14;
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.borderColor = UIColorFromRGB(0xe7e7e7).CGColor;
    self.contentView.layer.borderWidth = 1.0;
}

- (void)setModel:(FKXPsyListModel *)model {
    _model = model;
    self.labTitle.text = [NSString stringWithFormat:@"心理测试:%@",model.testTitle];
    self.labNum.text = [NSString stringWithFormat:@"%@人",model.testNum];
    self.labAccurate.text = [NSString stringWithFormat:@"%@人",model.praiseNum];
    [self.psyBackImgV sd_setImageWithURL:[NSURL URLWithString:model.testBackground] placeholderImage:[UIImage imageNamed:@"img_bac_default"]];
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 12;//整体向下 移动6
    frame.size.height -= 24;//间隔为12
    [super setFrame:frame];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
