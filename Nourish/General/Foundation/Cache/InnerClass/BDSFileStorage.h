//
//  BDSFileStorage.h
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSFileStorage : NSObject


/**
 *  清除某个命名空间的过期文件
 *
 *  @param nameSpace    命名空间
 *  @param expireNumber 过期时间
 */
+(void)cleanExpiredFiles:(NSString *)nameSpace expire:(NSNumber *)expireNumber;

//清空整个命名空间
+(BOOL)cleanNameSpace:(NSString*)nameSpace error:(NSError **)error;

//设置缓存命名空间
-(id)initWithNameSpace:(NSString*)nameSpace;
/**
 *  返回错误码(NSError)
 *
 *  @param description 错误信息描述
 *  @param code        错误码
 *
 *  @return 错误对象
 */
-(NSError*)createError:(NSString*)description errorCode:(NSInteger)code;

/**
 *  以key-value 的形式存储数据
 */
-(BOOL)saveObject:(NSData*)obj forKey:(NSString*)key error:(NSError**)error;
/**
 *   判断当前key存不存在
 *
 *  @param key 文件名称
 *
 *  @return yes 存在  ;no 不存在
 */
-(BOOL)existObjectForKey:(NSString*)key;
/**
 *  获取文件data
 *
 *  @param key   文件地址
 *  @param error 错误信息
 *
 *  @return 文件data
 */
-(NSData*)loadObjectForKey:(NSString*)key error:(NSError**)error;
/**
 *  删除文件
 *
 *  @param key   文件名称
 *  @param error 错误信息
 *
 *  @return 是否删除文件成功
 */
-(BOOL)removeObjectForKey:(NSString*)key error:(NSError **)error;
//获取当前对象的存储文件夹
-(NSString*)getStoragePath;
//获取namespace对应的文件路径
+(NSString*)getStoragePath:(NSString*)nameSpace;
//获取文件的完整文件路径
-(NSString*)getFullPathForKey:(NSString*)key;


//1.0.0 获取文件的完整文件路径
-(NSString*)getFullPathForKeyWithOldVersion:(NSString*)key;

@end
