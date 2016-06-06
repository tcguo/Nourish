//
//  NROrderListContainerController.h
//  Nourish
//
//  Created by gtc on 15/8/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"

typedef NS_ENUM(NSUInteger, NROrderListFrom) {
    NROrderListFromCurrentOrder,
    NROrderListFromPay,
};

@interface NROrderListContainerController : NRBaseViewController

@property (assign, nonatomic) NROrderListFrom from;
- (void)refreshOrderList;

@end
