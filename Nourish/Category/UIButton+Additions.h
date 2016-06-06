//
//  UIButton+UIButtonImageWithLable.h
//  Nourish
//
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Additions)

- (void)centerImageAndTitle:(float)space;
- (void)centerImageAndTitle;

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType;

- (void)setBackgroundColorForState:(UIColor *)backgroundColor forState:(UIControlState)stateType;


@property (nonatomic, copy) UIFont * appearanceFont UI_APPEARANCE_SELECTOR;

@end
