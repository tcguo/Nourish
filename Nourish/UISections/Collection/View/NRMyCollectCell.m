//
//  NRMyCollectCell.m
//  Nourish
//
//  Created by gtc on 15/8/14.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRMyCollectCell.h"
#import "UIImageView+WebCache.h"

@interface NRMyCollectCell ()
{
    UIImageView *_wpThemeImgv;
    UILabel *_wpNameLabel;
    UILabel *_wptNameLabel;
    UILabel *_priceLabel;
    UILabel *_mealTypesLabel;
}
@end

@implementation NRMyCollectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _wpThemeImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weekplan"]];
        _wpThemeImgv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 440/2);
        [self.contentView addSubview:_wpThemeImgv];
        
        UIView *infoContainerView = [UIView new];
        infoContainerView.frame = CGRectMake(0, 220, SCREEN_WIDTH, 126/2);
        [self.contentView addSubview:infoContainerView];
        
        _wpNameLabel = [UILabel new];
        _wpNameLabel.text = @"七天减脂午餐周计划";
        _wpNameLabel.font = SysFont(16);
        _wpNameLabel.textColor = RgbHex2UIColor(0x43, 0x43, 0x43);
        [infoContainerView addSubview:_wpNameLabel];
        CGFloat padding = 12;
        [_wpNameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(padding);
            make.height.equalTo(18);
        }];
        
        _wptNameLabel = [UILabel new];
        _wptNameLabel.text = @"轻盈减脂周计划";
        _wptNameLabel.font = SysFont(14);
        _wptNameLabel.textColor = RgbHex2UIColor(0xcd, 0xcd, 0xcd);
        [infoContainerView addSubview:_wptNameLabel];
        [_wptNameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_wpNameLabel.mas_bottom).offset(6);
            make.left.equalTo(padding);
            make.height.equalTo(14);
        }];

        _mealTypesLabel = [UILabel new];
        _mealTypesLabel.text = @"早+午+茶";
        _mealTypesLabel.font = SysFont(13);
        _mealTypesLabel.textColor = ColorRed_Normal;
        [infoContainerView addSubview:_mealTypesLabel];
        [_mealTypesLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_wpNameLabel.mas_centerY);
//            make.top.equalTo(padding +3);
            make.left.equalTo(_wpNameLabel.mas_right).offset(12);
            make.height.equalTo(15);
        }];

        _priceLabel = [UILabel new];
        _priceLabel.text = @"￥59";
        _priceLabel.font = SysFont(17);
        _priceLabel.textColor = ColorRed_Normal;
        [infoContainerView addSubview:_priceLabel];
        [_priceLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(infoContainerView.mas_centerY);
            make.right.equalTo(-padding);
            make.height.equalTo(17);
        }];
    }
    return self;
}

- (void)setModel:(NRCollectWeekPlanInfo *)model {
    // TODO:我的收藏价格还不对
    NSURL *imageUrl = [NSURL URLWithString:model.wpImage];
    [_wpThemeImgv sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"wpt-default"]];
    _wpNameLabel.text = model.wpName;
    _wptNameLabel.text = model.wptName;
   
    NSMutableString *dinners = [NSMutableString string];
    if ([model.smwIds.firstObject integerValue] != 0) {
        [dinners appendString:@"早+"];
    }
    
    [dinners appendString:@"午"];
    
    if ([model.smwIds.lastObject integerValue] != 0) {
        [dinners appendString:@"+茶"];
    }
    
    _mealTypesLabel.text = dinners;
    _priceLabel.text = [NSString stringWithFormat:@"￥%0.2f", [model.price floatValue]];
}

@end
