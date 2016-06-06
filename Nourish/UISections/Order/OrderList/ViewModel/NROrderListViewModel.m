//
//  NROrderListViewModel.m
//  Nourish
//
//  Created by tcguo on 16/4/5.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderListViewModel.h"
#import "NROrderInfoModel.h"

@interface NROrderListViewModel ()
@property (nonatomic, assign, readwrite) NSInteger orderListNextPageIndex;

@property (nonatomic, weak) RACDisposable *refundDispose;
@property (nonatomic, weak) RACDisposable *cancelRefundDispose;
@property (nonatomic, weak) RACDisposable *cancelChangeDispose;
@property (nonatomic, weak) RACDisposable *changeDispose;
@property (nonatomic, weak) RACDisposable *workDaysDispose;
@property (nonatomic, weak) RACDisposable *cancelOrderDispose;
@property (nonatomic, weak) RACDisposable *loadOrderListDispose;
@end

@implementation NROrderListViewModel

- (RACSignal *)cancelRefundWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.cancelRefundDispose) {
            [self.cancelRefundDispose dispose];
        }
        
        self.cancelRefundDispose = [[self.networkClient rac_sendPost:@"order/refund/cancel" parameters:parametres] subscribeNext:^(id res) {
            NSNumber *statusCode = [res valueForKey:@"statusCode"];
            NSString *statusDesc = [res valueForKey:@"statusDesc"];
            NSString *orderId = [res valueForKey:@"orderId"];
            NROrderInfoModel *resultMod = [[NROrderInfoModel alloc] init];
            resultMod.orderStatusDesc = statusDesc;
            resultMod.orderID = orderId;
            resultMod.orderstatus = [statusCode integerValue];
            
            [subscriber sendNext:resultMod];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.cancelRefundDispose;
    }];
}

- (RACSignal *)refundWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.refundDispose) {
            [self.refundDispose dispose];
        }
        
        self.refundDispose = [[self.networkClient rac_sendPost:@"order/refund/apply" parameters:parametres] subscribeNext:^(id res) {
            NSNumber *statusCode = [res valueForKey:@"statusCode"];
            NSString *statusDesc = [res valueForKey:@"statusDesc"];
            NSString *orderId = [res valueForKey:@"orderId"];
            NROrderInfoModel *resultMod = [[NROrderInfoModel alloc] init];
            resultMod.orderStatusDesc = statusDesc;
            resultMod.orderID = orderId;
            resultMod.orderstatus = [statusCode integerValue];
            
            [subscriber sendNext:resultMod];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.refundDispose;
    }];
}

- (RACSignal *)changeOrderWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.changeDispose) {
            [self.changeDispose dispose];
        }
        
        self.changeDispose = [[self.networkClient rac_sendPost:@"order/change/date/apply" parameters:parametres] subscribeNext:^(id res) {
            NSNumber *statusCode = [res valueForKey:@"statusCode"];
            NSString *statusDesc = [res valueForKey:@"statusDesc"];
            NROrderInfoModel *resultMod = [[NROrderInfoModel alloc] init];
            resultMod.orderstatus = [statusCode integerValue];
            resultMod.orderID = [res valueForKey:@"orderId"];
            resultMod.orderStatusDesc = statusDesc;
            resultMod.startDate = [res valueForKey:@"startDate"];
            resultMod.endDate = [res valueForKey:@"endDate"];
            NSString *dates = [res valueForKey:@"dates"];
            resultMod.arrDates = [dates componentsSeparatedByString:@","];
            [subscriber sendNext:resultMod];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.changeDispose;
    }];

}

- (RACSignal *)cancelChangeOrderWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.cancelChangeDispose) {
            [self.cancelChangeDispose dispose];
        }
        
        self.cancelChangeDispose = [[self.networkClient rac_sendPost:@"order/change/date/cancel" parameters:parametres] subscribeNext:^(id res) {
            NSNumber *statusCode = [res valueForKey:@"statusCode"];
            NSString *statusDesc = [res valueForKey:@"statusDesc"];
            NSString *orderId = [res valueForKey:@"orderId"];
            NROrderInfoModel *resultMod = [[NROrderInfoModel alloc] init];
            resultMod.orderStatusDesc = statusDesc;
            resultMod.orderID = orderId;
            resultMod.orderstatus = [statusCode integerValue];
            
            [subscriber sendNext:resultMod];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.cancelChangeDispose;
    }];
}

- (RACSignal *)readyToPayWithParametres:(NSDictionary *)parametres {
    return nil;
}

- (RACSignal *)fetchOrderWorkdaysWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.workDaysDispose) {
            [self.workDaysDispose dispose];
        }
        
        self.workDaysDispose = [[self.networkClient rac_sendPost:@"order/util/workdays" parameters:parametres] subscribeNext:^(id res) {
            [subscriber sendNext:res];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.workDaysDispose;
    }];
}

- (RACSignal *)cancelOrderWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.cancelOrderDispose) {
            [self.cancelOrderDispose dispose];
        }
        
        self.cancelOrderDispose = [[self.networkClient rac_sendPost:@"order/unpaid/cancel" parameters:parametres] subscribeNext:^(id res) {
            NSNumber *statusCode = [res valueForKey:@"statusCode"];
            NSString *statusDesc = [res valueForKey:@"statusDesc"];
            NSString *orderId = [res valueForKey:@"orderId"];
            NROrderInfoModel *resultMod = [[NROrderInfoModel alloc] init];
            resultMod.orderStatusDesc = statusDesc;
            resultMod.orderID = orderId;
            resultMod.orderstatus = [statusCode integerValue];
            
            [subscriber sendNext:resultMod];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.cancelOrderDispose;
    }];
}

- (RACSignal *)loadOrderListWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        self.loadOrderListDispose = [[self.networkClient rac_sendPost:@"order/list" parameters:parametres] subscribeNext:^(id res) {
            
            NSNumber *nextPage = [res valueForKey:@"nextPageIndex"];
            self.orderListNextPageIndex = [nextPage integerValue];
            NSMutableArray *rtnObjects = [NSMutableArray array];
            NSArray *arrList = [res valueForKey:@"list"];
            for (NSDictionary *dic in arrList) {
                NSString *orderID = [dic valueForKey:@"orderId"];
                NROrderInfoModel *model = [[NROrderInfoModel alloc] init];
                model.orderID = orderID;
                NSNumber *wptID = [dic valueForKey:@"wptId"];
                model.wptId = [wptID integerValue];
                model.wpName = [dic valueForKey:@"wpName"];
                model.wpThemeImgURL = [dic valueForKey:@"wpThemeImage"];
                model.smwIds = [dic valueForKey:@"smwIds"];
                model.startDate = [dic valueForKey:@"startDate"];
                model.endDate = [dic valueForKey:@"endDate"];
                model.createTime = [dic valueForKey:@"createTime"];
                
                NSNumber *days = [dic valueForKey:@"days"];
                model.days = [days unsignedIntegerValue];
                model.orderStatusDesc = [dic valueForKey:@"statusDesc"];
                NSNumber *status = [dic valueForKey:@"statusCode"];
                model.orderstatus = (OrderStatus)[status integerValue];
                
                model.realPrice = [NSNumber numberWithFloat:[[dic valueForKey:@"realPrice"] floatValue]];
                model.totalPrice = [NSNumber numberWithFloat:[[dic valueForKey:@"totalPrice"] floatValue]];
                NSString *dates = [dic valueForKey:@"dates"];
                model.arrDates = [dates componentsSeparatedByString:@","];
                
                [rtnObjects addObject:model];
            }
            [subscriber sendNext:rtnObjects];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.loadOrderListDispose;
    }];
}
@end
