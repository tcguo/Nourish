//
//  UILabel+Additions.h
//  Nourish
//
//  Created by gtc on 15/1/15.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Additions)

- (CGRect)getLabelSizeWithAttr:(NSDictionary *)attr;

@property (nonatomic, copy) UIFont * appearanceFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *appappearanceTextColor UI_APPEARANCE_SELECTOR;

@end
