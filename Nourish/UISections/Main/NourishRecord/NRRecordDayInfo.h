//
//  NRRecordDayInfo.h
//  Nourish
//
//  Created by gtc on 8/24/15.
//  Copyright (c) 2015 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRRecordDayInfo : NSObject

@property (assign, nonatomic) NSUInteger  nrProvide;//诺食提供
@property (assign, nonatomic) NSUInteger dayth;
@property (copy, nonatomic) NSString *themeName;
@property (copy, nonatomic) NSString *wpName;//周计划名称
@property (copy, nonatomic) NSString *themeContent;//主提日描述
@end
