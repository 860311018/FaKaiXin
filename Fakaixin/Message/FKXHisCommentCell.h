//
//  FKXHisCommentCell.h
//  Fakaixin
//
//  Created by apple on 2016/11/9.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKXHisCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *commentL;
@property (weak, nonatomic) IBOutlet UIImageView *zanImgV;
@property (weak, nonatomic) IBOutlet UILabel *zanCount;
@property (weak, nonatomic) IBOutlet UIImageView *openImgV;
@property (weak, nonatomic) IBOutlet UIButton *moreCommentBtn;

@end
