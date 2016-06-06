//
//  NRAddrSelectCell.m
//  Nourish
//
//  Created by tcguo on 15/9/15.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddrSelectCell.h"

@implementation NRAddrSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.top.and.bottom.equalTo(@0);
        }];
        
        UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"takeout_ic_auto_locate"]];
        [self.contentView addSubview:imgv];
        self.iconImgView = imgv;
        [self.iconImgView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.right).offset(5);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        [self.textField makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImgView.right).offset(5);
            make.right.equalTo(0);
            make.top.and.bottom.equalTo(0);
        }];

    }
    
    return self;
}

- (UILabel *)titleLabel
{
    if (_titleLabel) {
        return _titleLabel;
    }
    
    _titleLabel = [UILabel new];
    _titleLabel.font = NRFont(FontLabelSize);
    _titleLabel.textColor = [UIColor blackColor];
    return _titleLabel;
}

- (UITextField *)textField
{
    if (_textField) {
        return _textField;
    }
    
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.textColor = [UIColor blackColor];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.font = SysFont(FontTextFieldSize-2);
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
//    _textField.delegate = self;
    
    return _textField;
}


@end
