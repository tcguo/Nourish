//
//  NRHistoryOrderCell.m
//  Nourish
//
//  Created by gtc on 15/3/25.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRHistoryOrderCell.h"
#import "UIButton+Additions.h"
#import "LPLabel.h"
#import "UIImageView+WebCache.h"

#define BgColorForLine RgbHex2UIColor(0xde, 0xde, 0xde)

@interface NRHistoryOrderCell ()
{
    UIView *operateContentView;
    UIView *_moneyContentView;
    NSDateFormatter *fmt;
}

@property (weak, nonatomic) AppDelegate *appdelegate;

@property (strong, nonatomic) UIImageView *themeImageView;
@property (strong, nonatomic) UILabel *wpNameLabel;
@property (strong, nonatomic) UILabel *orderStatusLabel;

@property (strong, nonatomic) UILabel *cycleDisplayLabel;
@property (strong, nonatomic) UILabel *daysDisplayLabel;
@property (strong, nonatomic) LPLabel *totalAmountLabel;
@property (strong, nonatomic) UILabel *payAmountLabel;
@property (strong, nonatomic) UIButton *operateButton;
@property (strong, nonatomic) UIButton *payButton;

@end

@implementation NRHistoryOrderCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"M.d";
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UIView *upContainerView = [[UIView alloc] init];
        [self.contentView addSubview:upContainerView];
        [upContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(0);
            make.height.equalTo(80);
        }];
        
        self.themeImageView = [[UIImageView alloc] init];
        self.themeImageView.layer.cornerRadius = CornerRadius;
        self.themeImageView.layer.masksToBounds = YES;
        [upContainerView addSubview:self.themeImageView];
        
        int padding = 10;
        [self.themeImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(padding);
            make.left.equalTo(padding);
            make.bottom.equalTo(-padding);
            make.width.equalTo(90);
        }];
        
        [upContainerView addSubview:self.wpNameLabel];
        [self.wpNameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.themeImageView.mas_right).offset(padding/2);
            make.centerY.equalTo(upContainerView.centerY);
        }];
        
        [upContainerView addSubview:self.orderStatusLabel];
        [self.orderStatusLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(-padding);
            make.centerY.equalTo(upContainerView.centerY);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = BgColorForLine ;
        [self.contentView addSubview:lineView];
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(0);
            make.top.equalTo(upContainerView.mas_bottom);
            make.height.equalTo(0.5);
        }];
        
        // 基本信息
        UIView *downContainerView = [[UIView alloc] init];
        [self.contentView addSubview:downContainerView];
        [downContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.and.right.equalTo(0);
            make.height.equalTo(50);
        }];
        
//        downContainerView.backgroundColor = [UIColor yellowColor];
        
        //执行周期
        UIView *cycleContentView = [[UIView alloc] init];
        [downContainerView addSubview:cycleContentView];
        [cycleContentView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.bottom.equalTo(0);
            make.width.equalTo(199/2 * self.appdelegate.autoSizeScaleX);
        }];
        
        self.cycleDisplayLabel = [self createTextLabel];
        [cycleContentView addSubview:self.cycleDisplayLabel];
        [self.cycleDisplayLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cycleContentView.centerX);
            make.top.equalTo(@10);
            make.height.equalTo(@16);
        }];
        
        UIView *cycleTitleLabel = [self createTitleLabel:@"执行周期"];
        [cycleContentView addSubview:cycleTitleLabel];
        [cycleTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cycleContentView.centerX);
            make.top.equalTo(self.cycleDisplayLabel.mas_bottom).offset(@2);
        }];
        UIView *vlineViewOne  = [UIView new];
        vlineViewOne.backgroundColor = BgColorForLine;
        [downContainerView addSubview:vlineViewOne];
        [vlineViewOne makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0.5);
            make.height.equalTo(30);
            make.centerY.equalTo(downContainerView.centerY);
            make.left.equalTo(cycleContentView.mas_right);
        }];
        
        //总天数
        UIView *daysContentView = [[UIView alloc] init];
        [downContainerView addSubview:daysContentView];
        [daysContentView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(0);
            make.left.equalTo(vlineViewOne.mas_right);
            make.width.equalTo(60 * self.appdelegate.autoSizeScaleX);
        }];
        
        self.daysDisplayLabel = [self createTextLabel];
        [daysContentView addSubview:self.daysDisplayLabel];
        [self.daysDisplayLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(daysContentView.centerX);
            make.top.equalTo(@10);
            make.height.equalTo(@16);
        }];
        
        UILabel *daysTitleLabel = [self createTitleLabel:@"总天数"];
        [daysContentView addSubview:daysTitleLabel];
        [daysTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(daysContentView.centerX);
            make.top.equalTo(self.daysDisplayLabel.mas_bottom).offset(@2);
        }];

        UIView *vlineViewTwo  = [UIView new];
        [downContainerView addSubview:vlineViewTwo];
        [vlineViewTwo makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(downContainerView.centerY);
            make.left.equalTo(daysContentView.mas_right);
            make.width.equalTo(@0.5);
            make.height.equalTo(@30);
        }];
        vlineViewTwo.backgroundColor = BgColorForLine;
        
        //总金额
        _moneyContentView = [UIView new];
        [downContainerView addSubview:_moneyContentView];
        [_moneyContentView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(0);
            make.left.equalTo(vlineViewTwo.mas_right);
            make.width.equalTo(199/2 * self.appdelegate.autoSizeScaleX);
        }];

        self.totalAmountLabel = [[LPLabel alloc] init];
        self.totalAmountLabel.font =  SysFont(12);
        self.totalAmountLabel.text = @"￥600";
        self.totalAmountLabel.textColor = RgbHex2UIColor(0xc7, 0xc7, 0xc7);
        self.totalAmountLabel.strikeThroughEnabled = YES;
        self.totalAmountLabel.strikeThroughColor = RgbHex2UIColor(0xc7, 0xc7, 0xc7);
        self.totalAmountLabel.textAlignment = NSTextAlignmentCenter;
        
        [_moneyContentView addSubview:self.totalAmountLabel];
        
        self.payAmountLabel = [self createTextLabel];
        self.payAmountLabel.text = @"￥500";
        self.payAmountLabel.textColor = ColorRed_Normal;
        [_moneyContentView addSubview:self.payAmountLabel];
        
        UILabel *payTitleLabel = [self createTitleLabel:@"价格"];
        [_moneyContentView addSubview:payTitleLabel];
        [payTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_moneyContentView.centerX);
            make.top.equalTo(self.payAmountLabel.mas_bottom).offset(@2);
        }];
        
        UIView *vlineViewThree  = [[UIView alloc] init];
        vlineViewThree.backgroundColor = BgColorForLine;
        [downContainerView addSubview:vlineViewThree];
        [vlineViewThree makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(downContainerView.centerY);
            make.left.equalTo(_moneyContentView.mas_right);
            make.width.equalTo(@0.5);
            make.height.equalTo(@30);
        }];
        
        // 操作
        operateContentView = [[UIView alloc] init];
        [downContainerView addSubview:operateContentView];
        [operateContentView makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.bottom.equalTo(0);
            make.width.equalTo(60 * self.appdelegate.autoSizeScaleX);
        }];
    }
    
    return self;
}

#pragma mark - Property
- (void)setOrderModel:(NROrderInfoModel *)orderModel {
    _orderModel = orderModel;
    
    if ([orderModel.totalPrice compare:orderModel.realPrice] ==  NSOrderedSame) {
        self.totalAmountLabel.text = @"";
        self.payAmountLabel.text = [NSString stringWithFormat:@"￥%ld",(long)[orderModel.realPrice integerValue]];

        [self.payAmountLabel updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(199/4 * self.appdelegate.autoSizeScaleX -25);
            make.top.equalTo(@10);
            make.height.equalTo(@16);
        }];
        
        [self.totalAmountLabel updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.payAmountLabel.mas_left);
            make.bottom.equalTo(self.payAmountLabel.mas_bottom);
//            make.top.equalTo(@10);
            make.height.equalTo(@12);
        }];
    }
    else {
        self.totalAmountLabel.text = [NSString stringWithFormat:@"￥%d",[orderModel.totalPrice intValue]];
        self.payAmountLabel.text =[NSString stringWithFormat:@"￥%d",[orderModel.realPrice intValue]];
        [self.payAmountLabel updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(199/4 * self.appdelegate.autoSizeScaleX);
            make.top.equalTo(@10);
            make.height.equalTo(@16);
        }];
        
        [self.totalAmountLabel updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.payAmountLabel.mas_left);
            make.bottom.equalTo(self.payAmountLabel.mas_bottom);
//            make.top.equalTo(@10);
            make.height.equalTo(@12);
        }];
    }
    
    if (_orderModel.orderstatus == OrderStatusPaying) {
        self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.paying", @"未付款");
//        self.orderStatusLabel.textColor = ColorRed_Normal;
        self.orderStatusLabel.textColor = RgbHex2UIColor(0xff, 0x99, 0x66);
        
        if (self.payButton) {
            [self.payButton removeFromSuperview];
        }
        if (self.operateButton) {
            [self.operateButton removeFromSuperview];
        }
        [operateContentView addSubview:self.payButton];
        [self.payButton updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(56, 30));
            make.center.equalTo(operateContentView);
        }];
    }
    else {
        if (self.operateButton) {
            [self.operateButton removeFromSuperview];
        }
        if (self.payButton) {
            [self.payButton removeFromSuperview];
        }
        [operateContentView addSubview:self.operateButton];
        [self.operateButton updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(operateContentView);
            make.edges.equalTo(0);
        }];
    
        self.orderStatusLabel.textColor = ColorBaseFont;
        switch (orderModel.orderstatus) { 
            case OrderStatusPaying:
                self.orderStatusLabel.text = @"";
                break;
            case OrderStatusPayCompleted:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.paycompleted", @"已确认");
                self.orderStatusLabel.textColor = RgbHex2UIColor(0x66, 0xcc, 0x66);
                break;
            case OrderStatusToRun:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.torun", @"待执行");
                break;
            case OrderStatusRunning:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.running", @"正在执行");
                self.orderStatusLabel.textColor = RgbHex2UIColor(0xff, 0x33, 0x33);
                break;
            case OrderStatusRefunding:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.refunding", @"退款中");
                break;
            case OrderStatusRefunded:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.refunded", @"已退款");
                break;
            case OrderStatusChanging:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.changing", @"变更中");
                break;
            case OrderStatusChangeSuccess:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.changesuccess", @"已变更");
                break;
            case OrderStatusChangeFailure:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.changefailure", @"变更失败");
                break;
            case OrderStatusConfirmFailure:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.confirmfailure", @"确认失败");
                break;
            case OrderStatusToComment:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.tocomment", @"待评价");
                break;
            case OrderStatusDone:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.done", @"订单完成");
                break;
            case OrderStatusCancelled:
            case OrderStatusCancelTimeOut:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.cancelled", @"订单取消");
                break;
            case OrderStatusClosed:
                self.orderStatusLabel.text = NSLocalizedString(@"app.order.status.closed", @"订单关闭");
            default:
                break;
        }
    }
    
    // 周计划名称&图片、日期范围、总天数
    self.wpNameLabel.text = _orderModel.wpName;
    self.daysDisplayLabel.text = [NSString stringWithFormat:@"%lu",  (unsigned long)_orderModel.days];
    NSURL *imageUrl = [NSURL URLWithString:_orderModel.wpThemeImgURL];
    UIImage *imagePlaceholder = [UIImage imageNamed:DefaultImageName];
    [self.themeImageView sd_setImageWithURL:imageUrl placeholderImage:imagePlaceholder];
    
    NSDate *startDate = [NSDate dateFromString:_orderModel.startDate format:nil] ;
    NSDate *endDate = [NSDate dateFromString:_orderModel.endDate format:nil];
    
    //    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];

    NSMutableString *dateMString = [[NSMutableString alloc] init];
    [dateMString setString:@""];
    [dateMString appendString:[fmt stringForObjectValue:startDate]];
    [dateMString appendString:@"-"];
    [dateMString appendString:[fmt stringForObjectValue:endDate]];
    
    self.cycleDisplayLabel.text = dateMString;
}

- (UIButton *)payButton
{
    if (_payButton) {
        return _payButton;
    }
    
    _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_payButton setTitle:@"付款" forState:UIControlStateNormal];
    _payButton.titleLabel.font = SysFont(14);
    _payButton.layer.borderColor = ColorRed_Normal.CGColor;
    _payButton.layer.borderWidth = 1;
    _payButton.layer.cornerRadius = CornerRadius-1;
    _payButton.layer.masksToBounds = YES;
    [_payButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
    [_payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_payButton setBackgroundColorForState:[UIColor whiteColor] forState:UIControlStateNormal];
    [_payButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
    [_payButton addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    return _payButton;
}

- (UIButton *)operateButton
{
    if (_operateButton) {
        return _operateButton;
    }
    
    _operateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_operateButton setImage:[UIImage imageNamed:@"order-operate"] forState:UIControlStateNormal];
    [_operateButton addTarget:self action:@selector(operate:) forControlEvents:UIControlEventTouchUpInside];
    
    return _operateButton;
}

- (UILabel *)wpNameLabel
{
    if (_wpNameLabel) {
        return _wpNameLabel;
    }
    
    _wpNameLabel = [[UILabel alloc] init];
    _wpNameLabel.backgroundColor = [UIColor clearColor];
    _wpNameLabel.textColor = ColorBaseFont;
    _wpNameLabel.font = SysFont(FontButtonTitleSize-3);
    return _wpNameLabel;
}

- (UILabel *)orderStatusLabel
{
    if (_orderStatusLabel) {
        return _orderStatusLabel;
    }
    
    _orderStatusLabel = [[UILabel alloc] init];
    _orderStatusLabel.backgroundColor = [UIColor clearColor];
    _orderStatusLabel.font = SysFont(14);
    return _orderStatusLabel;
}

- (UIView *)createContainerView
{
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor clearColor];
    return containerView;
}

- (UILabel *)createTextLabel
{
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = ColorBaseFont;
    textLabel.font = SysFont(FontLabelSize);
    
    return textLabel;
}

- (UILabel *)createTitleLabel:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = SysFont(12);
    titleLabel.text = title;
    return titleLabel;
}

#pragma mark - action

- (void)operate:(id)sender
{
    [self.operateDelegate showOperateSheetList:self.myIndexPath];
}

- (void)pay
{
    if ([self.operateDelegate respondsToSelector:@selector(payForOrder:)]) {
        [self.operateDelegate payForOrder:self.orderModel];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
