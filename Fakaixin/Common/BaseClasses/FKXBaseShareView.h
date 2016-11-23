//
//  FKXBaseShareView.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/6/17.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
//分享界面
@interface FKXBaseShareView : UIView

@property(nonatomic, copy)NSString * imageUrlStr;
@property(nonatomic, copy)NSString * urlStr;
@property(nonatomic, copy)NSString * title;
@property(nonatomic, copy)NSString * text;

@property   (nonatomic,strong)NSString<Optional> *hotId;//热门文章的id
@property(nonatomic, assign)BOOL needUpdateForwardNum;//分享热门文章需要调用回调，更新分享得次数


- (void)createSubviews;

-(instancetype)initWithFrame:(CGRect)frame
                 imageUrlStr:(NSString *)imageUrlStr
                      urlStr:(NSString *)urlStr
                       title:(NSString *)title
                        text:(NSString *)text;
@end
