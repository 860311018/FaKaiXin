//
//  FKXLoveDetailCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyLoveItemsDelegate <NSObject>

- (void)selectQianDao;
- (void)selectComment;
- (void)selectThanks;
- (void)selectShare;
- (void)selectWenDa;
- (void)selectSend;

@end

@interface FKXLoveDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *scrollBar;

//签到
@property (weak, nonatomic) IBOutlet UIImageView *qianDaoImgV;
//评论
@property (weak, nonatomic) IBOutlet UIImageView *commentImgV;
//感谢他人
@property (weak, nonatomic) IBOutlet UIImageView *thanksImgV;
//分享产品
@property (weak, nonatomic) IBOutlet UIImageView *shareImgV;
//问答
@property (weak, nonatomic) IBOutlet UIImageView *wenDaImgV;
//发心事
@property (weak, nonatomic) IBOutlet UIImageView *sendImgV;

@property (weak, nonatomic) IBOutlet UIImageView *backImgV1;
@property (weak, nonatomic) IBOutlet UIImageView *backImgV2;
@property (weak, nonatomic) IBOutlet UIImageView *backImgV3;
@property (weak, nonatomic) IBOutlet UIImageView *backImgV4;
@property (weak, nonatomic) IBOutlet UIImageView *backImgV5;
@property (weak, nonatomic) IBOutlet UIImageView *backImgV6;


@property (weak, nonatomic) IBOutlet UIImageView *shadow1;
@property (weak, nonatomic) IBOutlet UIImageView *shadow2;
@property (weak, nonatomic) IBOutlet UIImageView *shadow3;
@property (weak, nonatomic) IBOutlet UIImageView *shadow4;
@property (weak, nonatomic) IBOutlet UIImageView *shadow5;
@property (weak, nonatomic) IBOutlet UIImageView *shadow6;


@property (weak, nonatomic) id<MyLoveItemsDelegate>myLoveItemsDelegate;

@end
