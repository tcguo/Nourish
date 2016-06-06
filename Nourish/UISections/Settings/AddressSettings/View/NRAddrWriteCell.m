//
//  NRAddrWriteCell.m
//  Nourish
//
//  Created by gtc on 15/4/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddrWriteCell.h"

@interface NRAddrWriteCell ()<UITextFieldDelegate>

@end

@implementation NRAddrWriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.top.and.bottom.equalTo(0);
            make.width.equalTo(40);
        }];
    
        __weak typeof(self) weakself = self;
        [self.textField makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakself.titleLabel.mas_right).offset(10);
            make.right.equalTo(0);
            make.top.and.bottom.equalTo(0);
        }];
    }
    
    return self;
}

- (void)relayoutSubviews {
    CGFloat width = 40.f;
    if (self.titleLabel.text.length == 3) {
        width = 35.f;
    }
    if (self.titleLabel.text.length == 5) {
        width = 70.0f;
    }
    
    [self.titleLabel updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(20);
        make.top.and.bottom.equalTo(0);
        make.width.equalTo(@(width));
    }];
    
    [self.textField updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.right).offset(10);
        make.right.equalTo(0);
        make.top.and.bottom.equalTo(0);
    }];
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
   

}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = NRFont(FontLabelSize);
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.textColor = [UIColor blackColor];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = SysFont(FontTextFieldSize-2);
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _textField.delegate = self;
    }
    
    return _textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.textField resignFirstResponder];
}

- (void)resignFirstResponderByCell {
    [self.textField resignFirstResponder];
}

@end
