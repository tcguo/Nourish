//
//  NRRecordViewController.h
//  Nourish
//
//  Created by gtc on 14/12/26.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRBaseViewController.h"

#import "HVTableView.h"
#import "HRTableViewCell.h"
#import "NRRecordDinnerCell.h"

#import "NRUserInfoModel.h"
#import "NRRecordDayInfo.h"
#import "NRRecordDetailModel.h"
#import "NREnergyElementModel.h"

@interface NRRecordTableViewController : NRBaseViewController<HVTableViewDelegate, HVTableViewDataSource>

@property (strong, nonatomic) HVTableView *tableView;

@end

