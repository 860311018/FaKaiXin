//
//  FKXMindCell.h
//  Fakaixin
//
//  Created by liushengnan on 16/9/18.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKXCourseModel.h"
//@class FKXMindCell;

//@protocol FKXMindCellProtocol <NSObject>
//
//- (void)clickToShareSession:(FKXMindCell *)cell withModel:(FKXCourseModel *)model;
//
//@end

//分享会或者课程cell
@interface FKXMindCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@property(nonatomic, strong)FKXCourseModel * courseModel;

@end
