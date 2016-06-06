//
//  UIView+ActivityIndicator.m
//  Nourish
//
//  Created by tcguo on 15/10/23.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "UIView+ActivityIndicator.h"
#import "UIButton+Additions.h"
#import <objc/runtime.h>

static char NRWaitingIndicator;
static char NRFailIndicator;
static char NRNoDataIndicator;

@implementation UIView (ActivityIndicator)

- (void)setIndicatorView:(NRWaitingIndicatorView *)indicatorView {
    [self willChangeValueForKey:@"indicatorView"];
    objc_setAssociatedObject(self, &NRWaitingIndicator,
                             indicatorView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"indicatorView"];
}

- (NRWaitingIndicatorView *)indicatorView {
    return objc_getAssociatedObject(self, &NRWaitingIndicator);
}

- (void)setFailView:(UIView *)failView {
    [self willChangeValueForKey:@"failView"];
    objc_setAssociatedObject(self, &NRFailIndicator,
                             failView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"failView"];
}

- (UIView *)failView {
    return objc_getAssociatedObject(self, &NRFailIndicator);
}

- (void)setNodataLabel:(UILabel *)nodataLabel {
    [self willChangeValueForKey:@"nodataLabel"];
    objc_setAssociatedObject(self, &NRNoDataIndicator,
                             nodataLabel,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"nodataLabel"];
}

- (UILabel *)nodataLabel {
    return objc_getAssociatedObject(self, &NRNoDataIndicator);
}


- (void)addNoDataLabelWithTitle:(NSString *)title {
    if (!self.nodataLabel) {
        UILabel *tmpLabel  = [[UILabel alloc] init];
        [self addSubview:tmpLabel];
        self.nodataLabel = tmpLabel;
        self.nodataLabel.textColor = RgbHex2UIColor(0xa6, 0xa6, 0xa6);
        self.nodataLabel.font = SysFont(14);
        self.nodataLabel.textAlignment = NSTextAlignmentCenter;
    }
    self.nodataLabel.text = title;
    self.nodataLabel.hidden = NO;
}

- (void)removeNoDataLabel {
    if (self.nodataLabel) {
        self.nodataLabel.hidden = YES;
    }
}

- (void)addFailIndicatorViewWithTitle:(NSString *)title {
    if (!self.failView) {
        CGFloat y = (SCREEN_HEIGHT-NAV_BAR_HEIGHT-145)/2 -50;
        UIView *_nonetworkView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.bounds.size.width, 145)];
        [self addSubview:_nonetworkView];
        self.failView = _nonetworkView;
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"network-no"]];
        imgView.frame = CGRectMake((_nonetworkView.bounds.size.width-95)/2, 0, 95, 120);
        [_nonetworkView addSubview:imgView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = title;
        tipLabel.textColor = RgbHex2UIColor(0xa6, 0xa6, 0xa6);
        tipLabel.font = SysFont(14);
        tipLabel.tag = 100;
        [_nonetworkView addSubview:tipLabel];
        
        [tipLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nonetworkView);
            make.top.equalTo(imgView.mas_bottom).offset(10);
            make.height.equalTo(15);
        }];
    }
    
    UILabel *titleLabel = (UILabel *)[self.failView viewWithTag:100];
    titleLabel.text = title;
    self.failView.hidden = NO;
}

- (void)addFailIndicatorViewWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font {
    [self addFailIndicatorViewWithTitle:title];
     UILabel *titleLabel = (UILabel *)[self.failView viewWithTag:100];
    if (titleColor) {
        titleLabel.textColor = titleColor;
    }
    if (font) {
        titleLabel.font = font;
    }
}

- (void)removeFailIndicatorView {
    if (self.failView) {
        self.failView.hidden = YES;
    }
}

- (void)addRetryIndicatorViewWithTitle:(NSString *)title actionHandler:(void (^)(void))actionHandler {
    if (!self.indicatorView) {
        CGFloat y = (SCREEN_HEIGHT-NAV_BAR_HEIGHT-200)/2 - 50;
        NRWaitingIndicatorView *indicatorView = [[NRWaitingIndicatorView alloc] initWithTitle:title];
        indicatorView.frame = CGRectMake(0, y-50, self.bounds.size.width, 200);
        [self addSubview:indicatorView];
       self.indicatorView = indicatorView;
    }
    
    self.indicatorView.title = title;
    self.indicatorView.retryActionHandler = actionHandler;
    self.indicatorView.hidden = NO;
}

- (void)removeRetryIndicatorView {
    self.indicatorView.hidden = YES;
}

@end


@interface NRWaitingIndicatorView()

@property(nonatomic, strong) UIButton *tapButton;

@end

@implementation NRWaitingIndicatorView

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"network-no"]];
        imgView.frame = CGRectMake((self.bounds.size.width-95)/2, 0, 95, 120);
        [self addSubview:imgView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = title;
        tipLabel.textColor = RgbHex2UIColor(0xa6, 0xa6, 0xa6);
        tipLabel.font = SysFont(14);
        tipLabel.tag = 100;
        [self addSubview:tipLabel];
        
        [tipLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX);
            make.top.equalTo(imgView.mas_bottom).offset(10);
            make.height.equalTo(15);
        }];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshButton.layer.borderColor = ColorRed_Normal.CGColor;
        refreshButton.layer.borderWidth = 1;
        refreshButton.layer.cornerRadius = CornerRadius;
        refreshButton.layer.masksToBounds = YES;
        [refreshButton setTitle:@"重新加载" forState:UIControlStateNormal];
        [refreshButton setTitle:@"重新加载" forState:UIControlStateHighlighted];
        [refreshButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
        [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [refreshButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
        [refreshButton setBackgroundColorForState:[UIColor clearColor] forState:UIControlStateNormal];
        
        refreshButton.titleLabel.font = SysFont(16);
        [self addSubview:refreshButton];
        [refreshButton addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
        [refreshButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX);
            make.top.equalTo(tipLabel.mas_bottom).offset(20);
            make.width.equalTo(120);
            make.height.equalTo(34);
        }];
    
        self.tapButton = refreshButton;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    UILabel *label = (UILabel *)[self viewWithTag:100];
    label.text = _title;
}

- (void)refreshData:(id)sender {
    if (self.retryActionHandler) {
        self.retryActionHandler();
    }
}

@end

