//
//  NRPlaceOrderViewModel.h
//  Nourish
//
//  Created by tcguo on 15/12/11.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"
#import "NRDistributionAddrModel.h"


typedef void(^MyCompletionBlock)(id resultObject, NSError *error);

@interface NRPlaceOrderViewModel : NRBaseViewModel

@property (nonatomic, strong) NRDistributionAddrModel *availableAddrModel;
@property (nonatomic, assign) NSUInteger couponCount;
@property (nonatomic, copy, readonly) NSString *orderId;
@property (nonatomic, copy, readonly) NSString *totalFee;

- (void)fetchReadyInfoWithSMWIds:(NSArray *)smwIds completeBlock:(MyCompletionBlock)completeBlock;
- (RACSignal *)submitOrderWithParametres:(NSDictionary *)parametres;
@end
