//
//  NRSettingsIndexAccountCell.m
//  Nourish
//
//  Created by gtc on 15/8/11.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSettingsIndexAccountCell.h"
#import "UIImageView+WebCache.h"
#include "NRLoginManager.h"

@interface NRSettingsIndexAccountCell ()
{
    UIImageView *_avatarImgv;
    UILabel *_nicknameLabel;
    UILabel *_bindPhoneLabel;
    UIImageView *_headerImgv;
}

@end


@implementation NRSettingsIndexAccountCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headerImgv  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting-avatarbg"]];
        _headerImgv.frame = CGRectMake(0, 0, self.bounds.size.width, 128);
        [self.contentView addSubview:_headerImgv];
        
        _avatarImgv = [[UIImageView alloc] init];
        _avatarImgv.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImgv.userInteractionEnabled = YES;
        [_headerImgv addSubview:_avatarImgv];
        [_avatarImgv makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headerImgv.centerY);
            make.left.equalTo(_headerImgv.left).offset(15*kAppUIScaleX);
            make.height.and.width.equalTo(66*kAppUIScaleY);
        }];
        _avatarImgv.layer.masksToBounds = YES;
        _avatarImgv.layer.cornerRadius = (66*kAppUIScaleY)/2;
        _avatarImgv.layer.borderWidth = 3;
        _avatarImgv.layer.borderColor = [UIColor whiteColor].CGColor;
        
        _nicknameLabel = [[UILabel alloc] init];
        [_headerImgv addSubview:_nicknameLabel];
        _nicknameLabel.font = SysFont(14);
        _nicknameLabel.textColor = [UIColor whiteColor];
        [_nicknameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headerImgv.mas_centerY).offset(-10);
            make.left.equalTo(_avatarImgv.right).offset(5);
            make.height.equalTo(FontLabelSize);
        }];
        
        _bindPhoneLabel = [[UILabel alloc] init];
        [_headerImgv addSubview:_bindPhoneLabel];
        _bindPhoneLabel.font = SysFont(14);
        _bindPhoneLabel.textColor = [UIColor whiteColor];
        [_bindPhoneLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headerImgv.mas_centerY).offset(10);
            make.left.equalTo(_avatarImgv.right).offset(5);
            make.height.equalTo(FontLabelSize);
        }];
        
    }
    
    return self;
}

- (void)layoutSubviews {
     [super layoutSubviews];
    _headerImgv.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)updateUserInfo {
    NRLoginManager *loginManager = [NRLoginManager sharedInstance];
    
    if (!STRINGHASVALUE([NRLoginManager sharedInstance].avatarUrl)) {
        _avatarImgv.image = [UIImage imageNamed:DefaultImageName_Avatar];
    } else {
        NSURL *url = [NSURL URLWithString:loginManager.avatarUrl];
        [_avatarImgv sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:DefaultImageName_Avatar] completed:nil];
    }
    
    if (!STRINGHASVALUE(loginManager.nickName)) {
        _nicknameLabel.text = @"未设置昵称";
    }else {
        _nicknameLabel.text = loginManager.nickName;
    }
    
    if (!STRINGHASVALUE(loginManager.cellPhone)) {
        _bindPhoneLabel.text = @"尚未绑定手机号";
    }
    else
        _bindPhoneLabel.text = loginManager.cellPhone;
}


@end
