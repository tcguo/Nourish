//
//  NRAccountUploadAvatarCell.m
//  Nourish
//
//  Created by tcguo on 15/10/31.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAccountUploadAvatarCell.h"
#import "UIImageView+WebCache.h"

@interface NRAccountUploadAvatarCell ()
{
    UIImage *_preImage;
}

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *titleLable;

@end

@implementation NRAccountUploadAvatarCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupControls];
    }
    
    return self;
}

- (void)setupControls {
    UILabel *lbl = [[UILabel alloc] init];
    [self.contentView addSubview:lbl];
    self.titleLable = lbl;
    _titleLable.font = NRFont(FontLabelSize);
    [self.titleLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.centerY);
        make.leading.equalTo(16);
        make.height.equalTo(FontLabelSize);
    }];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    [self.contentView addSubview:imgView];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.avatarImageView = imgView;
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.layer.cornerRadius = 36/2;
    
    [self.avatarImageView makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.right).offset(0);
        make.centerY.equalTo(self.contentView.centerY);
        make.width.and.height.equalTo(@36);
    }];
}

- (void)updateUserAvatarWith:(NRLoginManager *)userInfo {
    
    self.titleLable.text = @"上传或更改头像";
    if (_preImage == nil) {
        _preImage = [UIImage imageNamed:DefaultImageName_Avatar];
    }
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:_preImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _preImage = image;
    }];
}

@end
