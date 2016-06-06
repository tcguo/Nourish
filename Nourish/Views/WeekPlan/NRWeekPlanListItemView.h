//
//  NRWeekPlanListItemView.h
//  Nourish
//
//  Created by gtc on 15/1/22.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseView.h"
#import "NRWeekPlanListItemModel.h"
#import <Foundation/Foundation.h>

@protocol WeekPlanListDelegate <NSObject>

@optional
- (void)showSetMealDetail;
- (void)hideSetMealDetail;

- (void)getSetmealDetail;
- (void)setBgImage:(UIImage *)image;

@end

@interface NRWeekPlanListItemView : NRBaseView

@property (weak, nonatomic) id<WeekPlanListDelegate> weekplanlistDelegate;

@property (strong, nonatomic) NRWeekPlanListItemModel *model;
@property (assign, nonatomic) ListItemType listItemType;


- (id)initWithFrame:(CGRect)frame type:(ListItemType)itemtype mod:(NRWeekPlanListItemModel *)mod;
- (void)loadImage;

@end
