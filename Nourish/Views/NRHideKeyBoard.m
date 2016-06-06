//
//  NRHideKeyBoard.m
//  Nourish
//
//  Created by gtc on 15/4/14.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRHideKeyBoard.h"

@implementation NRHideKeyBoard

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    [self endEditing:YES];
    return result;
}

@end
