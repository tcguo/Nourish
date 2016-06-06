//
//  NRAddressViewModel.h
//  Nourish
//
//  Created by tcguo on 16/3/31.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"

@interface NRAddressViewModel : NRBaseViewModel

@property (nonatomic, assign) NSInteger nextPageIndex;

- (RACSignal *)upsertWithParameters:(NSDictionary *)params;
- (RACSignal *)queryAddressListWithParameters:(NSDictionary *)params;
- (RACSignal *)deleteAddressWithId:(NSUInteger)addrId;

@end
