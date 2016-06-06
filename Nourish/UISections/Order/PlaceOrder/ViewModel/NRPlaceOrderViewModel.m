//
//  NRPlaceOrderViewModel.m
//  Nourish
//
//  Created by tcguo on 15/12/11.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRPlaceOrderViewModel.h"
#import "NRDistributionAddrModel.h"

@interface NRPlaceOrderViewModel ()

@property (nonatomic, copy, readwrite) NSString *orderId;
@property (nonatomic, copy, readwrite) NSString *totalFee;

@property (nonatomic, weak) NSURLSessionDataTask *readyTask;
@property (nonatomic, weak) RACDisposable *submitDispose;

@end

@implementation NRPlaceOrderViewModel

- (void)fetchReadyInfoWithSMWIds:(NSArray *)smwIds completeBlock:(MyCompletionBlock)completeBlock {
    if (self.readyTask) {
        [self.readyTask cancel];
    }
    
    __weak typeof(self) weakSelf = self;
    NSDictionary *params = @{ @"smwIds": smwIds };
    
    self.readyTask = [[NRNetworkClient sharedClient] sendPost:@"order/ready2place" parameters:params success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        if (errorCode == 0) {
            NSNumber *couponCount = [res valueForKey:@"couponCount"];
            weakSelf.couponCount = [couponCount unsignedIntegerValue];
            NSDictionary *address = [res valueForKey:@"address"];
            
            if (DICTIONARYHASVALUE(address)) {
                NSInteger addrID = [[address valueForKey:@"id"] integerValue];
                NSString *name = [address valueForKey:@"name"];
                NSString *phone = [address valueForKey:@"phone"];
                NSString *poiName = [address valueForKey:@"poiName"];
                NSString *poiAddress = [address valueForKey:@"poiAddress"];
                NSNumber *distance = [address valueForKey:@"distance"];
                BOOL reachable = [[address valueForKey:@"reachable"] boolValue];//是否可配送
                NSString *detail = [address valueForKey:@"detail"];
                
                weakSelf.availableAddrModel = [[NRDistributionAddrModel alloc] init];
                weakSelf.availableAddrModel.addressID = addrID;
                weakSelf.availableAddrModel.name = name;
                weakSelf.availableAddrModel.phone = phone;
                weakSelf.availableAddrModel.poiName = poiName;
                weakSelf.availableAddrModel.poiAddress = poiAddress;
                weakSelf.availableAddrModel.detailAddress = detail;
                weakSelf.availableAddrModel.reachable = reachable;
                weakSelf.availableAddrModel.distance = [distance floatValue];
                NSNumber *numLong = [address valueForKey:@"x"];
                NSNumber *numLati = [address valueForKey:@"y"];
                weakSelf.availableAddrModel.longitude = [numLong floatValue];
                weakSelf.availableAddrModel.latitude = [numLati floatValue];
            }
            else {
                weakSelf.availableAddrModel = nil;
            }
            
            if (completeBlock) {
                completeBlock(self, nil);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
    
}

- (RACSignal *)submitOrderWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (self.submitDispose) {
            [self.submitDispose dispose];
        }
        
        self.submitDispose = [[self.networkClient rac_sendPost:@"order/place" parameters:parametres] subscribeNext:^(id res) {
            self.orderId = [res valueForKey:@"orderId"];
            self.totalFee = [res valueForKey: @"realPrice"];
            [subscriber sendNext:self];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.submitDispose;
    }];
}
@end
