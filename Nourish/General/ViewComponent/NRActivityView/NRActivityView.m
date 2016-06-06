//
//  NRActivityView.m
//  Nourish
//
//  Created by tcguo on 15/12/10.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRActivityView.h"

@interface NRActivityView ()

@property (nonatomic, strong) UIButton *dismissButton;

@end

@implementation NRActivityView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [UIColor clearColor];
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)setupUI {
    [self addSubview:self.dismissButton];
    [self addSubview:self.contentView];
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
    self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.contentViewHeight);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT-_contentViewHeight, SCREEN_WIDTH, _contentViewHeight);
                         self.dismissButton.frame = CGRectMake(0, 0, self.frame.size.width, SCREEN_HEIGHT - self.contentViewHeight);
                         self.dismissButton.alpha = 0.5;
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)dismiss {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.contentViewHeight);
                         self.dismissButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                         self.dismissButton.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self.dismissButton removeFromSuperview];
                         [self.contentView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}



- (void)setContentViewHeight:(CGFloat)contentViewHeight {
    _contentViewHeight = contentViewHeight;
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_dismissButton setBackgroundColor:[UIColor blackColor]];
        _dismissButton.alpha = 0;
        [_dismissButton addTarget:self
                                  action:@selector(dismiss)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _dismissButton;
}


@end
