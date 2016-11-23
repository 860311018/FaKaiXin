//
//  FKXSameMindCell.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXSameMindCell.h"
#import "NSString+HeightCalculate.h"

#define kFontOfContent 15

@interface FKXSameMindCell ()

@property (weak, nonatomic) IBOutlet UIButton *btnHug;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeadWear;
@property (weak, nonatomic) IBOutlet UIImageView *imgCardBackground;

@end
@implementation FKXSameMindCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _btnHug.tag = 200;
    _btnShare.tag = 202;
    
    [_imgCardBackground addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBack:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - 分享评论点击事件    0 抱抱 1 同感
- (IBAction)hugOrFeelBtnClick:(UIButton*)btn
{
    if ([self.delegate respondsToSelector:@selector(hugOrFeelDidSelect:type:)]) {
        [self.delegate hugOrFeelDidSelect:self.model type:btn.tag-200];
    }
}

- (void)tapBack:(UITapGestureRecognizer *)tap {
    NSInteger type = tap.view.tag-200;
    if ([self.delegate respondsToSelector:@selector(hugOrFeelDidSelect:type:)]) {
        [self.delegate hugOrFeelDidSelect:self.model type:type];
    }
}

-(void)setModel:(FKXSameMindModel *)model
{
    _model = model;
    
    _labTime.text = @"";
    switch ([model.worryType integerValue]) {
        case 0:
            _labTime.text = @"出轨";
            break;
        case 1:
            _labTime.text = @"失恋";
            break;
        case 2:
            _labTime.text = @"夫妻";
            break;
        case 3:
            _labTime.text = @"婆媳";
            break;
        default:
            break;
    }
    _btnHug.selected = [model.hug boolValue];
    [_iconImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.head, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _userName.text = model.nickName;
    if (model.checkedPendant.length) {
        _imgHeadWear.hidden = NO;
        [_imgHeadWear sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageBaseUrl, model.checkedPendant]]];
    }else
    {
        _imgHeadWear.hidden = YES;
    }
    if (model.checkedBackground) {
        [_imgCardBackground sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageBaseUrl, model.checkedBackground]]];
        _imgCardBackground.hidden = NO;
    }else{
        _imgCardBackground.hidden = YES;
    }
    NSMutableParagraphStyle *sty = [[NSMutableParagraphStyle alloc] init];
    sty.lineSpacing = 8;
    NSString *content = model.text? model.text : @"";
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName : sty}];
    _contentLab.attributedText = att;
    
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat height = [model.text heightForWidth:screen.size.width - 34 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:sty];
    CGFloat unitH = [@"哈" heightForWidth:screen.size.width - 34 usingFont:[UIFont systemFontOfSize:kFontOfContent] style:sty];
    _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;

    if (height > unitH*3)//文字高度大于3行
    {
//        if ([model.isOpen boolValue])//是展开的
//        {
//            _btnOpenDetail.hidden = YES;
//            CGRect frame = self.contentLab.frame;
//            frame.size.height = height;
//            _contentLab.numberOfLines = 0;
//            _contentLab.frame = frame;
//        }else{
//            _btnOpenDetail.hidden = NO;
            CGRect frame = self.contentLab.frame;
            frame.size.height = unitH*3;
            _contentLab.numberOfLines = 3;
            _contentLab.frame = frame;
//        }
    }
    else{
//        _btnOpenDetail.hidden = YES;
        CGRect frame = self.contentLab.frame;
        frame.size.height = height;
        _contentLab.numberOfLines = 3;
        _contentLab.frame = frame;
    }
}
- (IBAction)clickOpenDetail:(UIButton *)sender {

    self.model.isOpen = @(YES);

    if (_delegate && [_delegate respondsToSelector:@selector(clickToOpenDetail)]) {
        [_delegate clickToOpenDetail];
    }
}

@end
