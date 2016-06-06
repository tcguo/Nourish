//
//  NROrderCurrentJSONModel.h
//  Nourish
//
//  Created by tcguo on 16/3/23.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface NROrderCurrentOrderDateItem : JSONModel

@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) BOOL commented;
@end

@interface NROrderCurrentOrderItem : JSONModel

@property (nonatomic, copy) NSString<Optional> *orderId;
@property (nonatomic, copy) NSString<Optional> *wpName;
@property (nonatomic, assign) BOOL current;
@property (nonatomic, strong) NSArray<NROrderCurrentOrderDateItem *> *dates;

@end

@interface NROrderCurrentJSONModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *dispatchStatus;
@property (nonatomic, strong) NSArray<Optional> *orders;

@end



