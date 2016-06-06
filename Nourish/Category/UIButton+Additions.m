//
//  UIButton+UIButtonImageWithLable.m
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

- (void)centerImageAndTitle:(float)spacing
{
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}

- (void)centerImageAndTitle
{
    const int DEFAULT_SPACING = 6.0f;
    [self centerImageAndTitle:DEFAULT_SPACING];
}

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType
{
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, self.titleLabel.font, NSFontAttributeName, nil];
    
   
    CGSize titleSize = [title sizeWithAttributes:attributes];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-self.titleLabel.font.pointSize,
                                              0.0,
                                              0.0,
                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:self.titleLabel.font];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    
    [self setTitleEdgeInsets:UIEdgeInsetsMake(self.titleLabel.font.pointSize + self.titleLabel.font.pointSize*1/3,
                                              -image.size.width,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}

- (void)setBackgroundColorForState:(UIColor *)backgroundColor forState:(UIControlState)stateType
{
    CGSize imageSize = CGSizeMake(4, 4);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [backgroundColor set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage* colorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImg forState:stateType];
    
}

-(void)setAppearanceFont:(UIFont *)font {
    if (font)
        [self.titleLabel setFont:font];
}

-(UIFont *)appearanceFont {
    return self.font;
}

@end
