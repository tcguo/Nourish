//
//  NRWeekPlanListItemModel.h
//  Nourish
//
//  Created by gtc on 15/1/22.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ListItemType) {
    ListItemTypeIntrodution,
    ListItemTypeImage,
    ListItemTypeDetail,
};

typedef NS_ENUM(NSUInteger, MealType) {
    MealTypeZao = 1,
    MealTypeWu = 2,
    MealTypeCha = 3,
};



@interface NRWeekPlanListItemModel : NSObject

//此周计划包涵的单餐周计划ID数组[1,2,3]
@property (assign, nonatomic) NSUInteger wptId; //周计划类型
@property (strong, nonatomic) NSArray *arrWPSID; //单餐周计划ids
@property (copy, nonatomic) NSString *introdution; //周计划介绍
@property (assign, nonatomic) ListItemType itemType; // model类型
@property (assign, nonatomic) NSUInteger setmeal_id ;
@property (assign, nonatomic) MealType mealtype;
@property (assign, nonatomic) WeekDay weekday;

@property (copy, nonatomic) NSString *theme;//主题日名称
@property (copy, nonatomic) NSString *imageurl;//套餐主图片
@property (copy, nonatomic) NSString *theWeekPlanName;//所属周计划名称
@property (copy, nonatomic) NSString *theWeekPlanImageUrl;//所属周计划封面
@property (copy, nonatomic) NSString *setmealName; // 套餐名称
@property (copy, nonatomic) NSArray *singleFoods; // 单品名称
@property (assign, nonatomic) NSUInteger commentCount; // 总评论条数
@property (assign, nonatomic) BOOL hasCollected; //是否已收藏
@property (assign, nonatomic) NSInteger collectId; // 收藏 id

@end

@interface NRComment : NSObject

@property (assign, nonatomic) NSUInteger userid;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *avatarsurl;
@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSString *datetime;

@end
