//
//  NRSqliteManager.h
//  Nourish
//
//  Created by tcguo on 15/9/29.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define dataBasePath [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)) lastObject]stringByAppendingPathComponent:dataBaseName]
#define dataBaseName @"nourishDataBase.sqlite"

@interface NRSqliteManager : NSObject

+ (instancetype)shareManager;

@end
