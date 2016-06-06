//
//  NRAddAddressController.h
//  Nourish
//
//  Created by gtc on 15/3/6.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseTableViewController.h"
#import "NRDistributionAddrModel.h"

typedef NS_ENUM(NSUInteger, AddrOperateType) {
    AddrOperateTypeAdd,
    AddrOperateTypeEdit,
};

@protocol AddAddressDelegate <NSObject>
@optional
- (void)addAddressCompleted;

@end

@interface NRAddAddressController : NRBaseTableViewController

- (id)initWithStyle:(UITableViewStyle)style operateType:(AddrOperateType)type;

@property (nonatomic, assign) id<AddAddressDelegate> delegate;
@property (nonatomic, strong) NRDistributionAddrModel *editModel; //既用于添加也用于修改

@end
