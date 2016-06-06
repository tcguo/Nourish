//
//  NROrderListViewModel.h
//  Nourish
//
//  Created by tcguo on 16/4/5.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"

@interface NROrderListViewModel : NRBaseViewModel

//@property (nonatomic, copy) NSString *statusDesc;
//@property (nonatomic, assign) NSInteger statusCode;
//@property (nonatomic, copy) NSString *orderId;

@property (nonatomic, assign, readonly) NSInteger orderListNextPageIndex;

- (RACSignal *)cancelRefundWithParametres:(NSDictionary *)parametres;

- (RACSignal *)refundWithParametres:(NSDictionary *)parametres;

- (RACSignal *)changeOrderWithParametres:(NSDictionary *)parametres;

- (RACSignal *)cancelChangeOrderWithParametres:(NSDictionary *)parametres;

- (RACSignal *)readyToPayWithParametres:(NSDictionary *)parametres;

- (RACSignal *)fetchOrderWorkdaysWithParametres:(NSDictionary *)parametres;

- (RACSignal *)cancelOrderWithParametres:(NSDictionary *)parametres;

- (RACSignal *)loadOrderListWithParametres:(NSDictionary *)parametres;
@end

