//
//  LXActivity.h
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXActivity;
@protocol LXActivityDelegate <NSObject>

@optional
- (void)didClickOnImageIndex:(NSInteger)imageIndex;
- (void)didClickOnCancelButton:(NSDictionary *)data;
- (void)didClickOnComfirmButton:(LXActivity *)activity userInfo:(NSDictionary *)data;
@end

@interface LXActivity : UIView

@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, assign) id<LXActivityDelegate>delegate;
@property (nonatomic, assign) CGFloat LXActivityHeight;
@property (nonatomic, assign) AppDelegate *appDelegate ;

/**
 *  通用初始化
 *
 *  @param height   高度
 *  @param delegate <#delegate description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithHeight:(CGFloat)height delegate:(id<LXActivityDelegate>)delegate;

- (id)initWithTitle:(NSString *)title delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray;

- (id)initWithTitle:(NSString *)title height:(CGFloat)height delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)changeCancelButtonTitle:(NSString *)title;
- (void)showInView:(UIView *)view;
- (void)didClickOnImageIndex:(UIButton *)button;
- (void)tappedCancel;

@end


