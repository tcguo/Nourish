//
//  UILabel+Additions.m
//  Nourish
//
//  Created by gtc on 15/1/15.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel (Additions)

- (CGRect)getLabelSizeWithAttr:(NSDictionary *)attr
{
    CGSize size = CGSizeMake(320,2000);
    CGRect labelsize = [self.text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine attributes:attr context:nil];
    return labelsize;
}

-(void)setAppearanceFont:(UIFont *)font {
    if (font)
        [self setFont:font];
}

-(UIFont *)appearanceFont {
    return self.font;
}

- (void)setAppappearanceTextColor:(UIColor *)appappearanceTextColor
{
    if (appappearanceTextColor) {
        [self setTextColor:appappearanceTextColor];
    }
}

- (UIColor *)appappearanceTextColor
{
    return self.textColor;
}

@end
