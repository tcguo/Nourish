//
//  NROrderCommentController.h
//  Nourish

//  每日套餐评论

//  Created by gtc on 15/3/17.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"

@interface NROrderCommentController : NRBaseViewController

- (instancetype)initWithDate:(NSString *)date;

@property (nonatomic, readonly, strong) UITableView *tableview;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) RACCommand *refreshCmd;

@end
