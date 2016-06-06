//
//  NROrderWeekPlanCell.m
//  Nourish
//
//  Created by gtc on 15/3/2.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderWeekPlanCell.h"
#import "NRLoginManager.h"

@interface NROrderWeekPlanCell ()

@property (readwrite, nonatomic) UIImageView *wptImageView;
@property (strong, nonatomic) UILabel *wptNameLabel;

@end

@implementation NROrderWeekPlanCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.wptImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_wptImageView];
        self.wptImageView.contentMode = UIViewContentModeScaleToFill;
        [self.wptImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(4);
            make.bottom.equalTo(-4);
            make.left.equalTo(10);
            make.width.equalTo(@123);
        }];
        
//        [self.contentView addSubview:self.wptNameLabel];
//        [self.wptNameLabel makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.contentView.right);
//            make.centerY.equalTo(self.mas_centerY);
//        }];
        
    }
    
    return self;
}

- (UILabel *)wptNameLabel {
    if (_wptNameLabel == nil) {
        _wptNameLabel = [[UILabel alloc] init];
        _wptNameLabel.numberOfLines = 0;
        _wptNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _wptNameLabel;
}

- (void)setWptName:(NSString *)wptName {
    NRLoginManager *userInfo = [NRLoginManager sharedInstance];
    NSString *nickname = userInfo.nickName;
    
    NSString *strVal = [NSString stringWithFormat:@"%@\nfor\n%@", wptName, nickname];
    
    NSMutableAttributedString *_mattrstrE = [[NSMutableAttributedString alloc] initWithString:strVal];
    [_mattrstrE addAttribute:NSForegroundColorAttributeName value:RgbHex2UIColor(0xea, 0xae, 0x2f) range:NSMakeRange(0, wptName.length)];
    [_mattrstrE addAttribute:NSForegroundColorAttributeName value:RgbHex2UIColor(0xe5, 0x1b, 0x17) range:NSMakeRange(wptName.length, 5)];
     [_mattrstrE addAttribute:NSForegroundColorAttributeName value:RgbHex2UIColor(0xb9, 0xb9, 0xb9) range:NSMakeRange(wptName.length +5, nickname.length)];

    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.detailTextLabel.attributedText = _mattrstrE;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
