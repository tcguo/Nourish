//
//  NSBaseViewModel.m
//  Nourish
//
//  Created by tcguo on 16/3/23.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewModel.h"

@interface NRBaseViewModel ()

@end

@implementation NRBaseViewModel

- (NRNetworkClient *)networkClient {
    if (!_networkClient) {
        _networkClient = [NRNetworkClient sharedClient];
    }
    return _networkClient;
}
@end
