//
//  NRWeekPlanListViewModel.m
//  Nourish
//
//  Created by tcguo on 16/4/1.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanListViewModel.h"
#import "NRWeekPlanListItemModel.h"

@interface NRWeekPlanListViewModel ()
@property (nonatomic, assign) NSUInteger wptId;
@property (nonatomic, assign, readwrite) BOOL hasMore;
@property (nonatomic, copy, readwrite) NSString *changeKey;
@property (nonatomic, strong, readwrite) NRWeekPlanListItemModel *currentMod;
@property (nonatomic, strong, readwrite) NSMutableArray<NRWeekPlanListItemModel *> *dataArray;

@property (nonatomic, weak) RACDisposable *queryDispose;
@property (nonatomic, weak) RACDisposable *getCollectDispose;
@property (nonatomic, weak) RACDisposable *changeDispose;
@property (nonatomic, weak) RACDisposable *collectDispose;
@property (nonatomic, weak) RACDisposable *cancelCollectDispose;
@end


@implementation NRWeekPlanListViewModel
- (id)initWithWptId:(NSUInteger)weekplanId {
    if (self = [super init]) {
        self.wptId = weekplanId;
    }
    
    return self;
}

- (RACSignal *)getWeekplanlistWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.queryDispose) {
            [self.queryDispose dispose];
        }
        
        self.queryDispose = [[self.networkClient rac_sendPost:@"weekplan/query" parameters:parametres] subscribeNext:^(id res) {
            NSArray *arrWPS = [res valueForKey:@"wps"];
            NSNumber *moreNum =  [res valueForKey:@"more"];
            self.hasMore = [moreNum boolValue];
            self.changeKey = [res valueForKey:@"key"];
            [self buildDataFromResultArray:arrWPS];
            
            [subscriber sendNext:self];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.queryDispose;
    }];
}

- (RACSignal *)getCollectWeekplanlistWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.getCollectDispose) {
            [self.getCollectDispose dispose];
        }
        
        self.getCollectDispose = [[self.networkClient rac_sendPost:@"weekplan/queryBySmwIds" parameters:parametres] subscribeNext:^(id res) {
            NSArray *arrWPS = [res valueForKey:@"wps"];
            self.hasMore = NO;
            self.changeKey = nil;
            [self buildDataFromResultArray:arrWPS];
            
            [subscriber sendNext:self];

        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.getCollectDispose;
    }];
}

- (RACSignal *)changeWeekplanWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        self.changeDispose = [[self.networkClient rac_sendPost:@"weekplan/query/next" parameters:parametres] subscribeNext:^(id res) {
            
            NSNumber *moreNum =  [res valueForKey:@"more"];
            self.hasMore = [moreNum boolValue];
            self.changeKey = [res valueForKey:@"key"];
             NSArray *arrWPS = [res valueForKey:@"wps"];
            [self buildDataFromResultArray:arrWPS];
            [subscriber sendNext:self];

        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.changeDispose;
    }];
}

- (void)buildDataFromResultArray:(NSArray *)resultArr {
    self.dataArray = [NSMutableArray array];
    //只有一组周计划了，数组里也只有一个
    for (id plan in resultArr) {
        
        NSArray *arrSMWIDs = [plan valueForKey:@"smwIds"];//单餐周计划IDs
        NSString *introduction = [plan valueForKey:@"introduction"];
        NSString *weekPlanName = [plan valueForKey:@"name"];//周计划名称
        NSString *weekPlanCover = [plan valueForKey:@"imageUrl"];//周计划封面图
        NSNumber *collectID = [plan valueForKey:@"collectId"]; // 是否已收藏
        NSNumber *wpCommentCount = [plan valueForKey:@"commentCount"];
        
        NRWeekPlanListItemModel *model = [[NRWeekPlanListItemModel alloc] init];
        model.wptId = self.wptId;
        model.arrWPSID = arrSMWIDs;
        model.introdution = introduction;
        model.theWeekPlanName = weekPlanName;
        model.theWeekPlanImageUrl = weekPlanCover;
        model.itemType = ListItemTypeIntrodution;
        model.commentCount = [wpCommentCount unsignedIntegerValue];
        if (collectID && [collectID integerValue] != 0) {
            model.collectId = [collectID integerValue];
            model.hasCollected =  YES;
        }
        
        [self.dataArray addObject:model];
        self.currentMod = model; //默认下单第一个周计划
        
        NSArray *arrSetmeals = [plan valueForKey:@"setmeals"];
        for (id planWithImg in arrSetmeals) {
            
            NRWeekPlanListItemModel *imgMod = [[NRWeekPlanListItemModel alloc] init];
            imgMod.itemType = ListItemTypeImage;
            imgMod.arrWPSID = arrSMWIDs; // 为了便于读取,就是早午茶周计划Ids
            imgMod.setmeal_id = [[planWithImg valueForKey:@"setmealid"] unsignedIntegerValue];
            imgMod.setmealName = [planWithImg valueForKey:@"name"];
            imgMod.singleFoods = [planWithImg valueForKey:@"singleFoods"];
            imgMod.mealtype = [[planWithImg valueForKey:@"mealtype"] intValue];
            imgMod.theme = [planWithImg valueForKey:@"theme"];
            imgMod.weekday = [[planWithImg valueForKey:@"weekday"] intValue];
            imgMod.imageurl = [planWithImg valueForKey:@"imageurl"];
            imgMod.commentCount = [[planWithImg valueForKey:@"commentCount"] unsignedIntegerValue];
            
            [self.dataArray addObject:imgMod];
        }
    }
}


- (RACSignal *)collectWeekplanWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.collectDispose) {
            [self.collectDispose dispose];
        }
        self.collectDispose = [[self.networkClient rac_sendPost:@"weekplan/collection/do" parameters:parametres] subscribeNext:^(id res) {
            NSNumber *collectId = [res valueForKey:@"id"];
            [subscriber sendNext:collectId];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.collectDispose;
    }];
}

- (RACSignal *)cancelCollectWeekplanWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.cancelCollectDispose) {
            [self.cancelCollectDispose dispose];
        }
        self.cancelCollectDispose = [[self.networkClient rac_sendPost:@"weekplan/collection/cancel" parameters:parametres] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendNext:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.cancelCollectDispose;
    }];
}
@end
