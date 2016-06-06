//
//  BDSValueCache.m
//  BDStockClient
//
//  Created by licheng on 15/1/15.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#define BDSCache_Record_CacheKeyName @"BDSCache_Record_CacheKeyName"   //缓存的名字key
#define BDSValueCache_Max_Size    100.0    //单位MB

#define kBDSTotoalCleanCache        @"kBDSTotoalCleanCache"     //所有可清除的缓存

#import "BDSValueCache.h"
#import "NSArray+BDSExtension.h"

//#import "BDSLogicManager.h"
@implementation BDSValueCache

-(BOOL)setObj:(id)data forKey:(NSString *)aKey{
    
//    @synchronized(self){
//        //清除超越阀值的数据
//        [self cleanBeyondValueCache];
//        //记录新的缓存key
//        [self recordNewMemoryItemName:aKey];
//    }
    
    return [super setObj:data forKey:aKey];
}

//清除超越阀值的数据
- (void)cleanBeyondValueCache{
    
//    double marketSize = [BDSCache sizeWithStoreageNameSpace:self.nameSpace];
//    if (marketSize > BDSValueCache_Max_Size) {  //当前大小大于总大小
//        [BDSCache removeNameSpace:kBDSTotoalCleanCache];
//        [BDSCache clearMemory];
//    }
    
    NSArray * recordCacheNameArr = [self objectForKey:BDSCache_Record_CacheKeyName];
    if (ARRAYHASVALUE(recordCacheNameArr)) {
        //单位MB
        NSFileManager *fileManager = [NSFileManager defaultManager];
        double marketSize = [BDSCache sizeWithStoreageNameSpace:kBDSTotoalCleanCache];
//        double marketSize = [BDSCache sizeWithStoreageNameSpace:self.nameSpace];

        if (marketSize > BDSValueCache_Max_Size) {  //当前大小大于总大小
            
            NSString * memeryKey = [recordCacheNameArr safeObjectAtIndex:0];
            
            NSString* fullPath = [super getStorageFullPathForKey:memeryKey];
            [fileManager removeItemAtPath:fullPath error:nil];

            NSMutableArray * arr = [[NSMutableArray alloc]initWithArray:recordCacheNameArr];
            [arr safeRemoveObjectAtIndex:0];
            [super setObj:arr forKey:BDSCache_Record_CacheKeyName];
            
            [self cleanBeyondValueCache];
        }else{
        }
        
    }else{
        
    }
    
}

//记录新的缓存key
- (void)recordNewMemoryItemName:(NSString *)akey{

    if (STRINGHASVALUE(akey)) {
        NSArray * recordCacheNameArr = [self objectForKey:BDSCache_Record_CacheKeyName];
        if (ARRAYHASVALUE(recordCacheNameArr)) {//新来的数据放到最后面
            //当程序出现这个提示的时候，是因为你一边便利数组，又同时修改这个数组里面的内容，导致崩溃  需用下面的方法
            NSMutableArray * arr = [[NSMutableArray alloc]initWithArray:recordCacheNameArr];
            NSArray * tempArr = [NSArray arrayWithArray:arr];
            for (NSString * name in tempArr) {
                if (STRINGHASVALUE(name) && [akey isEqualToString:name]) {
                    [arr removeObject:name];
                }
            }
            [arr addObject:akey];
            [super setObj:arr forKey:BDSCache_Record_CacheKeyName];
        }else{
            NSArray * nameArr = [[NSArray alloc]initWithObjects:akey, nil];
            [super setObj:nameArr forKey:BDSCache_Record_CacheKeyName];
        }
    }
}



@end
