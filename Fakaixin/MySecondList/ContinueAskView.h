//
//  ContinueAskView.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/7/15.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXSecondAskModel.h"

@interface ContinueAskView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UITextView *myTeV;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property(nonatomic, strong)FKXSecondAskModel * model;

@end
