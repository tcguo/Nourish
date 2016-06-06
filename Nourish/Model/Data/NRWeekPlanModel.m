//
//  NRWeekPlanModel.m
//  Nourish
//
//  Created by gtc on 15/1/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRWeekPlanModel.h"

@interface NRWeekPlanModel ()
{
    
}

@property (readwrite, nonatomic, copy) NSString *imageUrlString;
@property (readwrite, nonatomic, assign) NSUInteger weekplanID;
@property (readwrite, nonatomic, assign) NSUInteger price;
@property (readwrite, nonatomic, copy) NSString *weekplanName;
@property (readwrite, nonatomic, copy) NSString *descZH;
@property (readwrite, nonatomic, copy) NSString *descEN;

@end

@implementation NRWeekPlanModel

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self.weekplanID = [[attributes valueForKey:@"wptid"] integerValue];
    self.price = (NSUInteger)[[attributes valueForKeyPath:@"price"] integerValue];
    self.weekplanName = [attributes valueForKeyPath:@"name"];
    self.imageUrlString = [attributes valueForKeyPath:@"imageurl"];
    self.descZH = [attributes valueForKeyPath:@"descZH"];
    self.descEN = [attributes valueForKeyPath:@"descEN"];
    
    return self;
}

- (NSURL *)imageUrl
{
    return [NSURL URLWithString:self.imageUrlString];
}

@end
