//
//  NSData+BDSExtension.m
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "NSData+BDSExtension.h"

@implementation NSData (BDSExtension)

- (NSString *)UTF8String
{
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return string;
}


-(NSArray*)array
{
    NSArray* arr= [NSKeyedUnarchiver unarchiveObjectWithData:self];
    return arr;
}
-(NSDictionary*)dictionary
{
    NSDictionary* dictionary= [NSKeyedUnarchiver unarchiveObjectWithData:self];
    return dictionary;
}
@end
