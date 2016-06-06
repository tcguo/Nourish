//
//  NRRecordDetailModel.h
//  Nourish
//
//  Created by gtc on 15/2/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NRRecordDetailModel : NSObject

@property (copy, nonatomic) NSString *distributionTime; // 配送时间
@property (copy, nonatomic) NSString *setmealImageUrl;  // 套餐图片
@property (assign, nonatomic) DinnerType dinnerType;
@property (retain, nonatomic) NSMutableArray *marrSingleFoodNames;
@property (copy, nonatomic) NSString *warmTips;
@property (retain, nonatomic) NSMutableArray *marrEnergyList; // 里面放单餐对应的所有能量-value:NREnergyElementModel

@property (assign, nonatomic) BOOL isLoad; //是否已加载
@property (nonatomic, assign) BOOL isExpanded;
@property (strong, nonatomic) UIImage *bigImage;
@property (strong, nonatomic) UIImage *smallImage;

@end
