//
//  UIView+BDSExtension.m
//  BDStockClient
//
//  Created by guoke on 14/10/22.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "UIView+BDSExtension.h"

@implementation UIView (BDSExtension)

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset blurRadius:(CGFloat)blurRadius {
    [self.layer setShadowColor:color.CGColor];
    [self.layer setShadowOpacity:opacity];
    [self.layer setShadowOffset:offset];
    [self.layer setShadowRadius:blurRadius];
}

- (UIViewController *)viewController {
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

- (void)pushView:(UIView *)view completion:(void (^)(BOOL finished))completion {
    if (view == self) {
        return ;
    }
    [view setFrame:CGRectMake(CGRectGetWidth(self.bounds),
                              0,
                              CGRectGetWidth(self.bounds),
                              CGRectGetHeight(self.bounds))];
    [self addSubview:view];
    [UIView animateWithDuration:0.2 animations:^{
        [view setFrame:self.bounds];
    } completion:^(BOOL finished) {
        completion(finished);
    }];
}

- (void)popCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.2 animations:^{
        [self setFrame:CGRectMake(CGRectGetWidth(self.bounds),
                                  0,
                                  CGRectGetWidth(self.bounds),
                                  CGRectGetHeight(self.bounds))];
    } completion:^(BOOL finished) {
        completion(finished);
        [self removeFromSuperview];
    }];
}


@end
