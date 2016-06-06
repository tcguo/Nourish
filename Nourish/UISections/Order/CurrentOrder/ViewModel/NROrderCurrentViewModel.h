//
//  NROrderCurrentViewModel.h
//  Nourish
//
//  Created by tcguo on 16/3/23.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"
#import "NROrderCurrentJSONModel.h"

@interface NROrderCurrentViewModel : NRBaseViewModel

@property (nonatomic, strong) NROrderCurrentJSONModel *model;
- (RACSignal *)fetchOrderWithDates:(NSArray *)dates;
- (RACSignal *)fetchCurrentOrder;
- (RACSignal *)refreshDispatchStatusWithParametres:(NSDictionary *)parametres;
@end
