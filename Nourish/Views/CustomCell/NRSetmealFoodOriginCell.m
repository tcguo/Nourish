//
//  NRSetmealFoodOriginCell.m
//  Nourish
//
//  Created by gtc on 15/6/7.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSetmealFoodOriginCell.h"

@implementation NRSetmealFoodOriginCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        
        self.lblName = [[UILabel alloc] init];
        [self.contentView addSubview:_lblName];
        self.lblName.textColor = RgbHex2UIColor(0x50, 0x50, 0x50);
        self.lblName.font = NRFont(15);
        [self.lblName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        self.lblText = [[UILabel alloc] init];
        [self.contentView addSubview:_lblText];
        self.lblText.textColor = RgbHex2UIColor(0x50, 0x50, 0x50);
        self.lblText.font = NRFont(15);
        [self.lblText makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(160);
            make.centerY.equalTo(self.contentView.centerY);
        }];

    }
    
    return self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
