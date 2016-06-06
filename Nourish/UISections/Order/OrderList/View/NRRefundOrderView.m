//
//  NRRefundOrderView.m
//  Nourish
//
//  Created by gtc on 15/7/22.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRefundOrderView.h"
#import "BMTextField.h"

@interface NRRefundOrderView ()<UITextFieldDelegate>
{
    UILabel *_daysTitleLabel;
    UILabel *_daysValueLabel;
    UILabel *_moneyTitleLabel;
    UILabel *_moneyValueLabel;
}

@property (nonatomic, strong) BMTextField *reasonTF;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelChangeButton;
@property (nonatomic, strong) NSMutableArray *marrAvaliableDateInOrderDates;

@end

static CGFloat reduceHeight = 216.0f;

@implementation NRRefundOrderView

- (id)initWithHeight:(CGFloat)height delegate:(id<LXActivityDelegate>)delegate {
    self = [super initWithHeight:height delegate:delegate];
    if (self) {
        CGFloat padding = 20;
        
        self.reasonTF = [[BMTextField alloc] initWithFrame:CGRectMake(padding, padding/2, self.backGroundView.bounds.size.width-2*padding, TextFieldDefaultHeight) hasControl:NO];
        self.reasonTF.placeholder = @"退款理由";
        self.reasonTF.delegate = self;
        [self.backGroundView addSubview:_reasonTF];
        
        _daysTitleLabel = [UILabel new];
        _daysTitleLabel.textColor = ColorRed_Normal;
        _daysTitleLabel.font = SysFont(FontTextFieldSize);
        _daysTitleLabel.text = @"可退天数 :";
        [self.backGroundView addSubview:_daysTitleLabel];
        [_daysTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_reasonTF.mas_bottom).offset(padding/2);
            make.left.equalTo(padding);
            make.height.equalTo(FontTextFieldSize);
        }];
        
        _daysValueLabel = [UILabel new];
        _daysValueLabel.textColor = ColorRed_Normal;
        _daysValueLabel.font = SysFont(FontTextFieldSize);
        [self.backGroundView addSubview:_daysValueLabel];
        [_daysValueLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_reasonTF.mas_bottom).offset(padding/2);
            make.left.equalTo(_daysTitleLabel.mas_right).offset(padding);
            make.height.equalTo(FontTextFieldSize);
        }];
        
        _moneyTitleLabel = [UILabel new];
        _moneyTitleLabel.textColor = ColorRed_Normal;
        _moneyTitleLabel.font = SysFont(FontTextFieldSize);
        _moneyTitleLabel.text = @"退款金额 :";
        [self.backGroundView addSubview:_moneyTitleLabel];
        [_moneyTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_daysTitleLabel.mas_bottom).offset(padding/2);
            make.left.equalTo(padding);
            make.height.equalTo(FontTextFieldSize);
        }];
        
        _moneyValueLabel = [UILabel new];
        _moneyValueLabel.textColor = ColorRed_Normal;
        _moneyValueLabel.font = SysFont(FontTextFieldSize);
        [self.backGroundView addSubview:_moneyValueLabel];
        [_moneyValueLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_daysTitleLabel.mas_bottom).offset(padding/2);
            make.left.equalTo(_moneyTitleLabel.mas_right).offset(padding);
            make.height.equalTo(FontTextFieldSize);
        }];
        
        //确认和取消
        [self.backGroundView addSubview:self.cancelChangeButton];
        [self.cancelChangeButton makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.backGroundView.mas_bottom).offset(-padding/2);
            make.left.equalTo(padding);
            make.height.equalTo(ButtonDefaultHeight);
            make.width.equalTo((self.backGroundView.bounds.size.width-3*padding)/2);
        }];
        
        [self.backGroundView addSubview:self.confirmButton];
        [self.confirmButton makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.backGroundView.mas_bottom).offset(-padding/2);
            make.right.equalTo(-padding);
            make.height.equalTo(ButtonDefaultHeight);
            make.width.equalTo((self.backGroundView.bounds.size.width-3*padding)/2);
        }];
        
    }
    
    return self;
}

#pragma mark - Action
- (void)refundOrder:(id)sender {
    // 1.退款理由必填
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *reason = self.reasonTF.text;
    reason = [reason stringByTrimmingCharactersInSet:whitespace];
    
    if (reason.length == 0) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"请填写退款理由"];
        return;
    }
    
    NSString *refundStartDate = nil;
    if (self.marrAvaliableDateInOrderDates.count > 0) {
        refundStartDate = [self.marrAvaliableDateInOrderDates firstObject];
    } else {
        refundStartDate = @" ";
    }
    
    NSDictionary *dicParam = @{@"orderId": self.orderMod.orderID,
                               @"refundStartDate": refundStartDate,
                               @"reason": reason};
    if (self.refundCmd) {
        [self.refundCmd execute:dicParam];
        [self tappedCancel];
    }
    return;
    
    WeakSelf(self);
    [MBProgressHUD showActivityWithText:weakSelf.viewController.view text:@"提交退款..." animated:YES];
    [[self.viewModel refundWithParametres:dicParam] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.viewController.view animated:YES];
//        weakSelf.orderMod.orderstatus = weakSelf.viewModel.statusCode;
//        weakSelf.orderMod.orderStatusDesc = weakSelf.viewModel.statusDesc;
        
        //回调更新订单状态
        if (weakSelf.weakOrderListVC) {
            [weakSelf.weakOrderListVC.tableViewList reloadData];
        }
        if (weakSelf.weakOrderDetailVC) {
            weakSelf.weakOrderDetailVC.isChanged = YES;
            [weakSelf.weakOrderDetailVC requestDetailData];
        }
        [MBProgressHUD showDoneWithText:KeyWindow text:@"已提交退款"];
    } error:^(NSError *error) {
        [weakSelf.viewController performSelector:@selector(processRequestError:) withObject:error];
    } completed:^{
    }];

    [self tappedCancel];
}

#pragma mark - Property
- (void)setOrderMod:(NROrderInfoModel *)orderMod {
    _orderMod = orderMod;
    self.marrAvaliableDateInOrderDates = [NSMutableArray array];
    
    NSDate *today = [NSDate new];//今天
    if (today.hour >= 21) {
        //判断当前时间是否超过21点，如果未超过，明天的可退款，超过从后天开始可退款
        today = [today dateByAddingTimeInterval:24*60*60];
    }
    
    for (NSString *dateString in self.orderMod.arrDates) {
        NSDate *date = [NSDate dateFromString:dateString format:nil];
        if ([date compare:today] == NSOrderedDescending) {
            [self.marrAvaliableDateInOrderDates addObject:dateString];
        }
    }
    
    NSUInteger unionPrice = [self.orderMod.totalPrice unsignedIntegerValue]/self.orderMod.days;
    _daysValueLabel.text = [NSString stringWithFormat:@"%lu元 × %lu天", unionPrice, self.marrAvaliableDateInOrderDates.count];
    NSUInteger totalFee = unionPrice *self.marrAvaliableDateInOrderDates.count;
    _moneyValueLabel.text = [NSString stringWithFormat:@"%lu 元", totalFee];
    
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
        _confirmButton.layer.borderColor = ColorRed_Normal.CGColor;
        _confirmButton.layer.borderWidth = 0.5;
        _confirmButton.layer.cornerRadius = CornerRadius;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton addTarget:self action:@selector(refundOrder:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _confirmButton;
}

- (UIButton *)cancelChangeButton {
    if (!_cancelChangeButton) {
        _cancelChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelChangeButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelChangeButton setTitleColor:ColorRed_Normal forState:UIControlStateNormal];
        _cancelChangeButton.titleLabel.textColor = ColorRed_Normal;
        _cancelChangeButton.layer.cornerRadius = CornerRadius;
        _cancelChangeButton.layer.borderColor = ColorRed_Normal.CGColor;
        _cancelChangeButton.layer.borderWidth = 0.5;
        _cancelChangeButton.layer.masksToBounds = YES;
        [_cancelChangeButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelChangeButton;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGFloat y = [UIScreen mainScreen].bounds.size.height-self.LXActivityHeight - reduceHeight;
    [UIView animateWithDuration:0.25 animations:^{
        [self.backGroundView setFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, self.LXActivityHeight)];
    } completion:^(BOOL finished) {
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.reasonTF resignFirstResponder];
    CGFloat y = [UIScreen mainScreen].bounds.size.height-self.LXActivityHeight;
    [UIView animateWithDuration:0.25 animations:^{
        [self.backGroundView setFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, self.LXActivityHeight)];
    } completion:^(BOOL finished) {
    }];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.reasonTF resignFirstResponder];
    CGFloat y = [UIScreen mainScreen].bounds.size.height-self.LXActivityHeight;
    [UIView animateWithDuration:0.25 animations:^{
        [self.backGroundView setFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, self.LXActivityHeight)];
    } completion:^(BOOL finished) {
    }];
}

@end
