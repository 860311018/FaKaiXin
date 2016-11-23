//
//  FKXRemoteNoticationView.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/5/13.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
//首次安装app的弹出通知的提示
@interface FKXRemoteNoticationView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@end
