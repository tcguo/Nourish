//
//  NRTimetSettingsLXActionSheet.m
//  Nourish
//
//  Created by gtc on 15/3/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRTimetSettingsLXActionSheet.h"

@implementation NRTimetSettingsLXActionSheet


- (UIButton *)creatOtherButtonWith:(NSString *)otherButtonTitle withPostion:(NSInteger )postionIndex {
    UIButton *theButton = [super creatOtherButtonWith:otherButtonTitle withPostion:postionIndex];
    [theButton setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
    [theButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [theButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    return theButton;
}

@end
