//
//  NRWeekPlanCommentCell.h
//  Nourish
//
//  Created by gtc on 15/1/23.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRWeekPlanListItemModel.h"

@interface NRWeekPlanCommentCell : UITableViewCell

@property (nonatomic, strong) NRComment *commentMod;

- (void)setCommentMod:(NRComment *)commentMod;

@end
