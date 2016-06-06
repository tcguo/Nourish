//
//  NRChangeOrderCalendarView.m
//  Nourish

//  订单变更日历

//  Created by gtc on 15/7/13.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRChangeOrderCalendarView.h"
#import "DSLChangeOrderCalendarView.h"
#import "UIView+BDSExtension.h"

@interface NRChangeOrderCalendarView ()<DSLChangeOrderCalendarViewDelegate>
{
    UIView *_containerView;
    UILabel *_tipsLabel;
    UILabel *_titleLabel;
    NSArray *_arrNewOrderDates;
    CGFloat _heightOfCalendarView;
}

@property (nonatomic, strong) DSLChangeOrderCalendarView *calendarView;
@property (nonatomic, strong) NSMutableSet *msetAavliableDates; //未分组的8个周的所有工作日
@property (nonatomic, strong) NSMutableSet *msetNewOrderAllDates; //已经吃过的天+变更的天
@property (nonatomic, strong) NSArray *arrNewOrderDates; //排序后的 已经吃过的天+变更的天
@property (nonatomic, strong) NSArray *arrOrderChangeDates; //变更的日期
@property (nonatomic, retain) UIActivityIndicatorView *act; //指示器
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelChangeButton;

//session
@property (nonatomic, weak) NSURLSessionDataTask *workdaysTask;
@property (nonatomic, weak) NSURLSessionDataTask *changeTask;
@end

@implementation NRChangeOrderCalendarView

- (id)init {
    self = [super init];
    if (self) {
        _heightOfCalendarView = 350*kAppUIScaleY;
        _msetAavliableDates = [NSMutableSet set];
    }
    
    return self;
}

- (void)setupUI {
    [super setupUI];
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor =  RgbHex2UIColor(0x16, 0xd4, 0x98);
    _titleLabel.font = SysBoldFont(15);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"请选择新的开始日期";
    [self.contentView addSubview:_titleLabel];
    [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.height.equalTo(@27);
        make.left.and.right.equalTo(0);
    }];
    self.contentView.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 27, self.bounds.size.width, _heightOfCalendarView)];
    _containerView.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
    [self.contentView addSubview:_containerView];
    
    //变更周期提示
    _tipsLabel = [UILabel new];
    _tipsLabel.textColor = ColorRed_Normal;
    _tipsLabel.font = SysFont(16);
    [self.contentView addSubview:_tipsLabel];
    [_tipsLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(_containerView.mas_bottom).offset(10);
        make.height.equalTo(@17);
    }];
    
    //确认和取消
    [self.contentView addSubview:self.cancelChangeButton];
    [self.cancelChangeButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(-1);
        make.height.equalTo(50);
        make.width.equalTo(SCREEN_WIDTH/2+1);
    }];
    
    [self.contentView addSubview:self.confirmButton];
    [self.confirmButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.right.equalTo(1);
        make.height.equalTo(50);
        make.width.equalTo(SCREEN_WIDTH/2+1);
    }];
    
    self.act = [[UIActivityIndicatorView  alloc] initWithFrame:CGRectMake((self.contentView.bounds.size.width-50)/2, (self.contentView.bounds.size.height-50)/2, 50, 50)];
    self.act.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.act.hidesWhenStopped = YES;
    [self.act startAnimating];
    [self.contentView addSubview:self.act];
}

#pragma mark - action
- (void)getWorkdays {
    NSString *dateNow = [NSDate stringFromDate:[NSDate date] format:nil];
    NSDictionary *dicParams = @{ @"dateNow": dateNow};
    
    WeakSelf(self);
    [[self.viewModel fetchOrderWorkdaysWithParametres:dicParams] subscribeNext:^(id res) {
        [weakSelf.msetAavliableDates removeAllObjects]; //移除所有
        NSArray *arrWeekGroup = [res valueForKey:@"workWeekGroup"];
        for (NSDictionary *dic in arrWeekGroup) {
            NSArray *workdays = [dic valueForKey:@"workdays"];
            [weakSelf.msetAavliableDates addObjectsFromArray:workdays];
        }
        
        weakSelf.calendarView = [[DSLChangeOrderCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, _heightOfCalendarView) orderDates:weakSelf.msetOrderDates avaliableDate:self.msetAavliableDates];
        weakSelf.calendarView.delegate = weakSelf;
        weakSelf.calendarView.backgroundColor = RgbHex2UIColor(0x16, 0xd4, 0x98);
        [_containerView addSubview:weakSelf.calendarView];
    } error:^(NSError *error) {
        [weakSelf.viewController performSelector:@selector(processRequestError:) withObject:error];
    } completed:^{
        [weakSelf.act stopAnimating];
    }];
}

- (void)requestChangeOrder {
    if (self.changeCmd) {
        [self.changeCmd execute:self.arrOrderChangeDates];
    }
}

- (void)tappedCancel {
    [self dismiss];
}

#pragma mark - Property
- (void)setMsetOrderDates:(NSMutableSet *)msetOrderDates {
    _msetOrderDates = msetOrderDates;
    [self displayNewDates:msetOrderDates];
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.layer.borderColor = RgbHex2UIColor(0x58, 0xF1, 0xb6).CGColor;
        _confirmButton.layer.borderWidth = SCREEN_SCALE;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton addTarget:self action:@selector(requestChangeOrder) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _confirmButton;
}

- (UIButton *)cancelChangeButton {
    if (!_cancelChangeButton) {
        _cancelChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelChangeButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelChangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelChangeButton.layer.borderColor = RgbHex2UIColor(0x58, 0xF1, 0xb6).CGColor;
        _cancelChangeButton.layer.borderWidth = SCREEN_SCALE;
        _cancelChangeButton.layer.masksToBounds = YES;
        [_cancelChangeButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelChangeButton;
}

#pragma mark -  DSLChangeOrderCalendarViewDelegate
- (void)calendarView:(DSLChangeOrderCalendarView*)calendarView didSelectDates:(NSMutableSet*)newDates {
    if (newDates == nil) {
        [MBProgressHUD showTips:self text:@"当前日期长度不满足变更长度"];
    }
    else
        [self displayNewDates:newDates];
}

#pragma mark - Helper
- (void)displayNewDates:(NSSet *)newDates {
    // 变更后的日期+已吃过的日期
    self.msetNewOrderAllDates = [NSMutableSet setWithSet:self.msetOrderDates];
    [self.msetNewOrderAllDates minusSet:self.calendarView.msetAvaliableDateInOrderDates];
    [self.msetNewOrderAllDates unionSet:newDates];
    
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    self.arrNewOrderDates  = [self.msetNewOrderAllDates.allObjects sortedArrayUsingDescriptors:sortDesc];
    self.arrOrderChangeDates = [newDates.allObjects sortedArrayUsingDescriptors:sortDesc];
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    //    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"MM月d日";
    
    NSDate *startDate = [NSDate dateFromString:_arrNewOrderDates.firstObject format:nil];
    NSDate *endDate = [NSDate dateFromString:_arrNewOrderDates.lastObject format:nil];
    
    NSMutableString *dateString = [NSMutableString stringWithString:@""];
    [dateString appendString:[fmt stringForObjectValue:startDate]];
    [dateString appendString:@"---"];
    [dateString appendString:[fmt stringForObjectValue:endDate]];
    
    _tipsLabel.text = [NSString stringWithFormat:@"周期变更为:%@", dateString];
}

@end
