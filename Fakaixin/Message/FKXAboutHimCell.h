//
//  FKXAboutHimCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXAboutHimCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *tagBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagBackViewH;

@property (nonatomic,strong) NSDictionary *userD;

@end
