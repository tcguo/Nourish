//
//  NSArray+BDSExtension.h
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (BDSExtension)

//加了安全保护，如果index大于总数会返回nil
- (id)safeObjectAtIndex:(NSUInteger)index;

////将array变成data
-(NSData*)cdata;

@end

#pragma mark -

@interface NSMutableArray (BDSExtension)

//安全add函数
- (void)safeAddObject:(id)anObject;
//安全插入函数
-(bool)safeInsertObject:(id)anObject atIndex:(NSUInteger)index;
//安全移除函数
-(bool)safeRemoveObjectAtIndex:(NSUInteger)index;
//安全替换函数
-(bool)safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end