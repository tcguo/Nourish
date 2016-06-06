//
//  NRWeekPlanListViewModel.h
//  Nourish
//
//  Created by tcguo on 16/4/1.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"
#import "NRWeekPlanListItemModel.h"

@interface NRWeekPlanListViewModel : NRBaseViewModel
@property (nonatomic, assign, readonly) BOOL hasMore;
@property (nonatomic, copy, readonly) NSString *changeKey;
@property (nonatomic, strong, readonly) NSMutableArray<NRWeekPlanListItemModel *> *dataArray;
@property (nonatomic, strong, readonly) NRWeekPlanListItemModel *currentMod;

- (id)initWithWptId:(NSUInteger)weekplanId;
- (RACSignal *)getWeekplanlistWithParametres:(NSDictionary *)parametres;
- (RACSignal *)getCollectWeekplanlistWithParametres:(NSDictionary *)parametres;
- (RACSignal *)changeWeekplanWithParametres:(NSDictionary *)parametres;
- (RACSignal *)collectWeekplanWithParametres:(NSDictionary *)parametres;
- (RACSignal *)cancelCollectWeekplanWithParametres:(NSDictionary *)parametres;

@end
