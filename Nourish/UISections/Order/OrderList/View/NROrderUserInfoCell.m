//
//  NROrderUserInfoCell.m
//  Nourish
//
//  Created by gtc on 15/3/2.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderUserInfoCell.h"

CGFloat const kFontSize = 16;

@implementation NROrderUserInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
        self.nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLabel];
        [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(10);
            make.top.equalTo(10);
        }];
        
        self.phoneLabel = [[UILabel alloc] init];
        self.phoneLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
        self.phoneLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_phoneLabel];
        [self.phoneLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.right);
            make.top.equalTo(10);
        }];
        
        self.addressLabel = [[UILabel alloc] init];
        self.addressLabel.font = NRFont(12);
        self.addressLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_addressLabel];
        [self.addressLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(10);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-12);
        }];
    }
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
