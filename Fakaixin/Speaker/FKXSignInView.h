//
//  FKXSignInView.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/25.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
//整体签到自定义视图（包含s型签到）
@interface FKXSignInView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UILabel *labTodays;
@property (weak, nonatomic) IBOutlet UIButton *btnAddSign;

@end
