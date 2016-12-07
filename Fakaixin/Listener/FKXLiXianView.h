//
//  FKXLiXianView.h
//  Fakaixin
//
//  Created by apple on 2016/11/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LixianDelegate <NSObject>

- (void)lixiantoHead:(NSNumber *)uid;

@end

@interface FKXLiXianView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameL;

@property (weak, nonatomic) IBOutlet UIImageView *headImgV;

@property (nonatomic,copy) NSString *head;//咨询师头像
@property (nonatomic,copy) NSString *name;//咨询师姓名
@property (weak, nonatomic) IBOutlet UILabel *statusL;

@property (weak, nonatomic) id<LixianDelegate>delegate;

@property (nonatomic,strong)NSNumber *lisId;

+ (id)creatLiXian;

@end
