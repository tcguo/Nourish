//
//  NRPlaceOrderViewController.m
//  Nourish
//
//  Created by gtc on 15/3/2.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRPlaceOrderViewController.h"
#import "NROrderUserInfoCell.h"
#import "NROrderWeekPlanCell.h"
#import "BMButton.h"
#import "UIImageView+WebCache.h"
#import "NRPlaceOrderCalendarView.h"
#import "NSDate+DSLCalendarView.h"

#import "NRPlaceOrderNoteController.h"
#import "NRPlaceOrderCouponController.h"
#import "NRCouponViewController.h"
#import "NRAddInvoiceController.h"
#import "NRAddrSelectTableController.h"
#import "NRAddAddressController.h"
#import "NRPayCenterTableController.h"
#import "NRWeekPlanListItemModel.h"
#import "NRCouponCell.h"
#import "LPLabel.h"

@interface NRPlaceOrderViewController ()<UITableViewDataSource, UITableViewDelegate, NRPlaceOrderCalendarViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) BMButton *submitButton;
@property (strong, nonatomic) UILabel *daysLabel;
@property (strong, nonatomic) UILabel *amountLabel;
@property (strong, nonatomic) NRPlaceOrderCalendarView *calendarView;
@property (strong, nonatomic) LPLabel *originalAmountLabel;

@property (strong, nonatomic) NSMutableString *dateMString;
@property (strong, nonatomic) NSArray *arrDates;
@property (strong, nonatomic) NSMutableArray *marrTitlesGroupThree;
@property (strong, nonatomic) NSMutableArray *marrDetailTitlesGroupThree;
@property (strong, nonatomic) NRAddInvoiceController *addInvoiceVC;

@property (strong, nonatomic) NRCouponInfoModel *couponSelectedModel;
@property (assign, nonatomic) CGFloat totalFee;

@end

@implementation NRPlaceOrderViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"确认订单";
    _marrTitlesGroupThree = [NSMutableArray arrayWithObjects:@"优惠券", @"备注", @"发票", nil];
    _marrDetailTitlesGroupThree = [NSMutableArray arrayWithObjects:@"选择优惠券", @"添加备注", @"发票抬头", nil];
    _dateMString = [[NSMutableString alloc] init];
    [self.dateMString setString:@"请选择"];
    _arrDates = [[NSArray alloc] init];
    
//    self.addressID = -1;
    
    [self setupTableView];
    [self setupPayAmountView];
    
    // 加载收餐地址
    [self readyToPlaceOrder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setupTableView {
    __weak typeof(self) weakself = self;
    [self.view addSubview:self.tableView];
    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(weakself.view);
        make.bottom.equalTo(weakself.view.mas_bottom).offset(-100);
    }];
}

- (void)setupPayAmountView {
    UIView *containerView = [[UIView alloc] init];
    [self.view addSubview:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(0);
        make.height.equalTo(100);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ColorLine;
    [containerView addSubview:lineView];
    [lineView makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(0);
        make.height.equalTo(0.5);
    }];
    
    UIView *priceContainerView = [[UIView alloc] init];
    [containerView addSubview:priceContainerView];
    [priceContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(30);
        make.right.equalTo(-30);
        make.top.equalTo(15);
        make.height.equalTo(25);
    }];
    
    UIImageView *priceImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orderplace-price"]];
    priceImgv.contentMode = UIViewContentModeScaleAspectFit;
    [priceContainerView addSubview:priceImgv];
    [priceImgv makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(priceContainerView.mas_centerY);
        make.left.equalTo(0);
    }];
    
    self.daysLabel = [[UILabel alloc] init];
    self.daysLabel.textColor = ColorRed_Normal;
    self.daysLabel.font = SysFont(FontLabelSize);
    self.daysLabel.text = [NSString stringWithFormat:@"%lu×%lu天", (unsigned long)self.unitPrice, (unsigned long)[self.arrDates count]];
    [priceContainerView addSubview:_daysLabel];
    [self.daysLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceImgv.mas_right).with.offset(5);
        make.centerY.equalTo(priceContainerView.mas_centerY);
    }];
    
    self.amountLabel = [[UILabel alloc] init];
    self.amountLabel.textColor = ColorRed_Normal;
    self.amountLabel.font = SysFont(FontLabelSize);
    self.amountLabel.text = [NSString stringWithFormat:@"%.2f", (CGFloat)self.unitPrice*self.arrDates.count];
    [priceContainerView addSubview:_amountLabel];
    [self.amountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(priceContainerView.mas_centerY);
        make.right.equalTo(0);
    }];
    
    WeakSelf(self);
    [priceContainerView addSubview:self.originalAmountLabel];
    [self.originalAmountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(priceContainerView.mas_centerY);
        make.right.equalTo(weakSelf.amountLabel.mas_left);
    }];
    
    UIImageView *amoutImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orderplace-amount"]];
    amoutImgv.contentMode = UIViewContentModeScaleAspectFit;
    [priceContainerView addSubview:amoutImgv];
    [amoutImgv makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(priceContainerView.mas_centerY);
        make.right.equalTo(weakSelf.originalAmountLabel.mas_left).offset(-5);
    }];
    
    self.submitButton = [BMButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.layer.borderColor = ColorRed_Normal.CGColor;
    self.submitButton.layer.borderWidth = 0.8;
    self.submitButton.layer.cornerRadius = CornerRadius;
    [containerView addSubview:_submitButton];
   
    [_submitButton setTitle:@"立即下单" forState:UIControlStateNormal];
    _submitButton.titleLabel.font = NRFont(FontButtonTitleSize);
    [_submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_submitButton setBackgroundColorForState:ColorRed_Normal forState:UIControlStateHighlighted];
    [_submitButton setBackgroundColorForState:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_submitButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView);
        make.centerY.equalTo(containerView).with.offset(20);
        make.height.greaterThanOrEqualTo(35);
        make.width.equalTo(120);
    }];
    [_submitButton addTarget:self action:@selector(submitOrder:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Actions
- (void)readyToPlaceOrder {
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showActivityWithText:self.view text:Tips_Loading animated:YES];
    
    [self.viewModel fetchReadyInfoWithSMWIds:self.currentMod.arrWPSID completeBlock:^(id resultObject, NSError *error) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        if (error) {
            [weakSelf processRequestError:error];
            return;
        }
        if (![resultObject isKindOfClass:[weakSelf.viewModel class]]) {
            return;
        }
        
        NRPlaceOrderViewModel *resultModel = (NRPlaceOrderViewModel *)resultObject;
        [weakSelf.marrDetailTitlesGroupThree replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%lu张可用", (unsigned long)resultModel.couponCount]];
        [weakSelf.tableView reloadData];
        
        //监听日期和优化券，重新计算价格
        RACSignal *couponSignal = RACObserve(weakSelf, couponSelectedModel);
        RACSignal *dateSignal = RACObserve(weakSelf, arrDates);
        [[RACSignal combineLatest:@[dateSignal, couponSignal]
                          reduce:^id(NSArray *dates, NRCouponInfoModel *coupon){
                              return @(ARRAYHASVALUE(dates) && coupon);
                          }] subscribeNext:^(id x) {
                              CGFloat originalFee = weakSelf.unitPrice*weakSelf.arrDates.count;
                              weakSelf.totalFee = weakSelf.unitPrice*weakSelf.arrDates.count;
                              if ([x boolValue]) {
                                  //重新计算价格
                                  if (weakSelf.couponSelectedModel.type == CouponTypeMoney) {
                                      weakSelf.totalFee = weakSelf.totalFee-[weakSelf.couponSelectedModel.amount integerValue];
                                  }
                                  else if (weakSelf.couponSelectedModel.type == CouponTypeDiscount) {
                                      weakSelf.totalFee = weakSelf.totalFee*(100-[weakSelf.couponSelectedModel.rate integerValue])/100;
                                  }
                              }
                              
                              // 当优惠券金额大于支付金额
                              if (weakSelf.totalFee < 0.0) {
                                  weakSelf.totalFee = 0.01;
                              }
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (self.totalFee != originalFee) {
                                      weakSelf.originalAmountLabel.text = [NSString stringWithFormat:@"%.2f", originalFee];
                                  }
                                  weakSelf.amountLabel.text = [NSString stringWithFormat:@"%.2f", weakSelf.totalFee];
                              });
                          }];
    }];
    
}

- (void)submitOrder:(id)sender {
    [MobClick event:NREvent_Click_PlaceOrder_Comfirm];
    
    if (!self.viewModel.availableAddrModel) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"请新增送餐地址"];
        return;
    }
    if (self.arrDates.count == 0) {
        [MBProgressHUD showErrormsg:KeyWindow msg:@"请选择日期"];
        return;
    }
    
    NSMutableDictionary *mdicData = [[NSMutableDictionary alloc] initWithCapacity:20];
    [mdicData setObject:[NSNumber numberWithInteger:self.viewModel.availableAddrModel.addressID] forKey:@"addressId"];
    [mdicData setObject:[NSNumber numberWithInteger:self.wptID] forKey:@"wptId"];
    
    NSArray *smwIds = self.currentMod.arrWPSID;
    [mdicData setObject:smwIds forKey:@"smwIds"];
    [mdicData setObject:self.arrDates forKey:@"dates"];
    
    if (self.couponSelectedModel) {
        [mdicData setObject:@(self.couponSelectedModel.couponID) forKey:@"couponId"];
    }
    if (![[self.marrDetailTitlesGroupThree objectAtIndex:1] isEqualToString:@"添加备注"]) {
        [mdicData setObject:self.noteString forKey:@"note"];
    }
    if (![[self.marrDetailTitlesGroupThree objectAtIndex:2] isEqualToString:@"发票抬头"]) {
        [mdicData setObject:self.invoiceString forKey:@"billTitle"];
    }

    [mdicData setObject:[NSString stringWithFormat:@"%lu", (unsigned long)self.unitPrice] forKey:@"dailyPrice"];
    [mdicData setObject:[NSNumber numberWithUnsignedInteger:self.arrDates.count] forKey:@"days"];
    [mdicData setObject:[NSString stringWithFormat:@"%.2f", self.totalFee] forKey:@"totalPrice"];
    
    [MBProgressHUD showActivityWithText:self.view text:@"提交订单..." animated:YES];
    WeakSelf(self);
    [[self.viewModel submitOrderWithParametres:mdicData] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        [MBProgressHUD showDoneWithText:KeyWindow text:@"下单成功"];
        
        NRPayCenterTableController *payVC = [[NRPayCenterTableController alloc] initWithStyle:UITableViewStyleGrouped];
        payVC.amount = weakSelf.viewModel.totalFee; //总金额
        payVC.orderID = weakSelf.viewModel.orderId; //订单号
        payVC.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:payVC animated:YES];
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 2;
    }
    else
        return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *OrderCell = @"OrderCell";
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (!self.viewModel.availableAddrModel) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"新增地址";
        } else {
            NROrderUserInfoCell *userCell = [[NROrderUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            userCell.addressLabel.text = self.viewModel.availableAddrModel.wholeAddress;
            userCell.nameLabel.text = self.viewModel.availableAddrModel.name;
            userCell.phoneLabel.text = self.viewModel.availableAddrModel.phone;
            cell = userCell;
        }
    } else if (indexPath.section == 1) {
        NROrderWeekPlanCell *weekplanCell = [[NROrderWeekPlanCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        [weekplanCell.wptImageView sd_setImageWithURL:[NSURL URLWithString:self.currentMod.theWeekPlanImageUrl] placeholderImage:[UIImage imageNamed:@"wpt-default"]];
        weekplanCell.wptName = self.currentMod.theWeekPlanName;
        cell = weekplanCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:OrderCell];
        if (!cell) {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:OrderCell];
        }
    }
    
    cell.textLabel.font = SysFont(FontLabelSize);
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellAccessoryNone;
    } else if (indexPath.section == 2) {
        cell.selectionStyle = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"周期制定";
            UIImageView *calendarImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orderplace-calendaricon"]];
            calendarImgv.contentMode = UIViewContentModeScaleAspectFit;
            cell.accessoryView = calendarImgv;
        } else {
            cell.textLabel.text = @"选定周期";
            cell.detailTextLabel.font = SysFont(14);
            cell.detailTextLabel.textColor = ColorRed_Normal;
            cell.detailTextLabel.text = self.dateMString;
        }
    } else if (indexPath.section == 3) {
        cell.detailTextLabel.font = SysFont(14);
        cell.textLabel.text = [self.marrTitlesGroupThree objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.marrDetailTitlesGroupThree objectAtIndex:indexPath.row];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NRAddrSelectTableController *addressVC = [[NRAddrSelectTableController alloc] initWithStyle:UITableViewStyleGrouped];
        addressVC.placeOrderVC = self;
        addressVC.selectedModel = self.viewModel.availableAddrModel;
        [self.navigationController pushViewController:addressVC animated:YES];
    }
    
    if (indexPath.section == 2) {
        self.calendarView = [[NRPlaceOrderCalendarView alloc] init];
        self.calendarView.contentViewHeight = 400*kAppUIScaleY;
        self.calendarView.delegate = self;
        [self.calendarView setupUI];
        [self.calendarView showInView:self.view.window];
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
            {
                [MobClick event:NREvent_Click_PlaceOrder_SelCounpon];
                
                WeakSelf(self);
                NRCouponViewController *couponVC = [[NRCouponViewController alloc] init];
                couponVC.fromWhere = CouponFromOrder;
                couponVC.wptID = self.wptID;
                couponVC.selectCouponCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                    weakSelf.couponSelectedModel = (NRCouponInfoModel *)input;
                    if (weakSelf.couponSelectedModel == nil) {
                        [weakSelf.marrDetailTitlesGroupThree replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%lu张可用", (unsigned long)weakSelf.viewModel.couponCount]];
                    }
                    else {
                        [weakSelf.marrDetailTitlesGroupThree replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@", weakSelf.couponSelectedModel.name]];
                    }
                   
                    return [RACSignal empty];
                }];
                
                [self.navigationController pushViewController:couponVC animated:YES];
            }
                break;
            case 1:
            {
                NRPlaceOrderNoteController *noteVC = [[NRPlaceOrderNoteController alloc] init];
                noteVC.placeOrderVC = self;
                [self.navigationController pushViewController:noteVC animated:YES];
            }
                break;
            case 2:
            {
                if (!self.addInvoiceVC) {
                    self.addInvoiceVC = [[NRAddInvoiceController alloc] init];
                    self.addInvoiceVC.placeOrderVC = self;
                }
                [self.navigationController pushViewController:self.addInvoiceVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!self.viewModel.availableAddrModel) {
            return 45;
        }
        return 70;
    } else if (indexPath.section == 1) {
        return 86;
    } else
        return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    
    return 7.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 7.5;
}


#pragma mark - NRPlaceOrderCalendarViewDelegate
- (void)placeOrderCalendarView:(NRPlaceOrderCalendarView *)calendarView didSelectDates:(NSDictionary *)userInfo {
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    //    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"MM月d日";
    [self.dateMString setString:@""];
    [self.dateMString appendString:[fmt stringForObjectValue:[userInfo valueForKey:@"start"]]];
    [self.dateMString appendString:@"-"];
    [self.dateMString appendString:[fmt stringForObjectValue:[userInfo valueForKey:@"end"]]];
    
//    NSLog(@"s = %@, e = %@", [fmt stringForObjectValue:[userInfo valueForKey:@"start"]],[userInfo objectForKey:@"end"]);
    [self.tableView reloadData];
    
    self.arrDates = [userInfo valueForKey:@"selectDates"];
    self.daysLabel.text = [NSString stringWithFormat:@"%lu×%lu天", (unsigned long)self.unitPrice, (unsigned long)[self.arrDates count]];
}


#pragma mark - Getter and Setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStyleGrouped];
        _tableView.backgroundColor = ColorViewBg;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

- (void)setInvoiceString:(NSString *)invoiceString {
    if (!STRINGHASVALUE(invoiceString)) {
        _invoiceString = @"发票抬头";
    }
    else {
        _invoiceString = invoiceString;
    }
    
    [self.marrDetailTitlesGroupThree replaceObjectAtIndex:2 withObject:_invoiceString];
}

- (void)setNoteString:(NSString *)noteString {
    if (!STRINGHASVALUE(noteString)) {
        _noteString = @"添加备注";
    }
    else {
        _noteString = noteString;
    }
    
    [self.marrDetailTitlesGroupThree replaceObjectAtIndex:1 withObject:_noteString];
}

- (NRPlaceOrderViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NRPlaceOrderViewModel alloc] init];
    }
    
    return _viewModel;
}

- (LPLabel *)originalAmountLabel {
    if (!_originalAmountLabel) {
        _originalAmountLabel = [[LPLabel alloc] init];
        _originalAmountLabel.font =  SysFont(12);
        _originalAmountLabel.textColor = RgbHex2UIColor(0xc7, 0xc7, 0xc7);
        _originalAmountLabel.strikeThroughEnabled = YES;
        _originalAmountLabel.strikeThroughColor = RgbHex2UIColor(0xc7, 0xc7, 0xc7);
        _originalAmountLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _originalAmountLabel;
}

#pragma mark - Override
- (void)back:(id)sender {
    [MobClick event:NREvent_Click_PlaceOrder_Back];
    [super back:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
