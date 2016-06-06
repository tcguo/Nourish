//
//  NRAddAddressButtonCell.m
//  Nourish
//
//  Created by gtc on 15/3/9.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddAddressButtonCell.h"

@implementation NRAddAddressButtonCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.titleLabel];
        
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.centerY);
            make.centerX.equalTo(self.contentView.centerX).with.offset(10);
        }];
        
        [self.iconImageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.centerY);
            make.right.equalTo(self.titleLabel.mas_left).with.offset(-5);
            make.width.and.height.equalTo(20);
        }];
        
    }
    
    return self;
}



- (UIImageView *)iconImageView
{
    if (_iconImageView) {
        return _iconImageView;
    }
    
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return _iconImageView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel) {
        return _titleLabel;
    }
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = NRFont(FontLabelSize-1);
    _titleLabel.textColor = ColorRed_Normal;
    
    return _titleLabel;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
