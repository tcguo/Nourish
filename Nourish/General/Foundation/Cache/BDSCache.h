//
//  BDSCache.h
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//
//#import "BDSSingleton.h"
#import "BDSCacheConst.h"
#import <Foundation/Foundation.h>

@interface BDSCache : NSObject

//当前cache所在命名空间
@property (nonatomic,readonly) NSString* nameSpace;

//缓存持久化策略
@property (nonatomic,readonly) BDSCachePolicy cacheStoragePolicy;

//内存缓存容量个数  默认是100
@property (nonatomic,assign) NSUInteger  memoryCapacity;

//内存缓存容量大小   50M = 50*1024*1024   默认缓存不包括此方法
@property (nonatomic,assign) NSUInteger  memoryTotalCost;

//磁盘缓存过期时间 单位 秒  默认不用赋值
@property (nonatomic,assign) NSUInteger  diskExpiredTime;

//单例
+(BDSCache*) sharedCache;

/*--------------------------全局作用----------------*/

/**
 *  清除所有命名空间的缓存
 */
+(void)clearMemory;

/**
 *  清除整个缓存（文件） *慎重
 */
+(void)removeAll;

/**
 *  清除某个namespace的缓存（文件）
 *
 *  @param nameSpace 命名空间
 */
+(void)removeNameSpace:(NSString*)nameSpace;

/**
 *  //获取该命名空间的地址
 *
 *  @param nameSpace 命名空间
 *
 *  @return 该命名空间的地址
 */
+(NSString *)storagePathNameSpace:(NSString *)nameSpace;

/**
 *  通过命名空间 获得文件总大小
 *
 *  @param nameSpace 命名空间
 *
 *  @return 文件大小 MB
 */
+(double)sizeWithStoreageNameSpace:(NSString *)nameSpace;
/*--------------------------局部作用----------------*/

/**
 *  初始化方法
 *
 *  @param nameSpace 命名空间
 *  @param policy    缓存策略
 *
 *  @return self
 */
-(id)initWithNameSpace:(NSString*)nameSpace storagePolicy:(BDSCachePolicy)policy;

/**
 *  是否存在缓存 会判断磁盘和内存
 *
 *  @param key
 *
 *  @return 是否存在缓存
 */
-(BOOL)existCacheForKey:(NSString*)key;

/**
 *  内存中是否有缓存
 *
 *  @param key
 *
 *  @return 内存中是否有缓存
 */
-(BOOL)existCacheForKeyInMemory:(NSString *)key;

/**
 *  磁盘中是否有缓存
 *
 *  @param key
 *
 *  @return 磁盘是否有缓存
 */
-(BOOL)existCacheForKeyOnDisk:(NSString *)key;

/**
 *  同步缓存一个obj
 *
 *  @param data
 *  @param aKey
 *
 *  @return 缓存是否成功
 */
-(BOOL)setObj:(id)data forKey:(NSString *)aKey;

/**
 *  异步缓存一个obj
 *
 *  @param data
 *  @param aKey
 */
-(void)setObjAsync:(id)data forKey:(NSString *)aKey;

/**
 *  同步缓存一个obj
 *
 *  @param data
 *  @param aKey
 *  @param cost
 *
 *  @return 是否缓存成功
 */
-(BOOL)setObj:(id)data forKey:(NSString *)aKey cost:(NSInteger)cost;


/**
 *  从缓存获取一个obj  包括磁盘和内存
 *
 *  @param key
 *
 *  @return 数据
 */
-(id)objectForKey:(NSString*)key;

/**
 *  只从内存缓存获取一个obj
 *
 *  @param key
 *
 *  @return
 */
-(id)objectForKeyOnlyInMemory:(NSString*)key;

/**
 *  异步获取一个obj
 *
 *  @param key
 *  @param completionHandler
 */
-(void)objectForKey:(NSString *)key  completionHandle:(void(^)(BOOL success,id obj))completionHandler;

/**
 *  同步移除obj
 *
 *  @param key
 */
-(void)removeObjcetForKey:(NSString*)key;

/**
 *  异步移除obj
 *
 *  @param key
 */
-(void)removeObjectAsyncForKey:(NSString *)key;

/**
 *  内存缓存移去
 *
 *  @param key
 */
-(void)removeObjcetForKeyOnlyInMemory:(NSString*)key;

/**
 *  清除所有（内存和磁盘）
 */
-(void)removeAll;

/**
 *  清除所有（内存）
 */
-(void)removeAllInMemory;

/**
 *  清除所有（磁盘）
 */
-(void)removeAllInDisk;

/**
 *  获取该命名空间的地址
 *
 *  @return 获取该命名空间的地址
 */
-(NSString *)storagePathNameSpace;

/**
 *  获取文件的完整文件路径
 *
 *  @param key
 *
 *  @return 文件完整路径
 */
-(NSString*)getStorageFullPathForKey:(NSString*)key;

//获取文件的完整文件路径 老的地址
-(NSString *)getStorageOldVersionFullPathForKey:(NSString *)key;


@end
