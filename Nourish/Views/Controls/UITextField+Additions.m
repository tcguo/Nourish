//
//  UITextField+MethodAddition.m
//  BMGameSDK
//
//  Created by gtc on 14-5-12.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "UITextField+Additions.h"

@implementation UITextField (MethodAddition)

- (BOOL)textIsNil
{
    if (self.text == nil || [self.text isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

@end
