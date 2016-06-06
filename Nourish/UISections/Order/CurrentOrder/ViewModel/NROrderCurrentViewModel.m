//
//  NROrderCurrentViewModel.m
//  Nourish
//
//  Created by tcguo on 16/3/23.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderCurrentViewModel.h"

@interface NROrderCurrentViewModel ()

@property (nonatomic, weak) RACDisposable *refreshStatusDispose;

@end

@implementation NROrderCurrentViewModel

- (RACSignal *)fetchOrderWithDates:(NSArray *)dates {
    __weak typeof(self) weakself = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *params = @{ @"dates": dates};
        return [[weakself.networkClient rac_sendPost:@"order/current" parameters:params] subscribeNext:^(NSDictionary *resObj) {
            NSError *error = nil;
            NROrderCurrentJSONModel *model = [[NROrderCurrentJSONModel alloc]
                                             initWithDictionary:resObj error:&error];
            if (error == nil) {
               [subscriber sendNext:model];
            }
            else {
               [subscriber sendError:error];
            }
       } error:^(NSError *error) {
           [subscriber sendError:error];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
    }];
}

- (RACSignal *)fetchCurrentOrder {
    __weak typeof(self) weakself = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return [[weakself.networkClient rac_sendPost:@"order/current" parameters:nil] subscribeNext:^(NSDictionary *resObj) {
            NSError *error = nil;
            NROrderCurrentJSONModel *model = [[NROrderCurrentJSONModel alloc]
                                              initWithDictionary:resObj error:&error];
            if (error == nil) {
                [subscriber sendNext:model];
            }
            else {
                [subscriber sendError:error];
            }
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
    }];
}

- (RACSignal *)refreshDispatchStatusWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.refreshStatusDispose) {
            [self.refreshStatusDispose dispose];
        }
        self.refreshStatusDispose = [[self.networkClient rac_sendPost:@"order/dispatch-status" parameters:parametres] subscribeNext:^(id x) {
            NSString *dispatchStatus = [x valueForKey:@"dispatchStatus"];
            [subscriber sendNext:dispatchStatus];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.refreshStatusDispose;
    }];
}

@end
