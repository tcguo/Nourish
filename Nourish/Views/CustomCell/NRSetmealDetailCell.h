//
//  NRSetmealDetailCell.h
//  Nourish
//
//  Created by gtc on 15/1/29.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRSetmealDetailCell : UITableViewCell

@property (strong, nonatomic) UILabel *lblName;
@property (strong, nonatomic) UILabel *lblText;

//今日主角
@property (assign, nonatomic) BOOL isLeadActor;
@end
