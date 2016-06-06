//
//  BDSMemoryStorage.m
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BDSMemoryStorage.h"

@interface BDSMemoryItem : NSObject

@property (nonatomic,strong) id cacheObj;

@end
@implementation BDSMemoryItem

- (void)dealloc
{
    self.cacheObj = nil;
}

@end

#pragma mark-


@interface BDSMemoryStorage()

@property (nonatomic,strong) NSString* nameSpace;
@property (nonatomic,strong) NSCache* memoryCache;   //缓存  命名空间
@property (nonatomic,assign) NSUInteger time_count;

@end


@implementation BDSMemoryStorage

#pragma mark - 类方法
//清空整个内存
+(void)cleanAllMemory
{
    for (BDSMemoryStorage* memory in [get_memory_namespace_dict() allValues])
    {
        [memory.memoryCache removeAllObjects];
    }
}
//获取所有缓存
static NSMutableDictionary* get_memory_namespace_dict()
{
    static NSMutableDictionary *idpShareMemDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idpShareMemDict = [NSMutableDictionary new];
    });
    return idpShareMemDict;
}
#pragma mark - 实例方法
/**
 *  创建缓存模块
 *
 *  @param nameSpace 缓存名称
 *
 *  @return self
 */
-(id)initWithNameSpace:(NSString*)nameSpace
{
    self = [super init];
    if (self)
    {
        self.nameSpace = nameSpace;
        self.memoryCache = [NSCache new];
        [get_memory_namespace_dict() setObject:self forKey:nameSpace];
    }
    return self;
}
/**
 *  内存配额（数量）
 *
 *  @param memoryCapacity （数量）
 */
-(void)setMemoryCapacity:(NSUInteger)memoryCapacity
{
    [self.memoryCache setCountLimit:memoryCapacity];
}
/**
 *  内存配额（容量）
 *
 *  @param memoryTotalCost （容量）
 */
- (void)setMemoryTotalCost:(NSUInteger)memoryTotalCost
{
    [self.memoryCache setTotalCostLimit:memoryTotalCost];
}
/**
 *  获取缓存数量
 *
 *  @return 数量
 */
-(NSUInteger)getMemoryCapacity
{
    return self.memoryCache.countLimit;
}
/**
 *  key所对应的value 是否存在
 *
 *  @param key
 *
 *  @return yes 存在 no 不存在
 */
-(BOOL)existObjectForKey:(NSString*)key
{
    id obj = [self.memoryCache objectForKey:key];
    if (obj) {
        return YES;
    }
    return NO;
}
/**
 *  返回 key所对应的value
 *
 *  @param key
 *
 *  @return
 */
-(id)loadObjectForKey:(NSString*)key
{
    BDSMemoryItem* item = [self.memoryCache objectForKey:key];
    return item.cacheObj;
}
/**
 *  存key - vlue
 *
 *  @param obj
 *  @param key
 */
-(void)saveObject:(id)obj forKey:(NSString*)key
{
    BDSMemoryItem* item = [[BDSMemoryItem alloc] init];
    item.cacheObj = obj;
    [self.memoryCache setObject:item forKey:key];

}
/**
 *  存key - vlue
 *
 *  @param obj
 *  @param key
 *  @param g    //当前数据的大小  统一由data.length 来获取
 */
-(void)saveObject:(id)obj forKey:(NSString *)key cost:(NSUInteger)g
{
    BDSMemoryItem* item = [[BDSMemoryItem alloc] init];
    item.cacheObj = obj;
    [self.memoryCache setObject:item forKey:key cost:g];
}

/**
 *  移除key 所对应的value
 *
 *  @param key
 */
-(void)removeObjectForKey:(NSString*)key
{
    [self.memoryCache removeObjectForKey:key];
}

/**
 *  清除缓存
 */
-(void)removeAll
{
    [self.memoryCache removeAllObjects];
}



@end
