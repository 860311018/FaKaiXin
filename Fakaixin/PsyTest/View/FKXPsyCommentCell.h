//
//  FKXPsyCommentCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/10.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FKXPsyCommentModel;
@interface FKXPsyCommentCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *commentL;

@property (nonatomic,strong) FKXPsyCommentModel *model;

@end
