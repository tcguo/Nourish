//
//  NRSettingsIndexAccountNotLoginCell.m
//  Nourish
//   账号未登录
//  Created by gtc on 15/8/14.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSettingsIndexAccountNotLoginCell.h"

@interface NRSettingsIndexAccountNotLoginCell ()
{
    UIImageView *_headerImgv;
}

@end

@implementation NRSettingsIndexAccountNotLoginCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headerImgv  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting-avatarbg"]];
        _headerImgv.frame = CGRectMake(0, 0, self.bounds.size.width, 128);
        _headerImgv.userInteractionEnabled = YES;
        [self.contentView addSubview:_headerImgv];

        //添加登录/注册按钮
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headerImgv addSubview:loginButton];
        loginButton.layer.borderColor = ColorRed_Normal.CGColor;
        loginButton.layer.borderWidth = 0.5;
        loginButton.layer.masksToBounds = YES;
        loginButton.layer.cornerRadius = CornerRadius;
        loginButton.titleLabel.font  = NRFont(FontButtonTitleSize);
        [loginButton setTitle:@"登录/注册" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
//        [loginButton setBackgroundColorForState:[UIColor whiteColor] forState:UIControlStateNormal];
//        [loginButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
//
        [loginButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headerImgv.centerX);
            make.centerY.equalTo(_headerImgv.centerY);
            make.height.equalTo(ButtonDefaultHeight);
            make.width.equalTo(150);
        }];
    }
    
    return self;
}

- (void)login:(id)sender
{
    [self.settingsIndexVC login];
}

- (void)layoutSubviews
{
    _headerImgv.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [super layoutSubviews];
}

@end
