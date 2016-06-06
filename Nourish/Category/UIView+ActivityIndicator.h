//
//  UIView+ActivityIndicator.h
//  Nourish
//
//  Created by tcguo on 15/10/23.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NRWaitingIndicatorView;

@interface UIView (ActivityIndicator)

//- (void)addWaitingIndicatorhWithActionHandler:(void (^)(void))actionHandler atPoint:(CGPoint)centerPoint;

- (void)addNoDataLabelWithTitle:(NSString *)title;
- (void)removeNoDataLabel;

- (void)addFailIndicatorViewWithTitle:(NSString *)title;
- (void)addFailIndicatorViewWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font;
- (void)removeFailIndicatorView;

- (void)addRetryIndicatorViewWithTitle:(NSString *)title actionHandler:(void (^)(void))actionHandler;
- (void)removeRetryIndicatorView;

@property (nonatomic, weak) NRWaitingIndicatorView *indicatorView;
@property (nonatomic, weak) UIView *failView;
@property (nonatomic, weak) UILabel *nodataLabel;

@end

@interface NRWaitingIndicatorView: UIView
{
    
}
- (instancetype)initWithTitle:(NSString *)title;
@property (nonatomic, copy) void (^retryActionHandler)(void);
//@property (nonatomic, assign) CGRect responseRect;
@property (nonatomic, strong) NSString *title;

//- (void)showWaitingWithText:(NSString *)text;
//- (void)showFailedWithText:(NSString *)text;
//- (void)showNoResponseFailWithText:(NSString *)text;

@end
