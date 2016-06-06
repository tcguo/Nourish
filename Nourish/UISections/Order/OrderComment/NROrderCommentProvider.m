//
//  NROrderCommentProvider.m
//  Nourish
//
//  Created by tcguo on 15/11/10.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderCommentProvider.h"
#import "NROrderCommentCell.h"
#import "NRWeekPlanCommentListCell.h"

@interface NROrderCommentProvider ()

@property (nonatomic, weak) NSURLSessionDataTask *requestTask;
@property (nonatomic, weak) NSURLSessionDataTask *submitTask;
@property (nonatomic, weak) NSURLSessionDataTask *submitWeekplanTask;
@property (nonatomic, weak) NSURLSessionDataTask *requestWeekplanTask;

@property (nonatomic, assign, readwrite) BOOL hasZaoMeal;
@property (nonatomic, assign, readwrite) BOOL hasChaMeal;

@end

@implementation NROrderCommentProvider

- (void)requestOrderCommentWithDate:(NSString *)date orderId:(NSString *)orderId completeBlock:(CompleteBlock)completeBlock{
    
    if (self.requestTask) {
        [self.requestTask cancel];
    }
    
    NSDictionary *data = @{ @"orderId": orderId,
                            @"date": date };
    
    __weak typeof(self) weakself = self;
    self.requestTask = [[NRNetworkClient sharedClient] sendPost:@"setmeal/comment/page" parameters:data success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        NSError *error = nil;
        NSMutableArray *dataArr = [NSMutableArray array];
        
        if (errorCode == 0) {
            NSNumber *numForCommented = [res valueForKey:@"commented"];
            weakself.isCommented = [numForCommented boolValue];
            
            NSArray *arr = [res valueForKey:@"comments"];
            for (NSDictionary *dic in arr) {
                NROrderCommentInfo *comment = [[NROrderCommentInfo alloc] init];
                NSNumber *setmealId = [dic valueForKey:@"setmealId"];
                comment.setmealId = [setmealId integerValue];
                NSNumber *type = [dic valueForKey:@"mealType"];
                comment.dinnerType = [type integerValue];
                
                NSArray *foods = [dic valueForKey:@"names"];
                comment.foods = [foods componentsJoinedByString:@"+"];
                comment.setmealImage = [dic valueForKey:@"imageUrl"];
                comment.comment = [dic valueForKey:@"content"];
                NSNumber *star = [dic valueForKey:@"star"];
                comment.starValue = [star integerValue];
                
                [dataArr addObject:comment];
                
                //test data
//                NROrderCommentInfo *commentZao = [[NROrderCommentInfo alloc] init];
//                NSNumber *zaosetmealId = [dic valueForKey:@"setmealId"];
//                commentZao.setmealId = [zaosetmealId integerValue];
//                commentZao.dinnerType = DinnerPriceZao;
//                
//                NSArray *zaofoods = [dic valueForKey:@"names"];
//                commentZao.foods = [zaofoods componentsJoinedByString:@"+"];
//                commentZao.setmealImage = [dic valueForKey:@"imageUrl"];
//                commentZao.comment = [dic valueForKey:@"content"];
//                NSNumber *starzao = [dic valueForKey:@"star"];
//                commentZao.starValue = [starzao integerValue];
//                
//                [dataArr addObject:commentZao];
//                
//                NROrderCommentInfo *commentCha = [[NROrderCommentInfo alloc] init];
//                NSNumber *chasetmealId = [dic valueForKey:@"setmealId"];
//                commentCha.setmealId = [chasetmealId integerValue];
//                commentCha.dinnerType = DinnerPriceZao;
//                
//                NSArray *chafoods = [dic valueForKey:@"names"];
//                commentCha.foods = [chafoods componentsJoinedByString:@"+"];
//                commentCha.setmealImage = [dic valueForKey:@"imageUrl"];
//                commentCha.comment = [dic valueForKey:@"content"];
//                NSNumber *starcha = [dic valueForKey:@"star"];
//                commentCha.starValue = [starcha integerValue];
//                [dataArr addObject:commentCha];
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(dataArr, error);
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil, error);
        });
    }];
}

- (void)submitCommentWithUserInfo:(NSDictionary *)userInfo completeBlock:(CompleteBlock)completeBlock {
    
    if (self.submitTask ) {
        [self.submitTask cancel];
    }
    
    self.submitTask = [[NRNetworkClient sharedClient] sendPost:@"setmeal/comment/add" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        NSError *error = nil;
        if (errorCode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(nil, error);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil, error);
        });
    }];
}

- (void)submitWeekplanCommentWithUserInfo:(NSDictionary *)userInfo completeBlock:(CompleteBlock)completeBlock {
    if (self.submitWeekplanTask ) {
        [self.submitWeekplanTask cancel];
    }
    
    self.submitWeekplanTask = [[NRNetworkClient sharedClient] sendPost:@"weekplan/comment/add" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        // 周计划评论成功
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(res, nil);
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil, error);
        });
    }];
}


- (void)requestWeekplanCommentLisWithUserInfo:(NSDictionary *)userInfo completeBlock:(CompleteBlock)completeBlock {
    if (self.requestWeekplanTask) {
        [self.requestWeekplanTask cancel];
    }
    __weak typeof(self) weakself = self;
    self.requestWeekplanTask = [[NRNetworkClient sharedClient] sendPost:@"weekplan/comment/list" parameters:userInfo success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        NSError *error = nil;
        NSMutableArray *dataArr = nil;
        
        NSNumber *pageIndex = [res valueForKey:@"nextPageIndex"];
        weakself.wpCommentPageIndex = [pageIndex integerValue];
        NSArray *comments = [res valueForKey:@"comments"];
        
        if (ARRAYHASVALUE(comments)) {
            dataArr = [NSMutableArray array];
            for (NSDictionary *item in comments) {
                NRWeekPlanCommentListModel *model = [[NRWeekPlanCommentListModel alloc] init];
                model.avatarUrl = [item valueForKey:@"userAvatarUrl"];
                model.nickName = [item valueForKey:@"nickname"];
                model.comment = [item valueForKey:@"content"];
//                    model.comment = @"周计划吃的相当不错，周计划吃的相当完美，好好好好吃吃好好好好吃吃好好好好吃吃好好好好吃吃好好好好吃吃好好好好吃吃好好好好吃吃好好好好吃吃好好好好吃吃好好好好吃吃松松送送送";
                model.dateTime = [item valueForKey:@"date"];
                NSNumber *weekth = [item valueForKey:@"weekCount"];
                NSString *price = [item valueForKey:@"dailyPrice"];
                model.price = [NSNumber numberWithInteger:[price integerValue]];
                model.weekth = [NSString stringWithFormat:@"%ld", (long)[weekth integerValue]];
                [dataArr addObject:model];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(dataArr, error);
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil, error);
        });
    }];
    
    
}
@end
