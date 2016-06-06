//
//  NRUIHistoryLocationCell.m
//  Nourish
//
//  Created by gtc on 15/7/10.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRUIHistoryLocationCell.h"

@interface NRUIHistoryLocationCell ()
{
    
}



@end

@implementation NRUIHistoryLocationCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.nameLabel = [UILabel new];
        self.nameLabel.text = @"郭天池";
        self.nameLabel.textColor = RgbHex2UIColor(0XAE, 0XAE, 0XAE);
        self.nameLabel.font = SysFont(14);
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(@15);
            make.height.equalTo(@14);
        }];
        
        self.phoneLabel = [UILabel new];
        self.phoneLabel.textColor = RgbHex2UIColor(0XAE, 0XAE, 0XAE);
        self.phoneLabel.text = @"18612839407";
        self.phoneLabel.font = SysFont(14);
        [self.contentView addSubview:self.phoneLabel];
        [self.phoneLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@15);
            make.left.equalTo(@112);
            make.height.equalTo(@14);
        }];
        
        self.addrLabel = [UILabel new];
        self.addrLabel.textColor = RgbHex2UIColor(0X4d, 0X4d, 0X4d);
        self.addrLabel.text = @"上地南路";
        self.addrLabel.font = SysFont(14);
        [self.contentView addSubview:self.addrLabel];
        [self.addrLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(15);
            make.left.equalTo(15);
            make.height.equalTo(@14);
        }];

    }
    
    return self;
}

@end
