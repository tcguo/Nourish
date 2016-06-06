//
//  NRCouponCell.m
//  Nourish
//
//  Created by tcguo on 15/9/19.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRCouponCell.h"

@interface NRCouponCell ()
{
    UILabel *_typeLable;
    UILabel *_expriedDateLabel;
    UILabel *_amountLabel;
    UILabel *_tipsLabel;
    UIImageView *_stampImgView;
}

@end

@implementation NRCouponCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:containerView];
        [containerView makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(15);
            make.trailing.equalTo(-15);
            make.top.equalTo(15);
            make.bottom.equalTo(0);
        }];
        
        UIView *upContainerView = [[UIView alloc] init];
        [containerView addSubview:upContainerView];
        [upContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(0);
            make.bottom.equalTo(-6);
        }];
        
        
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coupon-corner-left"]];
        [containerView addSubview:leftImageView];
        [leftImageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.bottom.equalTo(0);
            make.width.equalTo(10);
            make.height.equalTo(3);
        }];

        UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coupon-corner-right"]];
        [containerView addSubview:rightImageView];
        [rightImageView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(0);
            make.bottom.equalTo(0);
            make.width.equalTo(10);
            make.height.equalTo(3);
        }];
        
        UIView *middlePaddingView = [[UIView alloc] init];
        middlePaddingView.backgroundColor = RgbHex2UIColor(0xf0, 0x56, 0x3c);
        [containerView addSubview:middlePaddingView];
        [middlePaddingView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftImageView.mas_right);
            make.right.equalTo(rightImageView.mas_left);
            make.height.equalTo(3);
            make.bottom.equalTo(0);
        }];
        
        //显示内容控件
        UIColor *fontColor = RgbHex2UIColor(0xf0, 0X56, 0X3C);
        _typeLable = [[UILabel alloc] init];
        _typeLable.font = SysFont(18);
        _typeLable.textColor = fontColor;
        [upContainerView addSubview:_typeLable];
        [_typeLable makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(15);
            make.top.equalTo(15);
            make.height.equalTo(18);
        }];
        
        _expriedDateLabel = [[UILabel alloc] init];
        _expriedDateLabel.font = SysFont(12);
        _expriedDateLabel.textColor = fontColor;
        [upContainerView addSubview:_expriedDateLabel];
        [_expriedDateLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(15);
            make.top.equalTo(_typeLable.mas_bottom).offset(5);
            make.height.equalTo(12);
        }];
        
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.font = SysFont(12);
        _tipsLabel.textColor = ColorBaseFont;
        [upContainerView addSubview:_tipsLabel];
        [_tipsLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(15);
            make.bottom.equalTo(upContainerView.mas_bottom).offset(-5);
            make.height.equalTo(12);
        }];
        
        _stampImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coupon-expired"]];
        [upContainerView addSubview:_stampImgView];
        [_stampImgView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.equalTo(0);
            make.height.greaterThanOrEqualTo(52);
            make.width.greaterThanOrEqualTo(54);
        }];
        
        _amountLabel = [[UILabel alloc] init];
        [upContainerView addSubview:_amountLabel];
        [_amountLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(upContainerView.mas_right).offset(-59);
            make.bottom.equalTo(upContainerView.mas_bottom).offset(-30);
            make.height.equalTo(23);
        }];

    }
    
    return self;
}

- (void)setModel:(NRCouponInfoModel *)model {
    _typeLable.text = model.name;
    _expriedDateLabel.text = [NSString stringWithFormat:@"有效期: %@", model.expiredDate];
    
    NSString *amount = [NSString stringWithFormat:@"￥%@", model.amount];;
    NSMutableAttributedString *_str = [[NSMutableAttributedString alloc] initWithString:amount];
    [_str addAttribute:NSForegroundColorAttributeName value:RgbHex2UIColor(0xf0, 0X56, 0X3C) range:NSMakeRange(0, amount.length)];
    [_str addAttribute:NSFontAttributeName value:SysFont(10) range:NSMakeRange(0,1)];
    [_str addAttribute:NSFontAttributeName value:SysFont(23) range:NSMakeRange(1,amount.length-1)];
    _amountLabel.attributedText = _str;
    _tipsLabel.text = model.wptName;
    
    switch (model.state) {
        case CouponStateAvailable:
            _stampImgView.image = [UIImage imageNamed:@"coupon-available"];
            break;
        case CouponStateExpired:
            _stampImgView.image = [UIImage imageNamed:@"coupon-expired"];
            break;
//        case CouponStateOccupy:
//            _stampImgView.image = [UIImage imageNamed:@"coupon-occupy"];
//            break;
        case CouponStateUsed:
            _stampImgView.image = [UIImage imageNamed:@"coupon-used"];
            break;
        default:
            break;
    }
}


@end

@implementation NRCouponInfoModel


@end
