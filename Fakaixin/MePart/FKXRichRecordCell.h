//
//  FKXRichRecordCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/7.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXRichRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recordL;
@property (weak, nonatomic) IBOutlet UILabel *recordTime;
@property (weak, nonatomic) IBOutlet UILabel *recordCount;

@property (weak, nonatomic) IBOutlet UILabel *recordDetail;

@end
