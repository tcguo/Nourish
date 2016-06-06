//
//  UIView+BDSExtension.h
//  BDStockClient
//
//  Created by guoke on 14/10/22.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BDSExtension)

/**
 *  设置外阴影
 *
 *  @param color      颜色
 *  @param opacity    透明度
 *  @param offset     阴影偏移量
 *  @param blurRadius 半径
 */
- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset blurRadius:(CGFloat)blurRadius;

/**
 *  获取view所在Controller
 *
 *  @return UIViewController
 */

- (UIViewController *)viewController;
/**
 *  view转场的push操作
 *
 *  @param view
 *  @param completion
 */

- (void)pushView:(UIView *)view completion:(void (^)(BOOL finished))completion;
/**
 *  view转场的pop操作
 *
 *  @param completion
 */

- (void)popCompletion:(void (^)(BOOL finished))completion;

@end
