//
//  NSString+Validation.h
//  Nourish
//
//  Created by tcguo on 15/10/14.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

- (BOOL)isEmail;
- (BOOL)isPhoneNum;
- (BOOL)isQQ;
- (BOOL)isNickName;
- (BOOL)isPassWord;
- (int)getCharLength;

@end
