//
//  NRRecordViewModel.h
//  Nourish
//
//  Created by tcguo on 16/4/6.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"

@interface NRRecordViewModel : NRBaseViewModel
@property (nonatomic, copy, readonly) NSString *shareTitle;
@property (nonatomic, copy, readonly) NSString *shareDesc;
@property (nonatomic, copy, readonly) NSString *shareLink;

- (RACSignal *)fetchShareInfoWithParametres:(NSDictionary *)params;

@end
