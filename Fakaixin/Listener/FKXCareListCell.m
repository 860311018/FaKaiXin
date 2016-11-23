//
//  FKXCareListCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/25.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXCareListCell.h"
#import "NSString+HeightCalculate.h"

#define kFontOfContent 15
#define kMarginXTotal 62    //cell的边距加上textView的内边距 12 + 12 + 19 + 19
#define kLineSpacing 8  //段落的行间距
#define kTextVTopInset 12  //textV 的内容上下inset

@interface FKXCareListCell ()
@property (weak, nonatomic) IBOutlet UIButton *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *imgType;

@property (weak, nonatomic) IBOutlet UIView *bacView;
@property (weak, nonatomic) IBOutlet UITextView *textVContent;
@end

@implementation FKXCareListCell

- (void)awakeFromNib {
    // Initialization code
    _textVContent.textContainerInset = UIEdgeInsetsMake(12, 19, 12, 19);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(FKXSameMindModel *)model
{
    _model = model;
    _userName.text = model.nickName;
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _imgType.image = [UIImage imageNamed:[NSString stringWithFormat:@"img_care_list_mind_type%d", [model.worryType intValue]]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = kLineSpacing;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.text ? model.text : @"" attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:kFontOfContent], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
    _textVContent.attributedText = attStr;
    //264
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [model.text heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    CGFloat unitH = [@"哈" heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    CGFloat heightA = unitH*3 + kLineSpacing*2;
    if (height > heightA)//文字高度大于3行
    {
        CGRect frame = self.textVContent.frame;
        CGFloat heightB = unitH*3 + kLineSpacing*2 + kTextVTopInset*2;
        frame.size.height = heightB;
        _textVContent.frame = frame;
    }
    else{
        CGRect frame = self.textVContent.frame;
        frame.size.height = height + kTextVTopInset*2;
        _textVContent.frame = frame;
    }
}
- (IBAction)clickUserIcon:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(goToDynamicVC:sender:)]) {
        [self.delegate goToDynamicVC:_model sender:sender];
    }
}
@end
