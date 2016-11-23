//
//  ScrllTitleView.h
//  Fakaixin
//
//  Created by apple on 2016/11/22.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrllTitleView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *name2L;
@property (weak, nonatomic) IBOutlet UILabel *proL;

@property (weak, nonatomic) IBOutlet UILabel *label2;

+(id)creatTitleView;

@end
