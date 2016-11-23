//
//  DDTagButton.h
//  DingDongSuiFang
//
//  Created by 神农试 on 16/7/18.
//  Copyright © 2016年 神农试. All rights reserved.
//

#import <UIKit/UIKit.h>
#define tagDeleteImgV      20

//@protocol DeleteTagDelegae <NSObject>
//
//- (void)deleteTag:(NSInteger)index;
//
//@end


@interface DDTagButton : UIButton

//@property (nonatomic,weak)id<DeleteTagDelegae>deleteTagDelegae;

+(DDTagButton *)buttonWithTixt:(NSString *)str Color:(UIColor *)color andImage:(UIImage *)image andIsDelete:(BOOL)isDelete;


@end
