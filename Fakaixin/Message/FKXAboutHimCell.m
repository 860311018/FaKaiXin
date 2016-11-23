//
//  FKXAboutHimCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXAboutHimCell.h"
#import "DDTagButton.h"
@interface FKXAboutHimCell ()

@property (nonatomic,strong)id height;

@end

@implementation FKXAboutHimCell

- (void)awakeFromNib {
    
    self.height = self.tagBackViewH;
    [super awakeFromNib];
    // Initialization code
    
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setUserD:(NSDictionary *)userD {
    _userD = userD;
     NSArray *goodArr = userD[@"goodAt"];
    NSMutableArray *goodStrArr = [[NSMutableArray alloc]init];
    
    for (UIButton *btn in self.tagBackView.subviews) {
        [btn removeFromSuperview];
    }
    
    //tag 第一行距上一控件 纵向间距
    __block CGFloat tagMarginY = 5;
    //tag 第一行距左边横向间距
    __block CGFloat tagMarginX = 10;
    // tag间横向距离
    CGFloat btnPaddingX = 30;
    // tag间纵向距离
    CGFloat btnPaddingY = 10;
    __block CGFloat btn_H = 0;
    CGFloat btnW = kScreenWidth-52;
    
    for (NSNumber *num in goodArr) {
        switch ([num integerValue]) {
            case 0:
                [goodStrArr addObject:@"婚恋出轨"];
                break;
            case 1:
                [goodStrArr addObject:@"失恋阴影"];
                break;
            case 2:
                [goodStrArr addObject:@"夫妻相处"];
                break;
            case 3:
                [goodStrArr addObject:@"婆媳关系"];
                break;
            default:
                break;
        }
    }
    
    for (int i=0 ;i<goodStrArr.count;i++) {
        NSString *examinationName = goodStrArr[i];
        DDTagButton *btn = [DDTagButton buttonWithTixt:examinationName Color:[UIColor whiteColor] andImage:[UIImage imageNamed:@"message_tag"] andIsDelete:YES];
        btn.tag = i+ 100;
        [self.tagBackView addSubview:btn];
    }
    for (int i = 0; i< goodStrArr.count; i++) {
        DDTagButton *lastBtn;
        if (i>0) {
            lastBtn = (DDTagButton *)self.tagBackView.subviews[i-1];
        }
        DDTagButton *btn2 = (DDTagButton *)self.tagBackView.subviews[i];
        
        
        if((tagMarginX+CGRectGetWidth(btn2.frame)+10)>btnW){
            //折行
            //第一个tag 距边距水平距离
            tagMarginX = 10;
            
            //userBtnY tag间纵向距离
            tagMarginY = lastBtn.frame.origin.y + CGRectGetHeight(btn2.frame) + btnPaddingY ;
        }
        
        CGPoint point;
        point = CGPointMake(tagMarginX, tagMarginY);
        CGRect frame = btn2.frame;
        frame.origin = point;
        btn2.frame = frame;
        
        tagMarginX = btn2.frame.origin.x + btn2.frame.size.width +btnPaddingX;
        
        btn_H = tagMarginY+btn2.frame.size.height;
    }
    //    self.tagBackView.frame = CGRectMake(0, 40, btnW, btn_H);
    //    [self.tagBackView removeConstraint:self.height];
    [self.tagBackView removeConstraint:self.height];
    
    self.height = [NSLayoutConstraint constraintWithItem:self.tagBackView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:btn_H];
    [self.tagBackView addConstraint:self.height];
    [self setNeedsLayout];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
