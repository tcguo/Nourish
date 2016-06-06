//
//  NRWeekPlanCommentViewController.h
//  Nourish
//
//  Created by tcguo on 15/11/3.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NROrderInfoModel.h"
#import "NROrderListViewController.h"

@interface NRWeekPlanCommentViewController : NRBaseViewController

- (id)initWithOrderInfo:(NROrderInfoModel *)orderInfo;

@property (strong, nonatomic) RACCommand *refreshCmd;
@end
