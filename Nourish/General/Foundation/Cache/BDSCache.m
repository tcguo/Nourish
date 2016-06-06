//
//  BDSCache.m
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "BDSCache.h"
#import "BDSMemoryStorage.h"
#import "BDSStorage.h"
#import "BDSConfig.h"
#import "NSDictionary+BDSExtension.h"


//存储现有缓存namespace的key
#define BDSAllCacheNameSpace                                   @"bds_all_cache_namespace"

//存储单个缓存config的key
#define BDSCacheConfigKey                                      @"bds_cache_config"

//存储缓存策略
#define BDSCacheConfigPolicy                                   @"bds_cache_policy"

//存储缓存磁盘缓存过期时间
#define BDSCacheConfigDiskExpiredTime                          @"bds_cache_config_diskExpiredTime"

//存储缓存的内存缓存容量
#define BDSCacheConfigMemoryCapacity                           @"bds_cache_config_memorycapacity"



@interface BDSCache()

//文件存储引擎
@property (nonatomic,strong) BDSStorage * fileStorag;
//内存缓存引擎
@property (nonatomic,strong) BDSMemoryStorage * memoryStorag;
//配置模块
@property (nonatomic,retain) BDSConfig* config;
//配置项dict
@property (nonatomic,retain) NSMutableDictionary*  configDict;

@end


@implementation BDSCache

static BDSCache* g_sharedCache = nil;

+ (BDSCache*) sharedCache
{
    @synchronized(self)
    {
        if (g_sharedCache == nil) {
        
            g_sharedCache = [[self alloc] initWithNameSpace:@"default_cache" storagePolicy:BDSCStorageMemoryAndDisk];
        }
    }
    return g_sharedCache;
}


#pragma mark - 类方法

+ (void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

//清理整个内存
+ (void)clearMemory
{
    [BDSMemoryStorage cleanAllMemory];
}
//清除文件存储
+ (void)cleanFileCache
{
//    BDSLog(@"cleanFileCache");
    //先获取现有的所有缓存的namespace
    BDSConfig* config = [[BDSConfig alloc] initWithNameSpace:BDSAllCacheNameSpace];
    NSArray* array = [config arrayForKey:BDSAllCacheNameSpace];
    //finnalArr用来存储更新后的所有缓存的namesapce
    NSMutableArray* finnalArr = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    for (NSString* nameSpace in array) {

            BDSConfig* configInner = [[BDSConfig alloc] initWithNameSpace:nameSpace] ;
            NSDictionary* configDict = [configInner dictionaryForKey:BDSCacheConfigKey];
            if (!configDict) {
                continue;
            }
            NSNumber* expiredNumber = [configDict numberAtPath:BDSCacheConfigDiskExpiredTime];
            [BDSStorage cleanExpiredFiles:nameSpace expire:expiredNumber];
            [finnalArr addObject:nameSpace];
        
    }
    //更新配置
    [config setObject:finnalArr forKey:BDSAllCacheNameSpace];

//    BDSLog(@"cleanFileCache end");
}

//清除整个内存及文件存储
+ (void)cleanBackground
{
    [BDSCache clearMemory];
    long expiredDiskTime = [[BDSCache sharedCache] diskExpiredTime];
    if (!expiredDiskTime==0) {  //设置过期时间默认 则请理
        [BDSCache cleanFileCache];
    }
}

//清除整个文件存储
+(void)removeAll
{
//    BDSLog(@"removeAll");
    
    //防止进入后台清理磁盘
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    BDSConfig* config = [[BDSConfig alloc] initWithNameSpace:BDSAllCacheNameSpace];
    NSArray* array = [config arrayForKey:BDSAllCacheNameSpace];
    //finnalArr用来存储更新后的所有缓存的namesapce
    NSMutableArray* finnalArr = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString* nameSpace in array)
    {
        NSError* error = nil;
        [BDSStorage cleanNameSpace:nameSpace error:&error];
    }
    [config setObject:finnalArr forKey:BDSAllCacheNameSpace];
    //将通知加回来
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    BDSLog(@"removeAll end");
}

//清除某个namespace的缓存
+(void)removeNameSpace:(NSString*)nameSpace
{
//    BDSLog(@"removeNameSpace");
    
//    BDSConfig* config = [[BDSConfig alloc] initWithNameSpace:BDSAllCacheNameSpace];
//    NSArray* array = [config arrayForKey:BDSAllCacheNameSpace];
//    //finnalArr用来存储更新后的所有缓存的namesapce
//    NSMutableArray* finnalArr = [[NSMutableArray alloc] initWithCapacity:array.count];
//    for (NSString* nameSpaceInner in array)
//    {
//        if ([nameSpaceInner isEqualToString:nameSpace]) {
//            NSError* error = nil;
//            [BDSStorage cleanNameSpace:nameSpaceInner error:&error];
//        }
//        else
//        {
//            [finnalArr addObject:nameSpace];
//        }
//    }
//    [config setObject:finnalArr forKey:BDSAllCacheNameSpace];
    NSError* error = nil;
    [BDSStorage cleanNameSpace:nameSpace error:&error];
    
//    BDSLog(@"removeNameSpace end");
}

//将namesapece加入总namespace
+ (void)addNameSpaceToAllCache:(NSString*)nameSpace
{
//    BDSLog(@"addNameSpaceToAllCache");
    
    BDSConfig* config = [[BDSConfig alloc] initWithNameSpace:BDSAllCacheNameSpace];
    
    NSArray* array = [config arrayForKey:BDSAllCacheNameSpace];
    if (!array) {
        array = [[NSArray alloc] init];
    }
    //是否存在 不存在就加入
    BOOL bHasThisNameSpace = NO;
    for (NSString* item in array) {
        if ([item isEqualToString:nameSpace]) {
            bHasThisNameSpace = YES;
            break;
        }
    }
    if (!bHasThisNameSpace) {
        NSMutableArray* setArray = [[NSMutableArray alloc] initWithArray:array];
        [setArray addObject:nameSpace];
        [config setObject:setArray forKey:BDSAllCacheNameSpace];
        
    }
//    BDSLog(@"addNameSpaceToAllCache");
    
}

#pragma mark - 实例方法

- (id)initWithNameSpace:(NSString*)nameSpace storagePolicy:(BDSCachePolicy )policy;
{
//    BDSLog(@"initWithNameSpace");
    self = [super init];
    if (self) {
        _cacheStoragePolicy = policy;
        self.fileStorag = [[BDSStorage alloc]initWithNameSpace:nameSpace];
        self.memoryStorag = [[BDSMemoryStorage alloc]initWithNameSpace:nameSpace];
        self.config = [[BDSConfig alloc] initWithNameSpace:nameSpace];
        _nameSpace = [nameSpace copy];
        [BDSCache addNameSpaceToAllCache:nameSpace];
        self.configDict = [[NSMutableDictionary alloc] initWithCapacity:4];
        NSDictionary* configDictory = [self.config dictionaryForKey:BDSCacheConfigKey];
        NSNumber* memoryCapacity = [configDictory numberAtPath:BDSCacheConfigMemoryCapacity otherwise:[NSNumber numberWithUnsignedInteger:100]];
        self.memoryCapacity = memoryCapacity.unsignedIntegerValue;
        //只是物理存储配置 并且 不是第一次执行
        if (configDictory && policy != BDSCStorageMemory ) {
            
            
        }else{
            [self innerSavePolicy:policy];   //缓存策略
            [self.config setObject:self.configDict forKey:BDSCacheConfigKey];
        }
        
    }
//    BDSLog(@"initWithNameSpace end");
    return self;
}

//设置过期时间
- (void)setDiskExpiredTime:(NSUInteger)value
{
    if (self.cacheStoragePolicy == BDSCStorageMemory) {
        return;
    }
    [self.configDict setObject:[NSNumber numberWithUnsignedInteger:value] forKey:BDSCacheConfigDiskExpiredTime];
    [self.config setObject:self.configDict forKey:BDSCacheConfigKey];
}
//获取过期时间
-(NSUInteger)getDiskExpiredTime
{
    NSNumber* number = [self.configDict objectForKey:BDSCacheConfigDiskExpiredTime];
    return number.unsignedIntegerValue;
}
//设置缓存策略
- (void)innerSavePolicy:(int)policy
{
    if (self.cacheStoragePolicy == BDSCStorageMemory) {
        return;
    }
    [self.configDict setObject:[NSNumber  numberWithInt:policy] forKey:BDSCacheConfigKey];
}
//设置缓存的个数
- (void)setMemoryCapacity:(NSUInteger)value
{
    self.memoryStorag.memoryCapacity = value;
    [self.configDict setObject:[NSNumber numberWithUnsignedInteger:value] forKey:BDSCacheConfigMemoryCapacity];
    [self.config setObject:self.configDict forKey:BDSCacheConfigKey];
}
//设置缓存的存储大小
- (void)setMemoryTotalCost:(NSUInteger)memoryTotalCost
{
    self.memoryStorag.memoryTotalCost = memoryTotalCost;
}

//该对象是否存在
-(BOOL)existCacheForKey:(NSString*)key
{
    if ([self existCacheForKeyInMemory:key]) {
        return YES;
    }
    return [self existCacheForKeyOnDisk:key];
}
//在内存中是否存在
-(BOOL)existCacheForKeyInMemory:(NSString *)key
{
//    BDSLog(@"existCacheForKeyInMemory");
    if (self.cacheStoragePolicy  == BDSCStorageDisk) {
        return NO;
    }
    return [self.memoryStorag existObjectForKey:key];
}

//在文件中是否存在
-(BOOL)existCacheForKeyOnDisk:(NSString *)key
{
//    BDSLog(@"existCacheForKeyOnDisk");
    if (self.cacheStoragePolicy  == BDSCStorageMemory) {
        return NO;
    }
    return [self.fileStorag isObjectForKeyExist:key];
}


//存数据  异步
-(void)setObjAsync:(id)data forKey:(NSString *)aKey
{
    if (data == nil || aKey == nil) {
        return;
    }
    if (self.cacheStoragePolicy == BDSCStorageMemory || self.cacheStoragePolicy == BDSCStorageMemoryAndDisk)
    {
//        BDSLog(@"save me");
        [self.memoryStorag saveObject:data forKey:aKey];
    }
    if (self.cacheStoragePolicy == BDSCStorageDisk || self.cacheStoragePolicy == BDSCStorageMemoryAndDisk)
    {
//        BDSLog(@"save disk");
        [self saveInner:data forKey:aKey];
    }
}

//存数据  同步
-(BOOL)setObj:(id)data forKey:(NSString *)aKey
{
    if (data == nil || aKey == nil) {
        return NO;
    }
    
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk) {
        
        [self.memoryStorag saveObject:data forKey:aKey];
        
        BOOL isSave = [self saveInnerSync:data forKey:aKey];
        
        return isSave;
    }else if(self.cacheStoragePolicy == BDSCStorageMemory) {

        [self.memoryStorag saveObject:data forKey:aKey];
        
        return YES;
    }else if(self.cacheStoragePolicy == BDSCStorageDisk) {
        
        return [self saveInnerSync:data forKey:aKey];
    }else{
        return NO;
    }
    
}

//存数据
-(BOOL)setObj:(id)data forKey:(NSString *)aKey cost:(NSInteger)cost
{
    if (data == nil || aKey == nil) {
        return NO;
    }
    
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk) {
        
        [self.memoryStorag saveObject:data forKey:aKey cost:cost];
        
        BOOL isSave = [self saveInnerSync:data forKey:aKey];
        
        return isSave;
    }else if(self.cacheStoragePolicy == BDSCStorageMemory) {

        [self.memoryStorag saveObject:data forKey:aKey cost:cost];
        
        return YES;
    }else if(self.cacheStoragePolicy == BDSCStorageDisk) {
        
        return [self saveInnerSync:data forKey:aKey];
    }else{
        return NO;
    }

}

//根据数据的类型存储数据  异步
-(void)saveInner:(id)data forKey:(NSString*)aKey
{
    if([data isKindOfClass:[NSData class]] )
    {
        [self.fileStorag saveData:data forKey:aKey completionHandle:nil];
    }
    else if ([data isKindOfClass:[NSString class]])
    {
        [self.fileStorag saveString:data forKey:aKey completionHandle:nil];
    }
    else if([data isKindOfClass:[NSArray class]])
    {
        [self.fileStorag saveArray:data forKey:aKey completionHandle:nil];
    }
    else if([data isKindOfClass:[NSDictionary class]])
    {
        [self.fileStorag saveDictionary:data forKey:aKey completionHandle:nil];
    }
    else if ([data conformsToProtocol:@protocol(NSCoding)])
    {
        [self.fileStorag saveCodingObject:data forKey:aKey completionHandle:nil];
    }
    else
    {
        NSException* exception = [NSException
                                  exceptionWithName:@"BDS_WF"
                                  reason:@"can't save this type of obj"
                                  userInfo:nil];
        [exception raise];
        
    }
}

//根据数据的类型存储数据  同步
-(BOOL)saveInnerSync:(id)data forKey:(NSString *)akey
{
    if ([data isKindOfClass:[NSData class]]) {
       return [self.fileStorag saveData:data forKey:akey error:nil];
    }
    else if ([data isKindOfClass:[NSString class]])
    {
       return [self.fileStorag saveString:data forKey:akey error:nil];
    }
    else if ([data isKindOfClass:[NSArray class]])
    {
       return [self.fileStorag saveArray:data forKey:akey error:nil];
    }
    else if ([data isKindOfClass:[NSDictionary class]])
    {
       return [self.fileStorag saveDictionary:data forKey:akey error:nil];
    }
    else if ([data conformsToProtocol:@protocol(NSCoding)])
    {
        return [self.fileStorag saveCodingObject:data forKey:akey error:nil];
    }
    else
    {
        NSException* exception = [NSException
                                  exceptionWithName:@"BDS_WF"
                                  reason:@"can't save this type of obj"
                                  userInfo:nil];
        [exception raise];
        
        return NO;
    }
}



//获取数据  同步
-(id)objectForKey:(NSString*)key
{
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk)
    {
        id objRet = [self.memoryStorag loadObjectForKey:key];
        if (!objRet) {
            NSError* error = nil;
            objRet = [self.fileStorag objectForKey:key error:&error];
            if (objRet) {
                [self.memoryStorag saveObject:objRet forKey:key];
            }
        }
        return objRet;
    }
    else if(self.cacheStoragePolicy == BDSCStorageDisk)
    {
        NSError* error = nil;
        id objRet = [self.fileStorag objectForKey:key error:&error];
        return objRet;
    }
    else
    {
        return [self.memoryStorag loadObjectForKey:key];
    }
}

//只从内存中获取数据
-(id)objectForKeyOnlyInMemory:(NSString*)key
{
//    BDSLog(@"objectForKeyOnlyInMemory");
    if(self.cacheStoragePolicy == BDSCStorageDisk)
    {
        return nil;
    }
    id obj = [self.memoryStorag loadObjectForKey:key];
    return obj;
}

//异步获取数据
-(void)objectForKey:(NSString *)key  completionHandle:(void(^)(BOOL success,id obj))completionHandler
{
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk)
    {
        id objRet = [self.memoryStorag loadObjectForKey:key];
        
        if (!objRet) {
            [self.fileStorag objectForKey:key completionHandle:^(BOOL success, NSError *error, id obj) {
                if(obj)
                {
                    [self.memoryStorag saveObject:obj forKey:key];
                }
                completionHandler(success,obj);
            }];
        }
        else
        {
            completionHandler(YES,objRet);
        }
    }
    
    else if(self.cacheStoragePolicy == BDSCStorageDisk)
    {
        [self.fileStorag objectForKey:key completionHandle:^(BOOL success, NSError *error, id obj) {
            completionHandler(success,obj);
        }];
    }
    else
    {
        //只是内存缓存就同步完成
        id objRet = [self.memoryStorag loadObjectForKey:key];
        if (objRet) {
            completionHandler(YES,objRet);
        }
        else
        {
            completionHandler(NO,nil);
        }
    }
}

//同步删除
-(void)removeObjcetForKey:(NSString*)key
{
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageMemory)
    {
        [self.memoryStorag removeObjectForKey:key];
    }
    if(self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageDisk)
    {
        [self.fileStorag removeObjectForKey:key completionHandle:nil];
        NSError * err = nil;
        [self.fileStorag removeDataForKey:key error:&err];
//        BDSLog(@"删除同步删除err==%@",err);
    }
}
//异步删除
-(void)removeObjectAsyncForKey:(NSString *)key
{
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageMemory)
    {
        [self.memoryStorag removeObjectForKey:key];
    }
    if(self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageDisk)
    {
        [self.fileStorag removeObjectForKey:key completionHandle:nil];
    }
    
}

//内存缓存移去
-(void)removeObjcetForKeyOnlyInMemory:(NSString*)key
{
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageMemory)
    {
        [self.memoryStorag removeObjectForKey:key];
    }
}
//
-(void)removeAll
{
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageMemory)
    {
        [self.memoryStorag removeAll];
    }
    if(self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageDisk)
    {
        [BDSStorage cleanNameSpace:_nameSpace completionHandle:nil];
    }
    
}

//清除所有（内存）
-(void)removeAllInMemory
{
    if (self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageMemory)
    {
        [self.memoryStorag removeAll];
    }
}

//清除所有（内存和磁盘）
-(void)removeAllInDisk
{
    if(self.cacheStoragePolicy == BDSCStorageMemoryAndDisk || self.cacheStoragePolicy == BDSCStorageDisk)
    {
        [BDSStorage cleanNameSpace:_nameSpace completionHandle:nil];
    }
}


//通过命名空间获得文件总大小
+(double)sizeWithStoreageNameSpace:(NSString *)nameSpace{
    
    NSString *fullPath = [self storagePathNameSpace:nameSpace];
    
    return [self sizeWithFilePath:fullPath];
}
//所有命名空间的文件的大小
+(double)sizeForAllNameSpace
{
    BDSConfig* config = [[BDSConfig alloc] initWithNameSpace:BDSAllCacheNameSpace];
    NSArray* array = [config arrayForKey:BDSAllCacheNameSpace];
    double totoalSize = 0.0f;
    //finnalArr用来存储更新后的所有缓存的namesapce
    for (NSString* nameSpaceInner in array)
    {
        double size = [self sizeWithStoreageNameSpace:nameSpaceInner];
        totoalSize += size;
    }
    return totoalSize;
}



//path 文件夹的路径
+ (double)sizeWithFilePath:(NSString *)path
{

    // 1.获得文件夹管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 2.检测路径的合理性
    BOOL dir = NO;
    BOOL exits = [mgr fileExistsAtPath:path isDirectory:&dir];
    if (!exits) return 0;
    
    // 3.判断是否为文件夹
    if (dir) { // 文件夹, 遍历文件夹里面的所有文件
        // 这个方法能获得这个文件夹下面的所有子路径(直接\间接子路径)
        NSArray *subpaths = [mgr subpathsAtPath:path];
        int totalSize = 0;
        for (NSString *subpath in subpaths) {
            NSString *fullsubpath = [path stringByAppendingPathComponent:subpath];
            
            BOOL dir = NO;
            [mgr fileExistsAtPath:fullsubpath isDirectory:&dir];
            if (!dir) { // 子路径是个文件
                NSDictionary *attrs = [mgr attributesOfItemAtPath:fullsubpath error:nil];
                totalSize += [attrs[NSFileSize] intValue];
            }
        }
        return totalSize / (1024 * 1024.0);
    } else { // 文件
        NSDictionary *attrs = [mgr attributesOfItemAtPath:path error:nil];
        return [attrs[NSFileSize] intValue] / (1024 * 1024.0);
    }
}

//获取该命名空间的地址
+(NSString *)storagePathNameSpace:(NSString *)nameSpace{
    
    return [BDSStorage getStoragePath:nameSpace];
}

//获取该命名空间的地址
-(NSString *)storagePathNameSpace
{
    return [BDSStorage getStoragePath:_nameSpace];
}

//获取文件的完整文件路径
-(NSString*)getStorageFullPathForKey:(NSString*)key
{
    return [self.fileStorag getStorageFullPathForKey:key];
}

//获取文件的完整文件路径 老的地址
-(NSString *)getStorageOldVersionFullPathForKey:(NSString *)key{
    return [self.fileStorag getStorageFullPathForKeyWithOldVersion:key];
}


-(void)dealloc{
    
    NSLog(@"缓存模块释放...========");
}




@end







