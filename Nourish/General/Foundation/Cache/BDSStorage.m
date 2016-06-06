//
//  BDSStorage.m
//  BDStockClient
//
//  Created by licheng on 14-10-10.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BDSStorage.h"
#import "BDSFileStorage.h"
#import "NSData+BDSExtension.h"
#import "NSArray+BDSExtension.h"
#import "NSString+BDSExtension.h"
#import "NSDictionary+BDSExtension.h"

typedef enum {
    BDSCacheObjectTypeData = 1,
    BDSCacheObjectTypeArray,
    BDSCacheObjectTypeDictionary,
    BDSCacheObjectTypeString,
    BDSCacheObjectTypeCoding,
} BDSCacheObjectType;

@interface BDSStorage()
//物理存储引擎
@property (nonatomic,retain) id storageEngine;

@end

@implementation BDSStorage

//全局唯一读写队列
//同步队列
static dispatch_queue_t get_bds_sy_queue()
{
    static dispatch_queue_t  bdsSyncQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bdsSyncQueue = dispatch_queue_create("com.baidu.bds.disksyn", DISPATCH_QUEUE_SERIAL);
    });
    return bdsSyncQueue;
}
//异步队列
static dispatch_queue_t get_bds_asy_queue()
{
    static dispatch_queue_t BDSAsyncQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BDSAsyncQueue = dispatch_queue_create("com.baidu.bds.diskasyn", DISPATCH_QUEUE_SERIAL);
    });
    return BDSAsyncQueue;
}


-(id)initWithNameSpace:(NSString*)nameSpace 
{

    self = [super init];
    if(self)
    {   
        _nameSpace = [nameSpace copy];
        //根据策略选择引擎 以后可以扩展sql
        self.storageEngine = [[BDSFileStorage alloc] initWithNameSpace:nameSpace];
    }
//    BDSLog(@"initWithNameSpace end");
    return self;
}


-(NSError*)createError:(NSString*)description errorCode:(NSInteger)code
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"com.baidu.bds" code:code userInfo:userInfo];
}


#pragma mark - 同步

//同步读
-(NSData*)dataForKey:(NSString*)key error:(NSError**)error
{
//    BDSLog(@"dataForKey key = %@",key);
    //保证线程安全使用sync和async调用一个队列
    __block NSData* data = nil;
    dispatch_sync(get_bds_sy_queue(), ^{

        data =[self.storageEngine loadObjectForKey:key error:error];
    });
//    BDSLog(@"dataForKey key = %@ end",key);
    return data;
}
//同步写
-(BOOL)setData:(NSData*)obj forKey:(NSString*)key error:(NSError**)error
{
//    BDSLog(@"setData key = %@",key);
    __block BOOL bRet = FALSE;
    dispatch_sync(get_bds_sy_queue(), ^{
        bRet = [self.storageEngine saveObject:obj forKey:key error:error];
    });
//    BDSLog(@"setData key = %@ end",key);
    return bRet;
}
//同步删除
-(BOOL)removeDataForKey:(NSString*)key error:(NSError **)error
{
//    BDSLog(@"removeDataForKey key = %@",key);
    __block BOOL bRet = FALSE;
    dispatch_sync(get_bds_sy_queue(), ^{
        bRet =   [self.storageEngine removeObjectForKey:key error:error];
    });
//    BDSLog(@"removeDataForKey key = %@ end",key);
    return bRet;
}


//同步清空整个命名空间
+(BOOL)cleanNameSpace:(NSString*)nameSpace error:(NSError **)error
{
    return [BDSFileStorage cleanNameSpace:nameSpace error:error];
}

//同步存储指定数据类型的数据
- (BOOL)setObject:(NSData *)data forKey:(NSString *)key type:(BDSCacheObjectType)type error:(NSError **)error
{
    NSMutableData *saveData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(type)];
    [saveData appendData:data];
    
    return [self setData:saveData forKey:key error:error];
}
//同步读取指定数据类型的数据
- (id)objectForKey:(NSString *)key error:(NSError **)error
{
//    BDSLog(@"objectForKey key = %@",key);
    
    //保证线程安全使用sync和async调用一个队列
    NSData* data = nil;
    id obj = nil;
    
    data = [self dataForKey:key error:error];
    if(data.length > 2)
    {
        int type = 0;
        NSData *typeHeader = [data subdataWithRange:NSMakeRange(0, sizeof(type))];
        [typeHeader getBytes:&type];
        NSData *dataContent = [data subdataWithRange:NSMakeRange(sizeof(type), data.length - sizeof(type))];
        switch (type) {
            case BDSCacheObjectTypeData:
                obj = dataContent;
                break;
            case BDSCacheObjectTypeArray:
                obj = [self parseArrayObject:dataContent];
                break;
            case BDSCacheObjectTypeDictionary:
                obj = [self parseDictionaryObject:dataContent];
                break;
            case BDSCacheObjectTypeString:
                obj = [self parseStringObject:dataContent];
                break;
            case BDSCacheObjectTypeCoding:
                obj = [self parseCodingObject:dataContent];
                break;
            default:
                break;
        }
    }
    
//    BDSLog(@"objectForKey key = %@ end",key);
    
    return obj;
}


#pragma mark - 异步
//异步读
-(void)dataForKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error,id obj))completionHandler
{
//    BDSLog(@"dataForKeyAsy key = %@",key);
    dispatch_async(get_bds_asy_queue(), ^{
        
        NSError* error = nil;
        NSData* data =[self dataForKey:key error:&error];
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                BOOL bSuccess = NO;
                if (data) {
                    bSuccess = YES;
                }
                completionHandler(bSuccess,error,data);
            });
        }
        
    });
}
//异步写
-(void)setData:(NSData*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler
{
//    BDSLog(@"setDataAsy key = %@",key);
    dispatch_async(get_bds_asy_queue(), ^{
        NSError* error = nil;
        
        BOOL bSuccess  = [self setData:obj forKey:key error:&error];
        if (completionHandler)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler(bSuccess,error);
            });
        }
    });
}
//异步删除
-(void)removeObjectForKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler
{
//    BDSLog(@"removeObjectForKeyAsy key = %@",key);
    dispatch_async(get_bds_asy_queue(), ^{
        NSError* error = nil;
        BOOL bSuccess  = [self removeDataForKey:key error:&error];
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler(bSuccess,error);
            });
        }
    });
    
}

//异步清空整个命名空间
+(void)cleanNameSpace:(NSString*)nameSpace completionHandle:(void(^)(BOOL success,NSError* error))completionHandler
{
    dispatch_async(get_bds_asy_queue(), ^{
        NSError* error = nil;
        BOOL bSuccess = [BDSStorage cleanNameSpace:nameSpace  error:&error];
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler(bSuccess,error);
            });
        }
    });
}

//异步存储指定数据类型的数据
- (void)setObject:(NSData*)data forKey:(NSString*)key type:(BDSCacheObjectType)type completionHandle:(void(^)(BOOL success,NSError* error))completionHandler
{
    dispatch_async(get_bds_asy_queue(), ^{
        NSError* error = nil;
        BOOL bSuccess =  [self setObject:data forKey:key type:type error:&error];
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler(bSuccess,error);
            });
        }
    });
}

//异步读取指定数据类型的数据
- (void)objectForKey:(NSString *)key completionHandle:(void(^)(BOOL success,NSError* error,id obj))completionHandler
{
//    BDSLog(@"objectForKeyAsy key = %@",key);
    
    dispatch_async(get_bds_asy_queue(), ^{
        NSError* error = nil;
        id data = [self objectForKey:key error:&error];
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                BOOL bSuccess = NO;
                if (data) {
                    bSuccess = YES;
                }
                completionHandler(bSuccess,error,data);
            });
        }
    });
}

#pragma mark - other
//清理nameSpace 空间的过期文件
+(void)cleanExpiredFiles:(NSString*)nameSpace expire:(NSNumber *)expireNumber
{
    [BDSFileStorage cleanExpiredFiles:nameSpace expire:expireNumber];
}

//该文件是否存在
-(BOOL)isObjectForKeyExist:(NSString*)key
{
    return  [self.storageEngine existObjectForKey:key];
}

//获取该命名空间的文件地址
+(NSString*)getStoragePath:(NSString*)nameSpace
{
    return [BDSFileStorage getStoragePath:nameSpace];
}


//获取文件的完整文件路径
-(NSString*)getStorageFullPathForKey:(NSString*)key
{
    return [self.storageEngine getFullPathForKey:key];
}


//获取文件的完整文件路径 老的地址
-(NSString*)getStorageFullPathForKeyWithOldVersion:(NSString*)key
{
    return [self.storageEngine getFullPathForKeyWithOldVersion:key];
}



@end


//data类型的扩展
@implementation BDSStorage (NSDataExtension)


-(BOOL)saveData:(NSData*)obj forKey:(NSString*)key error:(NSError**)error
{
    return [self setObject:obj forKey:key type:BDSCacheObjectTypeData error:error];
}

-(void)saveData:(NSData*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler
{
    [self setObject:obj forKey:key type:BDSCacheObjectTypeData completionHandle:completionHandler];
}

@end



@implementation BDSStorage (NSArrayExtension)

-(NSArray*)parseArrayObject:(NSData *)data {
    return [data array];
}

-(BOOL)saveArray:(NSArray*)obj forKey:(NSString*)key error:(NSError**)error {
    return [self setObject:[obj cdata] forKey:key type:BDSCacheObjectTypeArray error:error];
}

-(void)saveArray:(NSArray*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler {
    [self setObject:[obj cdata] forKey:key type:BDSCacheObjectTypeArray completionHandle:completionHandler];
}

@end


@implementation BDSStorage (NSDictionaryExtension)

-(NSDictionary*)parseDictionaryObject:(NSData *)data {
    return [data dictionary];
}

-(BOOL)saveDictionary:(NSDictionary*)obj forKey:(NSString*)key error:(NSError**)error {
    return [self setObject:[obj data] forKey:key type:BDSCacheObjectTypeDictionary error:error];
}

-(void)saveDictionary:(NSDictionary*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler {
    [self setObject:[obj data] forKey:key type:BDSCacheObjectTypeDictionary completionHandle:completionHandler];
}

@end

@implementation BDSStorage (NSStringExtension)

-(NSString*)parseStringObject:(NSData *)data {
    return [data UTF8String];
}

-(BOOL)saveString:(NSString*)obj forKey:(NSString*)key error:(NSError**)error {
    return [self setObject:[obj UTF8Data] forKey:key type:BDSCacheObjectTypeString error:error];
}

-(void)saveString:(NSString*)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler {
    [self setObject:[obj UTF8Data] forKey:key type:BDSCacheObjectTypeString completionHandle:completionHandler];
}

@end




@implementation BDSStorage (NSCodingExtension)

- (id)parseCodingObject:(NSData *)data
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

-(id)loadCodingObject:(NSString*)key error:(NSError**)error
{
    return [self objectForKey:key error:error];
}

-(void)loadCodingForKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error,id obj))completionHandler
{
    [self objectForKey:key completionHandle:^(BOOL success, NSError *error, id obj) {
        completionHandler(success, error, obj);
    }];
}

-(BOOL)saveCodingObject:(id)obj forKey:(NSString*)key error:(NSError**)error
{
    if (![obj conformsToProtocol:@protocol(NSCoding)])
    {
        if (error) {
            *error = [self createError:@"obj not support NSCoding protocol" errorCode:-1];
        }
        return NO;
    }
    
    return [self setObject:[NSKeyedArchiver archivedDataWithRootObject:obj] forKey:key type:BDSCacheObjectTypeCoding error:error];
}

-(void)saveCodingObject:(id)obj forKey:(NSString*)key completionHandle:(void(^)(BOOL success,NSError* error))completionHandler
{
    if (![obj conformsToProtocol:@protocol(NSCoding)])
    {
        if (completionHandler) {
            completionHandler(NO,[self createError:@"obj not support NSCoding protocol" errorCode:-1]);
        }
        return;
    }
    
    [self setObject:[NSKeyedArchiver archivedDataWithRootObject:obj] forKey:key type:BDSCacheObjectTypeCoding completionHandle:nil];
}

@end










