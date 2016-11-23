//
//  FKXPublishMindViewController.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/11.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//


@class FKXSameMindViewController;

@protocol ProtocolFKXPublishMindViewController <NSObject>

- (void)clickedTheSendBtn:(NSString *)worryId;  //点击了发送按钮

@end
//发布心事界面
@interface FKXPublishMindViewController : FKXBaseViewController

@property(nonatomic, assign)id<ProtocolFKXPublishMindViewController> delegate;  //点击发送心事，展示tabbar主界面，开启等待动画

@end
