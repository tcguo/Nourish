//
//  NRSqliteManager.m
//  Nourish
//
//  Created by tcguo on 15/9/29.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSqliteManager.h"
#import "FMDatabase.h"

static NRSqliteManager *manager = nil;
static FMDatabase *shareDataBase = nil;

@implementation NRSqliteManager

+ (instancetype)shareManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[NRSqliteManager alloc] init];
        }
    });
    
    return manager;
}

- (FMDatabase *)createDatabase {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDataBase = [FMDatabase databaseWithPath:dataBasePath];
    });
    
    return shareDataBase;
}

- (void)closeDatabase {
    
    if(![shareDataBase close]) {
        NSLog(@"数据库关闭异常，请检查");
        return;
    }
}

- (BOOL)isTableExist:(NSString *)tableName {
    
    FMResultSet *rs = [shareDataBase executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        
        return count == 0 ? NO : YES;
    }
    
    return NO;
}

- (BOOL)createTable {
    
    shareDataBase = [[NRSqliteManager shareManager] createDatabase];
    if ([shareDataBase open]) {
        if (![self isTableExist:@"message_table"]) {
            NSString *sql = @"CREATE TABLE \"message_table\" (\"message_id\" TEXT PRIMARY KEY  NOT NULL  check(typeof(\"message_id\") = 'text') , \"att\" BLOB)";
            NSLog(@"no Medicine ");
            [shareDataBase executeUpdate:sql];
        }
        [shareDataBase close];
    }
    
    return YES;
}

- (BOOL) saveOrUpdataMessage:(NSObject *)message {
    
    BOOL isOk = NO;
    shareDataBase = [self createDatabase];
    if ([shareDataBase open]) {
        isOk = [shareDataBase executeUpdate: @"INSERT INTO \"message_table\" (\"message_id\",\"att\") VALUES(?,?)"];
        [shareDataBase close];
    }
    return isOk;
}

- (NSObject *) selectMessageByMessageId:(NSString*)messageId {
    
    NSObject *m = nil;
    shareDataBase = [self createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM \"message_table\" WHERE \"message_id\" = '%@'",messageId]];
        
        while ([resultSet next]) {
            
        }
        
        [shareDataBase close];
    }
    return m;
}

@end
