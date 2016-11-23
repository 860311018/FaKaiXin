//
//  FKXMyDynamicNoTextCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXMyDynamicNoTextCell.h"
#import "NSString+HeightCalculate.h"

#define kFontOfContent 13
#define kMarginXTotal 62    //cell的边距加上textView的内边距 52 + 12 + 10 + 10
#define kLineSpacing 8  //段落的行间距
#define kTextVTopInset 15  //textV 的内容上下inset

@interface FKXMyDynamicNoTextCell ()
@property (weak, nonatomic) IBOutlet UIButton *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UILabel *userTime;
@property (weak, nonatomic) IBOutlet UITextView *detailText;

@end
@implementation FKXMyDynamicNoTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _detailText.textContainerInset = UIEdgeInsetsMake(12, 19, 12, 19);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickUserIcon:(UIButton *)sender {
}
-(void)setModel:(MyDynamicModel *)model
{
    _model = model;
    [_userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", model.head,cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _userTime.text = model.createTime;
    _userName.text = model.nickname;
    _detailText.text = model.replyText;
    switch ([model.type integerValue]) {
        case 1:
            _userType.text = @"评论了";
            break;
        case 2:
            _userType.text = @"抱了";
            break;
        case 3:
            _userType.text = @"偷听了";
            break;
        case 4:
            _userType.text = @"赞了";
            break;
        default:
            break;
    }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = kLineSpacing;
    
    NSString *theString = [NSString stringWithFormat:@"%@：%@",model.toNickname, model.replyText];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:theString attributes:@{NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont systemFontOfSize:kFontOfContent], NSForegroundColorAttributeName : UIColorFromRGB(0x666666)}];
    [attStr addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x51b5ff)} range:[theString rangeOfString:[NSString stringWithFormat:@"%@：",model.toNickname]]];
    _detailText.attributedText = attStr;
    
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [theString heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    CGFloat unitH = [@"哈" heightForWidth:screen.size.width - kMarginXTotal usingFont:[UIFont systemFontOfSize:kFontOfContent] style:style];
    CGFloat heightA = unitH*3 + kLineSpacing*2;
    if (height > heightA)//文字高度大于3行
    {
        CGRect frame = self.detailText.frame;
        CGFloat heightB = unitH*3 + kLineSpacing*2 + kTextVTopInset*2;
        frame.size.height = heightB;
        _detailText.frame = frame;
    }
    else{
        CGRect frame = self.detailText.frame;
        frame.size.height = height + kTextVTopInset*2;
        _detailText.frame = frame;
    }
}
@end
