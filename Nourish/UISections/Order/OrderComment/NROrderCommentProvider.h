//
//  NROrderCommentProvider.h
//  Nourish
//
//  Created by tcguo on 15/11/10.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteBlock)(id reslut, NSError *error);

@interface NROrderCommentProvider : NSObject
@property (nonatomic, assign) BOOL isCommented;
@property (nonatomic, assign) NSInteger wpCommentPageIndex;

- (void)requestOrderCommentWithDate:(NSString *)date orderId:(NSString *)orderId completeBlock:(CompleteBlock)completeBlock;
- (void)submitCommentWithUserInfo:(NSDictionary *)userInfo completeBlock:(CompleteBlock)completeBlock;

- (void)submitWeekplanCommentWithUserInfo:(NSDictionary *)userInfo completeBlock:(CompleteBlock)completeBlock;
- (void)requestWeekplanCommentLisWithUserInfo:(NSDictionary *)userInfo completeBlock:(CompleteBlock)completeBlock;

@end
