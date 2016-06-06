//
//  NRDistributionAddrModel.m
//  Nourish

//  送餐配送地址

//  Created by gtc on 15/3/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRDistributionAddrModel.h"

@implementation NRDistributionAddrModel

- (NSString *)wholeAddress {
    if (!_wholeAddress) {
        _wholeAddress = [NSString stringWithFormat:@"%@  %@", self.poiName, self.detailAddress];
    }
    return _wholeAddress;
}

@end
