//
//  NRHistoryOrderCell.h
//  Nourish
//
//  Created by gtc on 15/3/25.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NROrderInfoModel.h"

@protocol OrderOperateDelegate <NSObject>

@optional
- (void)showOperateSheetList:(NSIndexPath *)indexPath;
- (void)payForOrder:(NROrderInfoModel *)orderModel;

@end

@interface NRHistoryOrderCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (strong, nonatomic) NSIndexPath *myIndexPath;
@property (weak, nonatomic) NROrderInfoModel *orderModel;
@property (assign, nonatomic) id<OrderOperateDelegate> operateDelegate;

@end

