//
//  GrayPageControl.h
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrayPageControl : UIPageControl<NSCoding>
{
    UIImage* activeImage;
    UIImage* inactiveImage;
}
@end
