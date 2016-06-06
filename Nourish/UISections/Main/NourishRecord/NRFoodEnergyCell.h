//
//  NRFoodEnergyCell.h
//  Nourish
//
//  Created by gtc on 15/6/4.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRFoodEnergyCell : UITableViewCell

@property (nonatomic, readonly) UIView *containerView;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *reliangLabel;
@property (nonatomic, strong) UILabel *zhifangLabel;
@property (nonatomic, strong) UILabel *danbaizhiLabel;
@property (nonatomic, strong) UILabel *huahewuLabel;
@property (nonatomic, strong) UILabel *xianweisuLabel;

@end
