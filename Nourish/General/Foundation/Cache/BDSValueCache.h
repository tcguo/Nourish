//
//  BDSValueCache.h
//  BDStockClient
//
//  Created by licheng on 15/1/15.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "BDSCache.h"

@interface BDSValueCache : BDSCache

/**
 *  同步缓存一个obj
 *
 *  @param data
 *  @param aKey
 *
 *  @return 缓存是否成功
 */
-(BOOL)setObj:(id)data forKey:(NSString *)aKey;

//记录新的缓存key
- (void)recordNewMemoryItemName:(NSString *)akey;

@end
