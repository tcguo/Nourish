//
//  NRRecordDinnerCell.h
//  Nourish
//
//  Created by gtc on 15/2/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRRecordDetailModel.h"

@interface NRRecordDinnerCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgv;
@property (nonatomic, strong) UIScrollView *scrollView;

@property(retain, nonatomic) NRRecordDetailModel *model;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier subTableTag:(NSInteger)tag;
- (void)addViews;
- (void)removeViews;

@end
