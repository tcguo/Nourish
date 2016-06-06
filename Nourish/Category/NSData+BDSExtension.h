//
//  NSData+BDSExtension.h
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>



#define BDSDateFormatter01 @"yyyy-MM-dd HH:mm:ss"
#define BDSDateFormatter02 @"yyyy-MM-dd HH:mm"
#define BDSDateFormatter03 @"yyyy-MM-dd HH"
#define BDSDateFormatter04 @"yyyy-MM-dd"
#define BDSDateFormatter05 @"yyyy-MM"
#define BDSDateFormatter06 @"MM-dd"
#define BDSDateFormatter07 @"HH:mm"
#define BDSDateFormatter08 @"MM-dd HH:mm"

@interface NSData (BDSExtension)

- (NSString *)UTF8String;
-(NSArray*)array;
-(NSDictionary*)dictionary;
@end
