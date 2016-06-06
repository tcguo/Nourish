//
//  NRAddressListCell.m
//  Nourish
//
//  Created by gtc on 15/3/6.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddressListCell.h"

#define kImageNormal  [UIImage imageNamed:@"settings-address-edit-normal"]
#define kImageSelected [UIImage imageNamed:@"settings-address-edit-normalwhite"]

@interface NRAddressListCell ()
{
    UIImageView *_availableImgView;
    UIView *_bgView;
}
@end

@implementation NRAddressListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
       
        [self addSubview:self.nameLabel];
        [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(15);
            make.left.equalTo(self.left).offset(10);
            make.height.equalTo(15);
        }];
        
//        _bgView = [[UIView alloc] initWithFrame:self.bounds];
//        _bgView.backgroundColor = ColorRed_Normal;
//        self.selectedBackgroundView = _bgView;
        
        [self addSubview:self.accessoryButton];
        [self.accessoryButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.height.equalTo(self.mas_height);
            make.width.equalTo(40);
        }];
        
        [self addSubview:self.phoneLabel];
        [self.phoneLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(15);
            make.right.equalTo(self.accessoryButton.mas_left);
            make.height.equalTo(15);
        }];
        
        [self addSubview:self.addressLabel];
        [self.addressLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-15);
            make.right.equalTo(self.accessoryButton.mas_left);
            make.left.equalTo(self.mas_left).offset(10);
            make.height.equalTo(30);
        }];
        
        _availableImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"takeout_icon_not_in_range"]];
        [self addSubview:_availableImgView];
        _availableImgView.hidden = YES;
        [_availableImgView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.centerY);
            make.width.and.height.equalTo(58);
            make.right.equalTo(_accessoryButton.mas_left).offset(-10);
        }];
        
        self.nameLabel.textColor = ColorBaseFont;
        self.phoneLabel.textColor = ColorBaseFont;
        self.addressLabel.textColor = ColorBaseFont;
    }
    
    return self;
}

#pragma mark - Controls

//- (void)setSelected:(BOOL)selected
//{
//    if (!self.available) {
//        return;
//    }
//    
//    if (selected) {
//        self.backgroundColor = ColorRed_Normal;
//        self.contentView.backgroundColor= ColorRed_Normal;
////        self.selectedBackgroundView = _bgView;
//        self.nameLabel.textColor = [UIColor whiteColor];
//        self.phoneLabel.textColor = [UIColor whiteColor];
//        self.addressLabel.textColor = [UIColor whiteColor];
//        self.accessoryButton.selected = YES;
//    }
//    else {
//        self.nameLabel.textColor = ColorBaseFont;
//        self.phoneLabel.textColor = ColorBaseFont;
//        self.addressLabel.textColor = ColorBaseFont;
//        self.accessoryButton.selected = NO;
//        self.backgroundColor = [UIColor whiteColor];
////        self.selectedBackgroundView = nil;
//    }
//}

- (void)setAvailable:(BOOL)available
{
    _available = available;
    
    if (!_available) {
//        self.backgroundColor = ColorViewBg;
//        self.selectedBackgroundView = _bgView;
        _availableImgView.hidden = NO;
    }
    else {
        _availableImgView.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        
    }
}

- (UILabel *)nameLabel {
    if (_nameLabel) {
        return _nameLabel;
    }
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont boldSystemFontOfSize:FontLabelSize];
    
    return _nameLabel;
}

- (UILabel *)phoneLabel
{
    if (_phoneLabel) {
        return _phoneLabel;
    }
    
    _phoneLabel = [[UILabel alloc] init];
    _phoneLabel.font = [UIFont boldSystemFontOfSize:FontLabelSize];
    
    return _phoneLabel;
}
- (UILabel *)addressLabel
{
    if (_addressLabel) {
        return _addressLabel;
    }
    
    _addressLabel = [[UILabel alloc] init];
//    _addressLabel.font = [UIFont boldSystemFontOfSize:FontLabelSize-4];
    _addressLabel.font = NRFont(12);
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    return _addressLabel;
}

- (UIButton *)accessoryButton
{
    if (_accessoryButton) {
        return _accessoryButton;
    }
    
    _accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _accessoryButton.frame = CGRectMake(0, 0, 83, 83);
    [_accessoryButton setImage:kImageNormal forState:UIControlStateNormal];
    [_accessoryButton setImage:kImageSelected forState:UIControlStateSelected];

    return _accessoryButton;
}

@end
