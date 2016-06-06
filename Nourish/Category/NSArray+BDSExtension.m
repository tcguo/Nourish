//
//  NSArray+BDSExtension.m
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "NSArray+BDSExtension.h"

@implementation NSArray (BDSExtension)

- (id)safeObjectAtIndex:(NSUInteger)index
{
	if ( index >= self.count )
		return nil;
    
	return [self objectAtIndex:index];
}

-(NSData*)cdata
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return data;
}
@end

#pragma mark -

@implementation NSMutableArray (BDSExtension)

- (void)safeAddObject:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}

-(bool)safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    if ( index >= self.count && index != 0)
	{
        return NO;
    }
    
    if (!anObject)
    {
        return NO;
    }
    
    [self insertObject:anObject atIndex:index];
    
    return YES;
}

-(bool)safeRemoveObjectAtIndex:(NSUInteger)index
{
    if ( index >= self.count )
	{
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;

}

-(bool)safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if ( index >= self.count )
	{
        return NO;
    }
    [self replaceObjectAtIndex:index withObject:anObject];
    return YES;
}


@end
