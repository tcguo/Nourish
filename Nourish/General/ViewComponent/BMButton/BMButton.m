 //
//  BMButton.m
//  BMGameSDK
//
//  Created by gavin on 14-5-29.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BMButton.h"
#import "Constants.h"
@implementation BMButton

+ (id)buttonWithType:(UIButtonType)buttonType
{
    UIButton *btn = [UIButton buttonWithType:buttonType];
    btn.exclusiveTouch = YES;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = CornerRadius;
//    btn.backgroundColor = ColorRed_Normal;
    [btn setBackgroundImage:[self getColorImage:ColorRed_Seleted] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[self getColorImage:ColorRed_Normal] forState:UIControlStateNormal];
//    [btn setBackgroundImage:<#(UIImage *)#> forState:UIControlStateDisabled];
    btn.titleLabel.font = NRFont(FontButtonTitleSize);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return (BMButton *)btn;
}

#pragma mark - helper

+ (UIImage*)getColorImage:(UIColor*)color
{
    CGSize imageSize = CGSizeMake(4, 4);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage* colorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImg;
}

@end
