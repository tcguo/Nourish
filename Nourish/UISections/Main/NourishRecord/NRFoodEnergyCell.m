//
//  NRFoodEnergyCell.m
//  Nourish
//
//  Created by gtc on 15/6/4.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRFoodEnergyCell.h"

CGFloat const kValueFontSize = 12;

@interface NRFoodEnergyCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic,assign) CGSize cellSize;
@property (nonatomic,assign) CGFloat footerHeight;

@end

@implementation NRFoodEnergyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.nameLabel = [UILabel new];
        [self.contentView addSubview:self.nameLabel];
       
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = SysFont(14);
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.shadowColor = [UIColor blackColor];
        self.nameLabel.shadowOffset = CGSizeMake(0,1);
        
        self.reliangLabel = [UILabel new];
        [self.contentView addSubview:self.reliangLabel];
       
        self.reliangLabel.textColor = [UIColor whiteColor];
        self.reliangLabel.backgroundColor = [UIColor clearColor];
        self.reliangLabel.font = SysFont(kValueFontSize);
        self.reliangLabel.textAlignment = NSTextAlignmentCenter;
        self.reliangLabel.shadowColor = [UIColor blackColor];
        self.reliangLabel.shadowOffset = CGSizeMake(0,1);
        
        self.zhifangLabel = [UILabel new];
        [self.contentView addSubview:self.zhifangLabel];
       
        self.zhifangLabel.textColor = [UIColor whiteColor];
        self.zhifangLabel.backgroundColor = [UIColor clearColor];
        self.zhifangLabel.font = SysFont(kValueFontSize);
        self.zhifangLabel.textAlignment = NSTextAlignmentCenter;
        self.zhifangLabel.shadowColor = [UIColor blackColor];
        self.zhifangLabel.shadowOffset = CGSizeMake(0,1);
        
        self.danbaizhiLabel = [UILabel new];
        [self.contentView addSubview:self.danbaizhiLabel];
       
        self.danbaizhiLabel.textColor = [UIColor whiteColor];
        self.danbaizhiLabel.backgroundColor = [UIColor clearColor];
        self.danbaizhiLabel.font = SysFont(kValueFontSize);
        self.danbaizhiLabel.textAlignment = NSTextAlignmentCenter;
        self.danbaizhiLabel.shadowColor = [UIColor blackColor];
        self.danbaizhiLabel.shadowOffset = CGSizeMake(0,1);
        
        self.huahewuLabel = [UILabel new];
        [self.contentView addSubview:self.huahewuLabel];
       
        self.huahewuLabel.textColor = [UIColor whiteColor];
        self.huahewuLabel.backgroundColor = [UIColor clearColor];
        self.huahewuLabel.font = SysFont(kValueFontSize);
        self.huahewuLabel.textAlignment = NSTextAlignmentCenter;
        self.huahewuLabel.shadowColor = [UIColor blackColor];
        self.huahewuLabel.shadowOffset = CGSizeMake(0,1);
        
        self.xianweisuLabel = [UILabel new];
        [self.contentView addSubview:self.xianweisuLabel];
      
        self.xianweisuLabel.textColor = [UIColor whiteColor];
        self.xianweisuLabel.backgroundColor = [UIColor clearColor];
        self.xianweisuLabel.font = SysFont(kValueFontSize);
        self.xianweisuLabel.textAlignment = NSTextAlignmentCenter;
        self.xianweisuLabel.shadowColor = [UIColor blackColor];
        self.xianweisuLabel.shadowOffset = CGSizeMake(0,1);
    }
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.nameLabel.frame = CGRectMake(0, 10, self.bounds.size.width, 14);
    CGFloat yRe = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + 8;
    self.reliangLabel.frame = CGRectMake(0, yRe,  self.bounds.size.width, kValueFontSize+2);
    
    CGFloat yZHI = self.reliangLabel.frame.origin.y + self.reliangLabel.frame.size.height + 8;
    self.zhifangLabel.frame = CGRectMake(0, yZHI, self.bounds.size.width, kValueFontSize+2);
    
    CGFloat yDAN = self.zhifangLabel.frame.origin.y + self.zhifangLabel.frame.size.height + 8;
    self.danbaizhiLabel.frame = CGRectMake(0, yDAN, self.bounds.size.width, kValueFontSize+2);
    
    CGFloat yHUA = self.danbaizhiLabel.frame.origin.y + self.danbaizhiLabel.frame.size.height + 8;
    self.huahewuLabel.frame = CGRectMake(0, yHUA, self.bounds.size.width, kValueFontSize+2);
    
    CGFloat yXIAN = self.huahewuLabel.frame.origin.y + self.huahewuLabel.frame.size.height + 8;
    self.xianweisuLabel.frame = CGRectMake(0, yXIAN, self.bounds.size.width, kValueFontSize+2);
   
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
