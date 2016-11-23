//
//  FKXCustomKeyboardUp.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/4/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
//自定义发心事的键盘弹出视图
@interface FKXCustomKeyboardUp : UIView
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;    //选择照片
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollview;    //滚动视图
@property (weak, nonatomic) IBOutlet UIButton *btnType;    //类型按钮
//@property(nonatomic, assign)BOOL isPublish;
@property (weak, nonatomic) IBOutlet UILabel *nimingL;
@property (weak, nonatomic) IBOutlet UILabel *quanxianL;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) IBOutlet UILabel *labRemind;

@property (weak, nonatomic) IBOutlet UIView *viewSwich;
@property (weak, nonatomic) IBOutlet UILabel *labType;
@end
