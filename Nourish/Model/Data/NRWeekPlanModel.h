//
//  NRWeekPlanModel.h
//  Nourish
//
//  Created by gtc on 15/1/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>


//static const CGFloat floatVal = 0.3;//常量

@interface NRWeekPlanModel : NSObject

@property (readonly, nonatomic, strong) NSURL *imageUrl;
@property (readonly, nonatomic, assign) NSUInteger weekplanID;
@property (readonly, nonatomic, assign) NSUInteger price;
@property (readonly, nonatomic, copy) NSString *weekplanName;
@property (readonly, nonatomic, copy) NSString *descZH;
@property (readonly, nonatomic, copy) NSString *descEN;

/**
 *  初始化
 *
 *  @param attributes 属性字典值
 *
 *  @return 实例
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
