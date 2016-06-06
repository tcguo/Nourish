//
//  BDSFileStorage.m
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BDSFileStorage.h"
#import "NSString+BDSExtension.h"
@interface BDSFileStorage()

@property (nonatomic,strong) NSString* nameSpace;
@property (nonatomic,strong,getter = getStoragePath) NSString* storagePath;

@property (nonatomic,strong,getter = getStorageOldPath) NSString* storageOldPath; //老版本的目录兼容1.0.0
@end


@implementation BDSFileStorage


#pragma mark - 类方法
/**
 *  清除某个命名空间的过期文件
 *
 *  @param nameSpace    命名空间
 *  @param expireNumber 过期时间
 */
+(void)cleanExpiredFiles:(NSString *)nameSpace expire:(NSNumber *)expireNumber
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:[BDSFileStorage getStoragePath:nameSpace]];
        NSString *filePath = [enumerator nextObject];
        NSDate *date = [[NSDate alloc] init];
        double currDate = [date timeIntervalSince1970];
        
        while (filePath) {
            @autoreleasepool
            {
                NSDictionary *attributes = [enumerator fileAttributes];
                double modifyDate = [(NSDate *)[attributes objectForKey:NSFileModificationDate] timeIntervalSince1970];
                double expireDate = modifyDate + [expireNumber doubleValue];
                if (expireDate < currDate) {
                    NSString *fullPath = [[BDSFileStorage getStoragePath:nameSpace] stringByAppendingPathComponent:filePath];
//                    BDSLog(@"Delete cached file: %@", fullPath);
                    [manager removeItemAtPath:fullPath error:nil];
                }
                filePath = [enumerator nextObject];
            }
        }
    });
}

//清空整个命名空间
+(BOOL)cleanNameSpace:(NSString*)nameSpace error:(NSError **)error
{
    //老版本的
    NSString* fullPathOldVersion  =  [BDSFileStorage getStoragePathWithOldVersion:nameSpace];
    NSFileManager* manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:fullPathOldVersion error:error];
    //新版本的
    NSString* fullPath  =  [BDSFileStorage getStoragePath:nameSpace];
//    NSFileManager* manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:fullPath error:error];
}

#pragma mark - 实例方法

//设置缓存命名空间
-(id)initWithNameSpace:(NSString*)nameSpace
{
    self = [super init];
    if (self)
    {
        self.nameSpace = nameSpace;
        //新建namesapce目录
        NSFileManager * fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:self.storagePath]) {
            [fm createDirectoryAtPath:self.storagePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //老版本namespace 目录  兼容1.0.0版本
        if (![fm fileExistsAtPath:self.storageOldPath]) {
            [fm createDirectoryAtPath:self.storageOldPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    return self;
}

/**
 *  返回错误码(NSError)
 *
 *  @param description 错误信息描述
 *  @param code        错误码
 *
 *  @return 错误对象
 */
-(NSError*)createError:(NSString*)description errorCode:(NSInteger)code
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"com.baidu.BDS" code:code userInfo:userInfo];
}

/**
 *  以key-value 的形式存储数据
 */
-(BOOL)saveObject:(NSData*)obj forKey:(NSString*)key error:(NSError**)error
{
    if (OBJECTISNULL(obj)) {
        if (error) {
            *error = [self createError:@"not support Null value" errorCode:-1];
        }
        return FALSE;
    }
    NSString* fullPath = [self getFullPathForKey:key];
    //新建namesapce目录
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:self.storagePath])
    {
        [fm createDirectoryAtPath:self.storagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL isSuccess = [fm createFileAtPath:fullPath contents:obj attributes:nil];
    
    if (isSuccess) { //不同步到云端
        NSURL *filePath = [NSURL fileURLWithPath:fullPath];
        // Delete by tcguo 2015-12-05 16:52:25
//        [filePath addSkipBackupAttributeToItemAtURL];
        
        //老版本的数据 如果存在 则删除
        [self removeObjectForKeyWithOldVersion:key error:nil];
    }
    return isSuccess;
}
/**
 *   判断当前key存不存在
 *
 *  @param key 文件名称
 *
 *  @return yes 存在  ;no 不存在
 */
-(BOOL)existObjectForKey:(NSString*)key
{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString* fullPath = [self getFullPathForKey:key];
    if ([manager fileExistsAtPath:fullPath]) {
        return YES;
    }
    return NO;
}

/**
 *  获取文件data
 *
 *  @param key   文件地址
 *  @param error 错误信息
 *
 *  @return 文件data
 */
-(NSData*)loadObjectForKey:(NSString*)key error:(NSError**)error
{
    NSString* fullPath = [self getFullPathForKey:key];
    NSData* data= [NSData dataWithContentsOfFile:fullPath];
    if (data != nil && data.length>0) { //新版本数据
        // 更新文件修改时间，以便不被清除
        NSFileManager* manager = [NSFileManager defaultManager];
        [manager setAttributes: @{NSFileModificationDate: [NSDate date]} ofItemAtPath:fullPath error:nil];
        return data;
        
    }else{ //旧版本老数据]
        NSString* fullPatholdVersion = [self getFullPathForKeyWithOldVersion:key];
        NSData* data= [NSData dataWithContentsOfFile:fullPatholdVersion];
        // 更新文件修改时间，以便不被清除
        NSFileManager* manager = [NSFileManager defaultManager];
        [manager setAttributes: @{NSFileModificationDate: [NSDate date]} ofItemAtPath:fullPatholdVersion error:nil];
        return data;
    }
}

/**
 *  删除文件
 *
 *  @param key   文件名称
 *  @param error 错误信息
 *
 *  @return 是否删除文件成功
 */
-(BOOL)removeObjectForKey:(NSString*)key error:(NSError **)error
{
    //清除老数据
    if ([self existObjectForKeyWithOldVersion:key]) {
        NSString* fullPath = [self getFullPathForKeyWithOldVersion:key];
        NSFileManager* manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:fullPath error:error];
    }
    
    if ([self existObjectForKey:key]) {
        NSString* fullPath = [self getFullPathForKey:key];
        NSFileManager* manager = [NSFileManager defaultManager];
        return [manager removeItemAtPath:fullPath error:error];
    }
    return YES;
}

//获取当前对象的存储文件夹
-(NSString*)getStoragePath
{
    if(!_storagePath)
    {
        _storagePath = [[BDSFileStorage getStoragePath:self.nameSpace] copy];
    }
    return _storagePath;
}


//获取namespace对应的文件路径
+(NSString*)getStoragePath:(NSString*)nameSpace
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullFileName = [NSString stringWithFormat:@"%@",nameSpace] ;
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fullFileName];
    return path;
}


//获取文件的完整文件路径
-(NSString*)getFullPathForKey:(NSString*)key
{
    NSString* fullPath = [self.storagePath stringByAppendingPathComponent:key];
    return fullPath;
}


#pragma mark - 兼容老版本  namespace 和 key 进行了md5加密

/**
 *   判断当前key存不存在
 *
 *  @param key 文件名称
 *
 *  @return yes 存在  ;no 不存在
 */
-(BOOL)existObjectForKeyWithOldVersion:(NSString*)key
{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString* fullPath = [self getFullPathForKeyWithOldVersion:key];
    if ([manager fileExistsAtPath:fullPath]) {
        return YES;
    }
    return NO;
}

/**
 *  获取文件data
 *
 *  @param key   文件地址
 *  @param error 错误信息
 *
 *  @return 文件data
 */
-(NSData*)loadObjectForKeyWithOldVersion:(NSString*)key error:(NSError**)error
{
    NSString* fullPath = [self getFullPathForKeyWithOldVersion:key];
    NSData* data= [NSData dataWithContentsOfFile:fullPath];
    // 更新文件修改时间，以便不被清除
    NSFileManager* manager = [NSFileManager defaultManager];
    [manager setAttributes: @{NSFileModificationDate: [NSDate date]} ofItemAtPath:fullPath error:nil];
    return data;
}

/**
 *  删除文件
 *
 *  @param key   文件名称
 *  @param error 错误信息
 *
 *  @return 是否删除文件成功
 */
-(BOOL)removeObjectForKeyWithOldVersion:(NSString*)key error:(NSError **)error
{
    if ([self existObjectForKeyWithOldVersion:key]) {
        NSString* fullPath = [self getFullPathForKeyWithOldVersion:key];
        NSFileManager* manager = [NSFileManager defaultManager];
        return [manager removeItemAtPath:fullPath error:error];
    }
    return YES;
}


//获取当前对象的存储文件夹
-(NSString*)getStorageOldPath
{
    if(!_storageOldPath)
    {
        _storageOldPath = [[BDSFileStorage getStoragePathWithOldVersion:self.nameSpace] copy];
    }
    return _storageOldPath;
}

//1.0.0版本 获取namespace对应的文件路径
+(NSString*)getStoragePathWithOldVersion:(NSString*)nameSpace
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullFileName = [[NSString stringWithFormat:@"%@",nameSpace] MD5];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fullFileName];
    return path;
}

//1.0.0 获取文件的完整文件路径
-(NSString*)getFullPathForKeyWithOldVersion:(NSString*)key
{
    NSString* md5 = [key MD5];
    NSString* fullPath = [self.storageOldPath stringByAppendingPathComponent:md5];
    return fullPath;
}




@end
