//
//  FKXLoveDetailCell.m
//  Fakaixin
//
//  Created by apple on 2016/11/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "FKXLoveDetailCell.h"

@interface FKXLoveDetailCell ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)UIImageView *bar;

@end

@implementation FKXLoveDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.scrollView.delegate = self;
//    [self.scrollView flashScrollIndicators];
//    [self.scrollView addSubview:self.scrollBar];

   
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTap:)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTap:)];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTap:)];
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTap:)];
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTap:)];
    UITapGestureRecognizer *tap6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTap:)];

//    [self.qianDaoImgV addGestureRecognizer:tap1];
//    [self.commentImgV addGestureRecognizer:tap2];
//    [self.thanksImgV addGestureRecognizer:tap3];
//    [self.shareImgV addGestureRecognizer:tap4];
//    [self.wenDaImgV addGestureRecognizer:tap5];
//    [self.sendImgV addGestureRecognizer:tap6];
    
}

// 当移动调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float p = 0;
    p = scrollView.contentOffset.x/(scrollView.contentSize.width - scrollView.frame.size.width+(kXHScreenWidth/2-kXHScreenWidth/2*scrollView.frame.size.width/scrollView.contentSize.width));

    [self.scrollBar removeFromSuperview];

    self.bar.frame = CGRectMake(3+p*scrollView.contentSize.width,CGRectGetHeight(self.scrollView.frame)-5-5, kXHScreenWidth/2, 5);
}





- (UIImageView *)bar {
    if (!_bar) {
        _bar = [[UIImageView alloc]init];
        _bar.image = [UIImage imageNamed:@"myLove_bar"];
        [self.scrollView addSubview:_bar];
    }
    return _bar;
}



- (void)selectTap:(UITapGestureRecognizer *)tap {
    UIImageView *imageV = (UIImageView *)tap.view;
    //签到
    if (imageV.tag == myLoveTag) {
        self.qianDaoImgV.alpha = 0.2;
//        [self.backImgV1 addSubview:self.imagCover];
        
        self.commentImgV.alpha = 1;
        self.thanksImgV.alpha = 1;
        self.shareImgV.alpha = 1;
        self.wenDaImgV.alpha = 1;
        self.sendImgV.alpha = 1;
        
        [_myLoveItemsDelegate selectQianDao];
    }
    //评论
    else if (imageV.tag == myLoveTag+1) {
        self.commentImgV.alpha = 0.2;
//        [self.backImgV2 addSubview:self.imagCover];
        
        self.qianDaoImgV.alpha = 1;
        self.thanksImgV.alpha = 1;
        self.shareImgV.alpha = 1;
        self.wenDaImgV.alpha = 1;
        self.sendImgV.alpha = 1;

        [_myLoveItemsDelegate selectComment];

    }
    //感谢他人
    else if (imageV.tag == myLoveTag+2) {
        self.thanksImgV.alpha = 0.2;
//        [self.backImgV3 addSubview:self.imagCover];
        
        self.qianDaoImgV.alpha = 1;
        self.commentImgV.alpha = 1;
        self.shareImgV.alpha = 1;
        self.wenDaImgV.alpha = 1;
        self.sendImgV.alpha = 1;
        
        [_myLoveItemsDelegate selectThanks];

    }
    //分享产品
    else if (imageV.tag == myLoveTag +3) {
        self.shareImgV.alpha = 0.2;
//        [self.backImgV4 addSubview:self.imagCover];
        
        self.qianDaoImgV.alpha = 1;
        self.commentImgV.alpha = 1;
        self.thanksImgV.alpha = 1;
        self.wenDaImgV.alpha = 1;
        self.sendImgV.alpha = 1;
        
        [_myLoveItemsDelegate selectShare];

    }
    //问答
    else if (imageV.tag == myLoveTag +4) {
        self.wenDaImgV.alpha = 0.2;
//        [self.backImgV5 addSubview:self.imagCover];
        
        self.qianDaoImgV.alpha = 1;
        self.commentImgV.alpha = 1;
        self.thanksImgV.alpha = 1;
        self.shareImgV.alpha = 1;
        self.sendImgV.alpha = 1;
        
        [_myLoveItemsDelegate selectWenDa];

    }
    //发心事
    else if (imageV.tag == myLoveTag +5) {
        self.sendImgV.alpha = 0.2;
//        [self.backImgV6 addSubview:self.imagCover];
        
        self.qianDaoImgV.alpha = 1;
        self.commentImgV.alpha = 1;
        self.thanksImgV.alpha = 1;
        self.shareImgV.alpha = 1;
        self.wenDaImgV.alpha = 1;
        
        [_myLoveItemsDelegate selectSend];

    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
