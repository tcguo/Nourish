//
//  NRMessageViewModel.h
//  Nourish
//
//  Created by tcguo on 16/3/29.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"
#import "NRSystemMessageModel.h"

@interface NRMessageViewModel : NRBaseViewModel
@property (nonatomic, assign, readonly) NSInteger nextPageIndex;

- (RACSignal *)loadMessageWithParametres:(NSDictionary *)parametres;

@end