//
//  NRUIHandLocationCell.m
//  Nourish
//
//  Created by gtc on 15/7/10.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRUIHandLocationCell.h"

@interface NRUIHandLocationCell ()
{
    UIImageView *_iconImgv;
    UILabel *_nameLabel;
}

@end

@implementation NRUIHandLocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        _iconImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wp-switchaddress-icon-location"]];
        [self.contentView addSubview:_iconImgv];
        
        [_iconImgv makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.centerY);
            make.left.equalTo(@16);
            make.height.and.width.equalTo(@18);
        }];
        
        _nameLabel = [UILabel new];
        _nameLabel.textColor = ColorRed_Normal;
        _nameLabel.font = SysFont(15);
        _nameLabel.text = @"点击定位到当前位置";
        [self.contentView addSubview:_nameLabel];
        [_nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.centerY);
            make.left.equalTo(_iconImgv.mas_right).offset(10);
            make.height.equalTo(16);
        }];
        
    }
    
    return self;
}

@end
