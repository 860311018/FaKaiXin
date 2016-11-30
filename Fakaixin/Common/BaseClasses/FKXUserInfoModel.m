//
//  FKXUserInfoModel.m
//  Fakaixin
//
//  Created by Connor on 10/16/15.
//  Copyright © 2015 Fakaixin. All rights reserved.
//

#import "FKXUserInfoModel.h"

@implementation FKXUserInfoModel


//- (FKXUserInfoModel *)initCommodityWithModel:(FKXUserInfoModel *)model andFrame:(CGFloat)frame {
//    if (self = [super init]) {
//        self.commodityFrame = [CommodityFrame commodityFrameWithModel:model andFrame:frame];
//    }
//    return self;
//}

@end


@interface CommodityFrame ()


@end

@implementation CommodityFrame

+ (CommodityFrame *)commodityFrameWithModel:(FKXUserInfoModel *)model andFrame:(CGFloat)frame {
    return [[self alloc]initCommodityModel:model andFrame:frame];
}

- (CommodityFrame *)initCommodityModel:(FKXUserInfoModel *)model andFrame:(CGFloat)frame {
    if (self = [ super init]) {
        
        NSString *name = model.name;
        NSString *profile = model.profile;
        NSString *cureCount = [model.cureCount stringValue];
        
        NSString *goodStr = @"";
        NSArray *goodAt = model.goodAt;
        //婚恋出轨   失恋阴影  夫妻相处  婆媳关系
        for (int i=0; i<goodAt.count; i++) {
            NSString *str = @"";
            if (i==0) {
                if ([goodAt[i] integerValue]==0) {
                    str = @"婚恋出轨";
                }else if ([goodAt[i] integerValue]==1) {
                    str = @"失恋阴影";
                }else if ([goodAt[i] integerValue]==2) {
                    str = @"夫妻相处";
                }else if ([goodAt[i] integerValue]==3) {
                    str = @"婆媳关系";
                }
                
            }else{
                if ([goodAt[i] integerValue]==0) {
                    str = [NSString stringWithFormat:@"、%@",@"婚恋出轨"];
                }else if ([goodAt[i] integerValue]==1) {
                    str = [NSString stringWithFormat:@"、%@",@"失恋阴影"];
                }else if ([goodAt[i] integerValue]==2) {
                    str = [NSString stringWithFormat:@"、%@",@"夫妻相处"];
                }else if ([goodAt[i] integerValue]==3) {
                    str = [NSString stringWithFormat:@"、%@",@"婆媳关系"];
                }
            }
            goodStr = [goodStr stringByAppendingString:str];
        }
        
        NSString *introStr = [NSString stringWithFormat:@"你好，我是%@ 心理咨询专家，资深婚恋情感咨询师,%@。 擅长%@类的问题，已经在伐开心中成功治愈了%@人，在这里聆听解决你的烦恼，给出中肯的建议",name,profile,goodStr,cureCount];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 20)];
        label.font = [UIFont systemFontOfSize:15];
        label.text = introStr;
        [label sizeToFit];
        
        CGFloat height = CGRectGetHeight(label.frame);
        
//        model.headerH =height+150+10+20;
//        model.introStr = introStr;
        
    }
    return self;
}

@end

