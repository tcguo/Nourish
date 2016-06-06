//
//  NRWeekPlanCell.h
//  Nourish
//
//  Created by gtc on 15/1/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRTableViewBaseCell.h"

@class NRWeekPlanPost;

@interface NRWeekPlanCell : NRTableViewBaseCell

@property (nonatomic, strong) NRWeekPlanPost *post;
@property (nonatomic, readonly, strong) UIImageView *weekPlanImageView;
@property (nonatomic, readonly, strong) UIView *maskBg;
@property (nonatomic, readonly, strong) UILabel *lblName;
@property (nonatomic, readonly, strong) UILabel *lblPrice;
@property (nonatomic, readonly, strong) UILabel *lblDescZH;
@property (nonatomic, readonly, strong) UILabel *lblDescEN;

@end
