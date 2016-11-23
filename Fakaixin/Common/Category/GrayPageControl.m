//
//  GrayPageControl.m
//  Fakaixin
//
//  Created by 刘胜南 on 16/8/8.
//  Copyright © 2016年 Fakaixin. All rights reserved.
//

#import "GrayPageControl.h"

@implementation GrayPageControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
//        self.backgroundColor = [UIColor redColor];
        self.contentMode = UIViewContentModeScaleAspectFit;
        activeImage = [UIImage imageNamed:@"img_page_current_tint_color"];
        inactiveImage = [UIImage imageNamed:@"img_page_tint_color"];
    }
    return self;
}
-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView * dot = [self imageViewForSubview:  [self.subviews objectAtIndex: i]];
        if (i == self.currentPage)
        {
            dot.image = activeImage;
        }
        else
        {
            dot.image = inactiveImage;
        }
    }
}
- (UIImageView *) imageViewForSubview: (UIView *) view
{
    UIImageView * dot = nil;
    if ([view isKindOfClass: [UIView class]])
    {
        for (UIView* subview in view.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView *)subview;
                break;
            }
        }
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 3, 3)];
            dot.contentMode = UIViewContentModeScaleAspectFit;
            view.contentMode = UIViewContentModeScaleAspectFit;
            [view addSubview:dot];
        }
    }
    else
    {
        dot = (UIImageView *) view;
    }
    return dot;
}
-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}
//-(IBAction) pageChanged:(id)sender
//{
//    int page = PageIndicator.currentPage;
//    
//    // update the scroll view to the appropriate page
//    CGRect frame = ImagesScroller.frame;
//    frame.origin.x = frame.size.width * page;
//    frame.origin.y = 0;
//    [ImagesScroller scrollRectToVisible:frame animated:YES];
//}
@end
