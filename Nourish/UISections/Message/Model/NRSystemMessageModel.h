//
//  NRSystemMessageModel.h
//  Nourish
//  诺食消息-系统消息Model
//  Created by gtc on 15/7/30.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NRMsgType) {
    NRMsgTypeAll,
    NRMsgTypeSystem,
};

@interface NRSystemMessageModel : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *coverImageUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, assign) NRMsgType msgType;
@end
