//
//  NRAddressViewModel.m
//  Nourish
//
//  Created by tcguo on 16/3/31.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddressViewModel.h"
#import "NRDistributionAddrModel.h"

@interface NRAddressViewModel ()
@property (nonatomic, weak) RACDisposable *upsertDispose;
@property (nonatomic, weak) RACDisposable *queryDispose;
@property (nonatomic, weak) RACDisposable *deleteDispose;
@end

@implementation NRAddressViewModel

- (RACSignal *)upsertWithParameters:(NSDictionary *)params {
    __weak typeof(self) weakself = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (weakself.upsertDispose) {
            [weakself.upsertDispose dispose];
        }
        weakself.upsertDispose = [[self.networkClient rac_sendPost:@"user/address/upsert" parameters:params] subscribeNext:^(id x) {
            [subscriber sendNext:[NSNumber numberWithBool:YES]];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return weakself.upsertDispose;
    }];
}

- (RACSignal *)queryAddressListWithParameters:(NSDictionary *)params{
    __weak typeof(self) weakself = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (weakself.queryDispose) {
            [weakself.queryDispose dispose];
        }
        weakself.queryDispose = [[self.networkClient rac_sendPost:@"user/address/list" parameters:params] subscribeNext:^(id res) {
            
            NSNumber *nextPageIndexNum = [res valueForKey:@"nextPageIndex"];
            weakself.nextPageIndex = [nextPageIndexNum integerValue];
            NSArray *arrAddrs = [res valueForKey:@"addresses"];
            NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[arrAddrs count]];
            
            for (id obj in arrAddrs) {
                NSInteger addrID = [[obj valueForKey:@"id"] integerValue];
                NSString *name = [obj valueForKey:@"name"];
                NSString *phone = [obj valueForKey:@"phone"];
                //GenderType gender = (GenderType)[[obj valueForKey:@"gender"] integerValue];
                NSString *poiName = [obj valueForKey:@"poiName"];
                NSString *poiAddress = [obj valueForKey:@"poiAddress"];
                NSString *poiType = [obj valueForKey:@"poiType"];
                NSNumber *distance = [obj valueForKey:@"distance"];
                BOOL reachable = [[obj valueForKey:@"reachable"] boolValue];//是否可配送
                NSString *detail = [obj valueForKey:@"detail"];
                NSString *adcode = [obj valueForKey:@"adcode"];
                NSNumber *longitude = [obj valueForKey:@"x"];
                NSNumber *latitude = [obj valueForKey:@"y"];
                
                NRDistributionAddrModel *model = [[NRDistributionAddrModel alloc] init];
                model.addressID = addrID;
                model.name = name;
                model.phone = phone;
                model.poiName = poiName;
                model.poiAddress = poiAddress;
                model.poiType = poiType;
                model.detailAddress = detail;
                model.reachable = reachable;
                model.distance = [distance floatValue];
                model.longitude = [longitude floatValue];
                model.latitude = [latitude floatValue];
                model.adcode = adcode;
                [resultArray addObject:model];
            }
            [subscriber sendNext:resultArray];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return weakself.queryDispose;
    }];

}

- (RACSignal *)deleteAddressWithId:(NSUInteger)addrId {
    __weak typeof(self) weakself = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (weakself.deleteDispose) {
            [weakself.deleteDispose dispose];
        }
        weakself.deleteDispose = [[self.networkClient rac_sendPost:nil parameters:nil] subscribeNext:^(id x) {
            
        } error:^(NSError *error) {
            
        } completed:^{
            
        }];
        return weakself.deleteDispose;
    }];
}

@end
