//
//  NRAreaTableTool.m
//  Nourish
//
//  Created by gtc on 15/4/21.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAreaTableTool.h"
#import <sqlite3.h>

#define DBNAME    @"areainfo.sqlite"
#define TABLENAME @"AREAS"

#define fID       @"ID"
#define fLevel    @"level"
#define fName     @"name"
#define fParentID @"parentID"
#define fEnable   @"enable"

static sqlite3 *_db;

@implementation NRAreaTableTool

//首先需要有数据库
+ (void)initialize
{
     //获得数据库文件的路径
     NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     NSString *fileName = [doc stringByAppendingPathComponent:@"areainfo.sqlite"];
     
     //将OC字符串转换为c语言的字符串
     const char *cfileName = fileName.UTF8String;
     
     //1.打开数据库文件（如果数据库文件不存在，那么该函数会自动创建数据库文件）
     int result = sqlite3_open(cfileName, &_db);
     if (result == SQLITE_OK) {        //打开成功
         NSLog(@"成功打开数据库");
         
         NSString *strSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ integer PRIMARY KEY, %@ integer NOT NULL, %@ text NOT NULL, %@ integer NOT NULL, %@ integer NOT NULL)",TABLENAME, fID, fLevel, fName, fParentID,fEnable];
         
         //2.创建表
         const char  *sql= strSql.UTF8String;
         
         char *errmsg=NULL;
         result = sqlite3_exec(_db, sql, NULL, NULL, &errmsg);
         if (result==SQLITE_OK) {
             NSLog(@"创表成功");
         }else
         {
             printf("创表失败---%s",errmsg);
         }
     }
     else {
         NSLog(@"打开数据库失败");
     }

}

+(void)openDB
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"areainfo.sqlite"];
    
    //将OC字符串转换为c语言的字符串
    const char *cfileName = fileName.UTF8String;
    
    //1.打开数据库文件（如果数据库文件不存在，那么该函数会自动创建数据库文件）
    int result = sqlite3_open(cfileName, &_db);
    if (result == SQLITE_OK) {        //打开成功
        
    }
    
}

+ (void)add:(NRAreaModel *)mod
{
    //1.拼接SQL语句
    NSMutableString *msql = [NSMutableString new];
    [msql appendFormat:@"INSERT INTO %@ (ID,level,name,parentID, enable)",TABLENAME];
    [msql appendFormat:@"VALUES (%d, %d, '%@', %d, %d)", mod.ID, mod.level, mod.name, mod.parentID, mod.enable];
    
    
    //2.执行SQL语句
    char *errmsg = NULL;
    sqlite3_exec(_db, msql.UTF8String, NULL, NULL, &errmsg);
    
    if (errmsg) {//如果有错误信息
         NSLog(@"插入数据失败--%s",errmsg);
    }
    else {
       NSLog(@"插入数据成功");
    }
}

+ (BOOL)update:(NRAreaModel *)mod
{
    sqlite3_stmt *stmt = nil;
    
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set enable = %d where ID = %d",TABLENAME, mod.enable, mod.ID];
    
    int result = sqlite3_prepare_v2(_db, [sqlStr UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {//觉的应加一个判断, 若有这一行则修改
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                sqlite3_finalize(stmt);
                return YES;
            }
        }
    }
    
    sqlite3_finalize(stmt);
    return NO;
}

//删除一个
+ (BOOL)deleteByid:(NSInteger)ID
{
    sqlite3_stmt *stmt = nil;
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where ID = %d", TABLENAME, ID];
    
    int result = sqlite3_prepare_v2(_db, [sqlStr UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {	//觉的应加一个判断, 若有这一行则删除
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                sqlite3_finalize(stmt);
                return YES;
            }
        }
    }
    
    sqlite3_finalize(stmt);
    return NO;
}

+ (BOOL)deleteAll
{
    sqlite3_stmt *stmt = nil;
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@", TABLENAME];
    
    int result = sqlite3_prepare_v2(_db, [sqlStr UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {	//觉的应加一个判断, 若有这一行则删除
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                sqlite3_finalize(stmt);
                return YES;
            }
        }
    }
    
    sqlite3_finalize(stmt);
    return NO;
}

+ (NSDictionary *)queryByParentID:(NSInteger)parentId andLevel:(NSInteger)level;
{
    //打开数据库
    
    //数据库操作指针 stmt:statement
    sqlite3_stmt *stmt = nil;
    
    //验证SQL的正确性 参数1: 数据库指针, 参数2: SQL语句, 参数3: SQL语句的长度 -1代表无限长(会自动匹配长度), 参数4: 返回数据库操作指针, 参数5: 为未来做准备的, 预留参数, 一般写成NULL
    NSString *strSql  = nil;
    if (parentId  == 0) {
         strSql = [NSString stringWithFormat:@"select * from %@ where level = %d", TABLENAME, level];
    }
    else
        strSql = [NSString stringWithFormat:@"select * from %@ where parentID = %d and level = %d", TABLENAME, parentId, level];
    
    
    int result = sqlite3_prepare_v2(_db, strSql.UTF8String, -1, &stmt, NULL);
    NSMutableDictionary *mdicAreas = [NSMutableDictionary dictionary];
    
    //判断SQL执行的结果
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {//存在一行数据
            //列数从0开始
            int ID = sqlite3_column_int(stmt, 0);
            int level = sqlite3_column_int(stmt, 1);
            const unsigned char *name = sqlite3_column_text(stmt, 2);
            int parentID = sqlite3_column_int(stmt, 3);
            int enable = sqlite3_column_int(stmt, 4);
            
            //封装Student模型
            NRAreaModel *model = [[NRAreaModel alloc] init];
            model.ID = ID;
            model.level = level;
            model.name = [NSString stringWithUTF8String:(const char *)name];
            model.parentID = parentID;
            model.enable = enable;
            
            //添加到数组
            [mdicAreas setObject:model forKey:[NSString stringWithFormat:@"%d", model.ID]];
        }
    }
    //释放stmt指针
    sqlite3_finalize(stmt);
    //关闭数据库
    return mdicAreas;
    
}

+ (void)closeDB
{
    sqlite3_close(_db);
    _db = nil;
}


@end
