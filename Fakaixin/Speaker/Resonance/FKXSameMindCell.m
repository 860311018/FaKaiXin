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
@property (weak, nonatomic) IBOutlet UIImageView *imgHeadWear;
@property (weak, nonatomic) IBOutlet UIImageView *imgCardBackground;

@property (weak, nonatomic) IBOutlet UIButton *jiejueBtn;

@property (weak, nonatomic) IBOutlet UIButton *tagBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentProBtn;
@property (weak, nonatomic) IBOutlet UILabel *listenL;

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

#pragma mark - 点击第一个按钮
- (IBAction)clickFirstBtn:(id)sender {
    
    //抱抱
    if (self.type == 0) {
        if ([self.delegate respondsToSelector:@selector(baobao:)]) {
            [self.delegate baobao:self.model];
        }
    }
    //评论
    else {
        if ([self.delegate respondsToSelector:@selector(comment:)]) {
            [self.delegate comment:self.model];
        }
    }
}

#pragma mark - 点击中间按钮
- (IBAction)clickMiddleBtn:(id)sender {
    //评论
    if (self.type == 0) {
        if ([self.delegate respondsToSelector:@selector(comment:)]) {
            [self.delegate comment:self.model];
        }
    }
    //语音界面
    else {
        if ([self.delegate respondsToSelector:@selector(voice:)]) {
            [self.delegate voice:self.model];
        }
    }
}




#pragma mark - 分享评论点击事件    0 抱抱 1 同感
- (IBAction)hugOrFeelBtnClick:(UIButton*)btn
{
    if ([self.delegate respondsToSelector:@selector(hugOrFeelDidSelect:type:andCellType:)]) {
        [self.delegate hugOrFeelDidSelect:self.model type:btn.tag-200 andCellType:self.type];
    }
}

- (void)tapBack:(UITapGestureRecognizer *)tap {
    NSInteger type = tap.view.tag-200;
    if ([self.delegate respondsToSelector:@selector(hugOrFeelDidSelect:type:andCellType:)]) {
        [self.delegate hugOrFeelDidSelect:self.model type:type andCellType:self.type];
    }
}

-(void)setModel:(FKXSameMindModel *)model
{
    _model = model;
    
    if (self.type == 0) {
        [_jiejueBtn setTitle:@" 未解决 " forState:UIControlStateNormal];
        [_jiejueBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _jiejueBtn.layer.borderColor = [[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]CGColor];
        
        _userName.text = model.nickName;
        
        NSString *title = @"";
        switch ([model.worryType integerValue]) {
            case 0:
                title = @"出轨";
                break;
            case 1:
                title = @"失恋";
                break;
            case 2:
                title = @"夫妻";
                break;
            case 3:
                title = @"婆媳";
                break;
            default:
                break;
        }
        
        [_tagBtn setImage:[UIImage imageNamed:@"img_sign_same_mind"] forState:UIControlStateNormal];
        [_tagBtn setTitle:title forState:UIControlStateNormal];

        [_btnHug setImage:[UIImage imageNamed:@"img_hug_normal"] forState:UIControlStateNormal];
        [_btnHug setImage:[UIImage imageNamed:@"img_hug_selected"] forState:UIControlStateSelected];
        [_btnHug setTitleColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1] forState:UIControlStateNormal];
        [_btnHug setTitleColor:kColorMainRed forState:UIControlStateSelected];
        [_btnHug setTitle:@"抱抱" forState:UIControlStateNormal];
        
        _btnHug.selected = [model.hug boolValue];

        
        [_commentProBtn setImage:[UIImage imageNamed:@"btn_comment"] forState:UIControlStateNormal];
        [_commentProBtn setTitle:@"评论" forState:UIControlStateNormal];
        
        _listenL.hidden = YES;
        
        if (model.checkedBackground) {
            [_imgCardBackground sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageBaseUrl, model.checkedBackground]]];
            _imgCardBackground.hidden = NO;
        }else{
            _imgCardBackground.hidden = YES;
        }
        
        if (model.checkedPendant.length) {
            _imgHeadWear.hidden = NO;
            [_imgHeadWear sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageBaseUrl, model.checkedPendant]]];

        }else
        {
            _imgHeadWear.hidden = YES;
        }

        [_iconImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.head, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];

    }else {
        [_jiejueBtn setTitle:@" 已解决 " forState:UIControlStateNormal];
        [_jiejueBtn setTitleColor:[UIColor colorWithRed:73/255.0 green:182/255.0 blue:249/255.0 alpha:1] forState:UIControlStateNormal];
        _jiejueBtn.layer.borderColor = [[UIColor colorWithRed:73/255.0 green:182/255.0 blue:249/255.0 alpha:1]CGColor];
        
        _userName.text = model.listenerNickName;
        
        [_tagBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_tagBtn setTitle:model.listenerProfession forState:UIControlStateNormal];

        
        [_btnHug setImage:[UIImage imageNamed:@"btn_comment"] forState:UIControlStateNormal];
        [_btnHug setTitleColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1] forState:UIControlStateNormal];
        [_btnHug setTitle:@"评论" forState:UIControlStateNormal];
        
        [_commentProBtn setImage:[UIImage imageNamed:@"btn_pro"] forState:UIControlStateNormal];
        [_commentProBtn setTitle:@"专家回复" forState:UIControlStateNormal];
        
        _listenL.hidden = NO;
        _listenL.text = [NSString stringWithFormat:@"%@人听过", model.listenNum];
        
        if (model.listenerBackground) {
            [_imgCardBackground sd_setImageWithURL:[NSURL URLWithString:model.listenerBackground]];
            _imgCardBackground.hidden = NO;
            
        }else{
            _imgCardBackground.hidden = YES;
        }
        
        if (model.listenerPendant.length) {
            _imgHeadWear.hidden = NO;
            [_imgHeadWear sd_setImageWithURL:[NSURL URLWithString:model.listenerPendant]];
        }else
        {
            _imgHeadWear.hidden = YES;
        }
        
        [_iconImg sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",model.listenerHead, cropImageW]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];

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
