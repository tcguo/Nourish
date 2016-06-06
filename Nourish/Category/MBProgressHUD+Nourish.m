//
//  MBProgressHUD+Nourish.m
//  Nourish
//
//  Created by gtc on 15/1/14.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "MBProgressHUD+Nourish.h"

#define kMBCornerRadius 4.0

@implementation MBProgressHUD (Nourish)

+ (void)showTips:(UIView *)view text:(NSString *)tips {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.labelText = tips;
    hud.opacity = 0.6f;
    hud.labelFont = SysFont(14);
    hud.cornerRadius = kMBCornerRadius;
    hud.mode = MBProgressHUDModeText;
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(1.5);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];

}

+ (void)showErrormsg:(UIView *)view msg:(NSString *)msg {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.labelText = msg;
    hud.opacity = 0.6;
    hud.labelFont = SysFont(14);
    hud.cornerRadius = kMBCornerRadius;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-tip"]];
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

+ (void)showErrormsg:(UIView *)view msg:(NSString *)msg completionBlock:(void (^)())completion {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.labelText = msg;
    hud.opacity = 0.6;
    hud.labelFont = SysFont(14);
    hud.cornerRadius = kMBCornerRadius;
    //    hud.detailsLabelText =@"12122";
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-tip"]];
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        if (completion) {
            completion();
        }
        [hud removeFromSuperview];
    }];
}

+ (void)showErrormsg:(UIView *)view msg:(NSString *)msg detailMsg:(NSString *)detailMsg completionBlock:(void (^)())completion {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.labelText = msg;
    hud.labelFont = SysFont(14);
    hud.opacity = 0.6;
    hud.cornerRadius = kMBCornerRadius;
    hud.detailsLabelText = detailMsg;
    hud.detailsLabelFont = SysFont(12);
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-tip"]];
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        if (completion) {
            completion();
        }
        [hud removeFromSuperview];
    }];
}

+ (void)showErrormsgWithoutIcon:(UIView *)view title:(NSString *)msg detail:(NSString *)detailMsg {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.labelText = msg;
    hud.labelFont = SysFont(14);
    hud.opacity = 0.6;
    hud.cornerRadius = kMBCornerRadius;
    if (detailMsg) {
        hud.detailsLabelText = detailMsg;
    }
    hud.mode = MBProgressHUDModeText;
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2.0);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}


+ (void)showDone:(UIView *)view {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 0.6;
    hud.cornerRadius = kMBCornerRadius;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-done"]];
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

+ (void)showDoneWithText:(UIView *)view text:(NSString *)text {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 0.6;
    hud.cornerRadius = kMBCornerRadius;
    hud.labelText = text;
    hud.labelFont = SysFont(14);
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-done"]];
    
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

+ (void)showDoneWithText:(UIView *)view text:(NSString *)text completionBlock:(void(^)())completion {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 0.6;
    hud.cornerRadius = kMBCornerRadius;
    hud.labelText = text;
    hud.labelFont = SysFont(14);
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-done"]];
    
    [view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        if (completion) {
            completion();
        }
        [hud removeFromSuperview];
    }];
}

+ (void)showErrormsgOnWindow:(NSString *)msg {
    [self showErrormsg:[UIApplication sharedApplication].keyWindow msg:msg];
}

+ (MB_INSTANCETYPE)showActivityWithText:(UIView *)view text:(NSString *)text animated:(BOOL)animated {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.opacity = 0.6;
    hud.cornerRadius = kMBCornerRadius;
    hud.labelText = text;
    hud.labelFont = SysFont(14);
    [view addSubview:hud];
    [hud show:animated];
    return hud;
}

+ (BOOL)hideActivityWithText:(UIView *)view animated:(BOOL)animated {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud != nil) {
        [hud removeFromSuperview];
        return YES;
    }
    return NO;
}

+ (void)showAlert:(NSString *)title msg:(NSString *)msg delegate:(id)delegate cancelBtnTitle:(NSString *)cancelTitle {
    if (title.length == 0) {
        title = @"提示";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:delegate
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:nil, nil];
    
    [alert show];

}


+ (void)beginNetworkActivity {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

+ (void)endNetworkActivity {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
@end
