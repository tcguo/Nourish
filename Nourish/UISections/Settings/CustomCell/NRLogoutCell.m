//
//  NRLogoutCell.m
//  Nourish
//
//  Created by tcguo on 15/11/21.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRLogoutCell.h"

@implementation NRLogoutCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *logoutLabel = [[UILabel alloc] init];
        [self.contentView addSubview:logoutLabel];
        logoutLabel.font = SysFont(16);
        logoutLabel.textColor = ColorRed_Normal;
        logoutLabel.text = @"退出当前账号";
        [logoutLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.centerX.equalTo(self.contentView);
            make.height.equalTo(16);
        }];
    }
    
    return self;
}

@end
