//
//  NRGlobalManager.h
//  Nourish
//
//  Created by tcguo on 16/4/5.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRGlobalManager : NSObject
@property (nonatomic, copy, readonly) NSString *customerPhone;

+ (instancetype)sharedInstance;
- (void)getCustomerPhone;

@end
