//
//  NSBaseViewModel.h
//  Nourish
//
//  Created by tcguo on 16/3/23.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRNetworkClient.h"

@interface NRBaseViewModel : NSObject

@property (nonatomic, weak) NRNetworkClient *networkClient;

@end
