//
//  NSString+BDSExtension.h
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (BDSExtension)

//
- (NSString *)URLEncoding;

//url编码成utf-8 str
- (NSString *)UTF8Encoding;

//url解码成unicode str
- (NSString *)URLDecoding;

//计算md5
- (NSString *)MD5;

//转换成data
- (NSData *)UTF8Data;

//去前后空格
-(NSString *)trim;

/*去除左右空格*/
- (NSString *)trimLeftAndRightWhitespace;
@end
