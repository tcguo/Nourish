//
//  NRActivityView.h
//  Nourish
//
//  Created by tcguo on 15/12/10.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseView.h"

@interface NRActivityView :NRBaseView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGFloat contentViewHeight;

- (void)setupUI;
- (void)showInView:(UIView *)view;
- (void)dismiss;
@end
