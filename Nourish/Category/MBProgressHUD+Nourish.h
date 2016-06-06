//
//  MBProgressHUD+Nourish.h
//  Nourish
//
//  Created by gtc on 15/1/14.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Nourish)

+ (void)showTips:(UIView *)view text:(NSString *)tips;
+ (void)showErrormsg:(UIView *)view msg:(NSString *)msg;
+ (void)showErrormsgOnWindow:(NSString *)msg;
+ (void)showErrormsg:(UIView *)view msg:(NSString *)msg completionBlock:(void (^)())completion;
+ (void)showErrormsg:(UIView *)view msg:(NSString *)msg detailMsg:(NSString *)detailMsg completionBlock:(void (^)())completion;
+ (void)showErrormsgWithoutIcon:(UIView *)view title:(NSString *)msg detail:(NSString *)detailMsg;

+ (MB_INSTANCETYPE)showActivityWithText:(UIView *)view text:(NSString *)text animated:(BOOL)animated;
+ (BOOL)hideActivityWithText:(UIView *)view animated:(BOOL)animated;

+ (void)showDone:(UIView *)view;
+ (void)showDoneWithText:(UIView *)view text:(NSString *)text completionBlock:(void(^)())completion;
+ (void)showDoneWithText:(UIView *)view text:(NSString *)text;

+ (void)showAlert:(NSString *)title msg:(NSString *)msg delegate:(id)delegate cancelBtnTitle:(NSString *)cancelTitle;

+ (void)beginNetworkActivity;
+ (void)endNetworkActivity;
@end
