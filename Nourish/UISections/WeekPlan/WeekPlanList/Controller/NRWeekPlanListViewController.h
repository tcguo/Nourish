//
//  NRWeekPlanListViewController.h
//  Nourish
//
//  Created by gtc on 15/1/22.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"

@interface NRWeekPlanListViewController : NRBaseViewController<UIScrollViewDelegate>

@property (nonatomic, assign) NSUInteger weekplanID;//周计划类型ID
@property (nonatomic, strong) NSArray *arrMealtypes;
@property (nonatomic, assign) NSUInteger pricePerDay;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *locationx; //经度
@property (nonatomic, copy) NSString *locationy; //维度
@property (strong, nonatomic) NSMutableArray *marrWPList;

- (id)initWithFromCollect:(BOOL)isFromCollect;
- (void)getWeekplanlist;
- (void)getWeekplanlistWithSmwIds:(NSArray *)smwIds; //从收藏进入的

@end
