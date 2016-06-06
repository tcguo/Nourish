//
//  BDSStorage.h
//  BDStockClient
//
//  Created by licheng on 14-10-10.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BDSCacheConst.h"
#import <Foundation/Foundation.h>

@interface BDSStorage : NSObject

@property (nonatomic,readonly) NSString* nameSpace;

//初始化存储引擎 namespace是存储名称
-(id)initWithNameSpace:(NSString*)nameSpace;

/*--------------------------同步----------------*/
//同步获取一个data
-(NSData*)dataForKey:(NSString*)key error:(NSError**)error;

//同步存储一个data
-(BOOL)setData:(NSData*)obj forKey:(NSString*)key error:(NSError**)error;

//同步移除一个key
-(BOOL)removeDataForKey:(NSString*)key error:(NSError **)error;

//同步清空整个命名空间
+(BOOL)cleanNameSpace:(NSString*)nameSpace error:(NSError **)error;

//同步读取指定数据类型的数据
- (id)objectForKey:(NSString *)key error:(NSError **)error;


/*--------------------------异步----------------*/

//异步获取一个data
-(void)dataForKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error,id obj))completionHandler;

//异步存储一个data
-(void)setData:(NSData*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;

//异步移除一个data
-(void)removeObjectForKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;

//异步清空整个命名空间
+(void)cleanNameSpace:(NSString*)nameSpace completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;

/*--------------------------共同----------------*/
//该文件是否存在
-(BOOL)isObjectForKeyExist:(NSString*)key;

//清理nameSpace 空间的过期文件
+(void)cleanExpiredFiles:(NSString*)nameSpace expire:(NSNumber *)expireNumber;
//异步读取指定数据类型的数据
- (void)objectForKey:(NSString *)key completionHandle:(void(^)(BOOL success,NSError* error,id obj))completionHandler;
//获取该命名空间的文件地址
+(NSString*)getStoragePath:(NSString*)nameSpace;
//获取文件的完整文件路径
-(NSString*)getStorageFullPathForKey:(NSString*)key;

//获取文件的完整文件路径
-(NSString*)getStorageFullPathForKeyWithOldVersion:(NSString*)key;

@end



//data类型的扩展
@interface BDSStorage (NSDataExtension)

-(BOOL)saveData:(NSData*)obj forKey:(NSString*)key error:(NSError**)error;
-(void)saveData:(NSData*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;

@end

//string类型的扩展
@interface BDSStorage (NSStringExtension)
-(NSString*)parseStringObject:(NSData*)data;
-(BOOL)saveString:(NSString*)obj forKey:(NSString*)key error:(NSError**)error;
-(void)saveString:(NSString*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;
@end

//array类型的扩展
@interface BDSStorage (NSArrayExtension)
-(NSArray*)parseArrayObject:(NSData*)data;
-(BOOL)saveArray:(NSArray*)obj forKey:(NSString*)key error:(NSError**)error;
-(void)saveArray:(NSArray*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;
@end


//dict类型的扩展
@interface BDSStorage (NSDictionaryExtension)
-(NSDictionary*)parseDictionaryObject:(NSData*)data;
-(BOOL)saveDictionary:(NSDictionary*)obj forKey:(NSString*)key error:(NSError**)error;
-(void)saveDictionary:(NSDictionary*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;
@end



//支持coding协议类型的扩展
@interface BDSStorage (NSCodingExtension)

-(id)parseCodingObject:(NSData*)data;
-(id)loadCodingObject:(NSString*)key error:(NSError**)error;
-(void)loadCodingForKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error,id obj))completionHandler;
-(BOOL)saveCodingObject:(id)obj forKey:(NSString*)key error:(NSError**)error;
-(void)saveCodingObject:(id)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler;

@end







