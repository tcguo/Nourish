//
//  NRUINavigationBar.m
//  Nourish
//
//  Created by gtc on 15/7/10.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRUINavigationBar.h"

@implementation NRUINavigationBar


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect barFrame = self.frame;
    barFrame.size.height = 60;
    self.frame = barFrame;
}

@end
