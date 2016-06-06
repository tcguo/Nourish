//
//  NRWeekPlanPost.m
//  Nourish
//
//  Created by gtc on 15/1/14.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanPost.h"
#import "NRNetworkClient.h"
#import "Config.h"

@implementation NRWeekPlanPost

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        self.weekplanModel = [[NRWeekPlanModel alloc] initWithAttributes:attributes];
    }
    return self;
}

+ (NSURLSessionDataTask *)getWeekPlanDataWithBlock:(void (^)(NSArray *posts, NSError *error))block {
    NSURLSessionDataTask *task = nil;
    task = [[NRNetworkClient sharedClient] sendPost:@"wpt/list" parameters:nil success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        NSError *myerror = nil;
        NSMutableArray *marrPosts = nil;
        NSArray *arrWeekPlans = [res valueForKey:@"wpts"];
        marrPosts = [NSMutableArray arrayWithCapacity:[arrWeekPlans count]];
        
        for (NSDictionary *dic in arrWeekPlans) {
            NRWeekPlanPost *post = [[NRWeekPlanPost alloc] initWithAttributes:dic];
            [marrPosts addObject:post];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(marrPosts, myerror);
            }
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(nil, error);
            }
        });
    }];
    
    return task;
}

@end
