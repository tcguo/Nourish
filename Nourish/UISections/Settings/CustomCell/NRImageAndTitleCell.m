//
//  NRImageAndTitleCell.m
//  Nourish
//
//  Created by tcguo on 15/11/21.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRImageAndTitleCell.h"

@interface NRImageAndTitleCell ()


@end

@implementation NRImageAndTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.left.equalTo(_iconImageView.mas_right).offset(10);
        }];
        
        [_iconImageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(_titleLabel.mas_left).offset(-10);
            make.height.and.width.equalTo(15);
        }];
    }
    
    return self;
}

@end
