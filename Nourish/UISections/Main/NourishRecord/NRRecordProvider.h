//
//  NRRecordProvider.h
//  Nourish
//
//  Created by tcguo on 15/11/20.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRUserInfoModel.h"
#import "NRRecordDayInfo.h"
#import "NRRecordArticleInfo.h"

typedef void(^CompleteBlock)(id reslut, NSError *error);

@interface NRRecordProvider : NSObject

- (void)requestDailyRecordWithDate:(NSDate *)date completeBlock:(CompleteBlock)completeBlock;

@end


@interface NRRecordInfo : NSObject

@property (nonatomic, assign) BOOL isVisitor;
@property (nonatomic, assign) BOOL isNewUser;
@property (nonatomic, assign) BOOL isOrderDate;

@property (strong, nonatomic) NRUserInfoModel *userMod;
@property (strong, nonatomic) NRRecordDayInfo *dayMod;
@property (strong, nonatomic) NSMutableArray *articles;
@property (strong, nonatomic) NSMutableArray *dinnerDetails;


@end