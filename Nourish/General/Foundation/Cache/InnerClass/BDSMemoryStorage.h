//
//  BDSMemoryStorage.h
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSMemoryStorage : NSObject

//内存配额（数量）
@property (nonatomic,assign) NSUInteger  memoryCapacity;
//内存配额（容量）
@property (nonatomic,assign) NSUInteger  memoryTotalCost;

//清空整个内存
+(void)cleanAllMemory;
//创建缓存并指定缓存名称
-(id)initWithNameSpace:(NSString*)nameSpace;

//从内存中读取
-(id)loadObjectForKey:(NSString*)key;

//内存中是否存在
-(BOOL)existObjectForKey:(NSString*)key;

//从内存中删除
-(void)removeObjectForKey:(NSString*)key;

//保存到内存中
-(void)saveObject:(id)obj forKey:(NSString*)key;

//保存到内存中通过cost 来标注当前数据的位置
-(void)saveObject:(id)obj forKey:(NSString *)key cost:(NSUInteger)g;

//清除所有
-(void)removeAll;

@end
