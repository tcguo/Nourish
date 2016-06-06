//
//  NRSetmealDetailCell.m
//  Nourish
//
//  Created by gtc on 15/1/29.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSetmealDetailCell.h"

#define FontColorForDayCell RgbHex2UIColor(0x50, 0x50, 0x50)

@interface NRSetmealDetailCell ()

@property (nonatomic, strong) UIImageView *actorImgView;

@end

@implementation NRSetmealDetailCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.lblName = [[UILabel alloc] init];
    [self.contentView addSubview:_lblName];
    self.lblName.textColor = FontColorForDayCell;
    self.lblName.font = NRFont(15);
    [self.lblName makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    self.lblText = [[UILabel alloc] init];
    [self.contentView addSubview:_lblText];
    self.lblText.textColor = FontColorForDayCell;
    self.lblText.font = NRFont(15);
    [self.lblText makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.centerX);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(20);
    }];
    
    self.actorImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record-biaoji"]];
    self.actorImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.actorImgView];
    [self.actorImgView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
        make.width.equalTo(@18);
        make.height.equalTo(@18);
    }];
    
    [self.actorImgView setHidden:YES];
    
    return self;
}

- (void)setIsLeadActor:(BOOL)isLeadActor
{
    _isLeadActor = isLeadActor;
    if (isLeadActor) {
        [self.actorImgView setHidden:NO];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
