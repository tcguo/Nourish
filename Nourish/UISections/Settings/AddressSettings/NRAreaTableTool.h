//
//  NRAreaTableTool.h
//  Nourish
//
//  Created by gtc on 15/4/21.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRAreaModel.h"

@interface NRAreaTableTool : NSObject

+ (void)add:(NRAreaModel *)mod;
+ (NSDictionary *)queryByParentID:(NSInteger)parentId andLevel:(NSInteger)level;
+ (BOOL)update:(NRAreaModel *)mod;
+ (BOOL)deleteByid:(NSInteger)ID;
+ (BOOL)deleteAll;
+ (void)closeDB;
+ (void)openDB;

@end
