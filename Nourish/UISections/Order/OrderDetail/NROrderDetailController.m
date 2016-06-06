//
//  NROrderDetailController.m
//  Nourish
//
//  Created by gtc on 15/3/27.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderDetailController.h"
#import "UIImageView+LBBlurredImage.h"
#import "NROrderDetailModel.h"
#import "NRRefundOrderView.h"
#import "NRChangeOrderCalendarView.h"
#import "UIImageView+WebCache.h"
#import "NRWeekPlanCommentViewController.h"
#import "NRPlaceOrderViewController.h"

#define FontSmall 14
#define FontBigColor RgbHex2UIColor(0x51, 0x51, 0x51)

static const int alertViewTag_cancelOrder = 100;

@interface NROrderDetailController ()<UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    UILabel *_orderStatusLabel;
    UILabel *_orderAmountLabel;
    UILabel *_orderStartDateLabel;
    
    UILabel *_postNameLabel;
    UILabel *_postPhoneLabel;
    UILabel *_postAddrLabel;
    
    UILabel *_orderNoLabel;
    UILabel *_orderPayWayLabel;
    UILabel *_orderCouponLabel;
    UILabel *_orderSubmitTimeLabel;
    
    UILabel *_customerServicePhoneLabel;

    UIView *_orderStatusContainerView;
    UIView *_postContainerView;
    UIView *_weekplansContailView;
    UIView *_orderDetailContainerView;
    UIView *_tipContainerView;
    UIView *_operateContainerView;
    
    UILabel *_zaoContentLabel;
    UILabel *_wuContentLabel;
    UILabel *_chaContentLabel;
    UILabel *_weekLabel;
    int paddingLeft;
    
    
    NRChangeOrderCalendarView *_changeOrderView;
    UIWebView  *_webView;
   
}

@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;
@property (copy, nonatomic) NSString *orderID;
@property (strong, nonatomic) UIScrollView *outerSV;
@property (strong, nonatomic) UIScrollView *innerSV;
@property (strong, nonatomic) NROrderDetailModel *model;

@property (nonatomic, weak) NSURLSessionDataTask *detailTask;

@end

@implementation NROrderDetailController


#pragma mark - view cycle
- (id)initWithOrderID:(NSString *)orderID {
    if (self = [super init]) {
        _orderID = orderID;
        _isChanged = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"订单详情";
    self.view.backgroundColor = RgbHex2UIColor(0xe2, 0xe2, 0xe2);
    paddingLeft = 32;
    [self.view addSubview:self.outerSV];
    [self setupCallButton];
    [self requestDetailData];
}

- (void)viewDidLayoutSubviews {
    if (_tipContainerView) {
        CGFloat height = _tipContainerView.frame.size.height + _tipContainerView.frame.origin.y;
        
        if (height <= self.outerSV.bounds.size.height) {
            height = self.outerSV.bounds.size.height+10;
        }
        
        [self.outerSV setContentSize:CGSizeMake(SCREEN_WIDTH, height)];
    }
}


#pragma mark - SetupUI
- (void)setupCallButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"order-customerPhone"] forState:UIControlStateNormal];
    button.exclusiveTouch = YES;
    [button addTarget:self action:@selector(willCallCustomer) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 28, 28);
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:menuButton animated:YES];
}

- (void)setupOrderStatus {
    _orderStatusContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    _orderStatusContainerView.backgroundColor = [UIColor whiteColor];
    [self.outerSV addSubview:_orderStatusContainerView];

    UIImageView *saveImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orderdetail-note"]];
    [_orderStatusContainerView addSubview:saveImgView];
    [saveImgView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(12);
        make.left.equalTo(@10);
        make.width.equalTo(@12);
    }];
    
    _orderStatusLabel = [UILabel new];
    _orderStatusLabel.font = [UIFont boldSystemFontOfSize:FontLabelSize];
    _orderStatusLabel.textColor = FontBigColor;
    _orderStatusLabel.text = [NSString stringWithFormat:@"周计划%@", self.model.statusDesc];
    [_orderStatusContainerView addSubview:_orderStatusLabel];
    [_orderStatusLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(12);
        make.left.equalTo(paddingLeft);
        make.height.equalTo(FontLabelSize);
    }];
    
    _orderAmountLabel = [UILabel new];
    _orderAmountLabel.font = SysFont(FontSmall);
    _orderAmountLabel.text = [NSString stringWithFormat:@"周计划金额: %@", self.model.totalPrice];
    _orderAmountLabel.textColor = ColorBaseFont;
    [_orderStatusContainerView addSubview:_orderAmountLabel];
    [_orderAmountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_orderStatusLabel.mas_bottom).offset(10);
        make.left.equalTo(paddingLeft);
        make.height.equalTo(FontSmall);
    }];
    
    _orderStartDateLabel = [UILabel new];
    _orderStartDateLabel.font = SysFont(FontSmall);
    _orderStartDateLabel.text = [NSString stringWithFormat:@"周计划生效日期: %@", self.model.startDate];
    _orderStartDateLabel.textColor = ColorBaseFont;
    [_orderStatusContainerView addSubview:_orderStartDateLabel];
    [_orderStartDateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_orderAmountLabel.mas_bottom).offset(10);
        make.left.equalTo(paddingLeft);
        make.height.equalTo(FontSmall);
    }];
    
    UIView *lineFirst = [UIView new];
    lineFirst.backgroundColor = RgbHex2UIColor(0xe9, 0xe7, 0xe8);
    [_orderStatusContainerView addSubview:lineFirst];
    [lineFirst makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(@0);
        make.height.equalTo(@0.5);
    }];
}

- (void)setupPostInfo {
    CGFloat y = _orderStatusContainerView.frame.origin.y + _orderStatusContainerView.bounds.size.height;
    _postContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, 76)];
    _postContainerView.backgroundColor = [UIColor whiteColor];
    [self.outerSV addSubview:_postContainerView];
    
    UIImageView *locationImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orderdetail-location"]];
    [_postContainerView addSubview:locationImgView];
    [locationImgView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@12);
        make.width.equalTo(@12);
    }];
    
    _postNameLabel = [UILabel new];
    _postNameLabel.textColor = FontBigColor;
    _postNameLabel.font = [UIFont boldSystemFontOfSize:FontLabelSize];
    _postNameLabel.text = [NSString stringWithFormat:@"收餐人 : %@", self.model.toName];
    [_postContainerView addSubview:_postNameLabel];
    [_postNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@12);
        make.left.equalTo(paddingLeft);
        make.height.equalTo(FontLabelSize);
    }];
    
    _postPhoneLabel = [UILabel new];
    _postPhoneLabel.textColor = FontBigColor;
    _postPhoneLabel.font = [UIFont boldSystemFontOfSize:FontLabelSize];
    _postPhoneLabel.text = self.model.toPhone;
    [_postContainerView addSubview:_postPhoneLabel];
    [_postPhoneLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@12);
        make.right.equalTo(-10);
        make.height.equalTo(FontLabelSize);
    }];
    
    _postAddrLabel = [[UILabel alloc] init];
    _postAddrLabel.textColor = ColorBaseFont;
    _postAddrLabel.numberOfLines = 0;
    _postAddrLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _postAddrLabel.textAlignment = NSTextAlignmentLeft;
    _postAddrLabel.font = SysFont(FontSmall);
    NSString *address = [NSString stringWithFormat:@"地址: %@", self.model.toAddr];
    [_postContainerView addSubview:_postAddrLabel];
   
    NSDictionary *attr = @{ NSFontAttributeName:SysFont(FontSmall),
                            NSParagraphStyleAttributeName: self.paragraphStyle};
    CGSize size = [address sizeWithAttributes:attr];
    CGFloat wid = SCREEN_WIDTH;
    long int rowNum = ceil(ceil(size.width)/(wid-32-10));
    CGFloat height = rowNum*15 +(rowNum-1)*4.0;

    [_postAddrLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postNameLabel.mas_bottom).offset(@12);
        make.left.equalTo(paddingLeft);
        make.height.equalTo(@(height));
        make.right.equalTo(@(-10));
    }];
    NSMutableAttributedString *attrAddress = [[NSMutableAttributedString alloc] initWithString:address attributes:attr];
    _postAddrLabel.attributedText = attrAddress;
    
    _postContainerView.frame = CGRectMake(0, y, self.view.bounds.size.width, 50+height);
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = RgbHex2UIColor(0xc6, 0xc6, 0xc6);
    [_postContainerView addSubview:lineView];
    [lineView makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(@0);
        make.height.equalTo(@0.5);
    }];
}

- (void)setupMealImages {
    _weekplansContailView = [[UIView alloc] initWithFrame:CGRectMake(0, _postContainerView.frame.origin.y +_postContainerView.bounds.size.height, self.view.bounds.size.width, 176*self.appdelegate.autoSizeScaleY)];
    _weekplansContailView.backgroundColor = [UIColor clearColor];
    [self.outerSV addSubview:_weekplansContailView];
    
    NSInteger pages = self.model.orderDates.count;
    CGFloat fontSizeForTitle = 14;
    CGFloat fontSizeForContent = 12;
    
    [_weekplansContailView addSubview:self.innerSV];
    self.innerSV.contentSize = CGSizeMake(self.innerSV.frame.size.width * pages, self.innerSV.frame.size.height);

    for (int page = 0; page < pages; page++) {
        NSString *date = self.model.orderDates[page];
        // 判断当天日期是周几
        NSDate *today = [NSDate dateFromString:date format:nil];
        NSDateComponents *dateComponents = [NSDate dateComponentsForDate:today];
        NSInteger weekday = dateComponents.weekday;
        NSInteger newWeekday = weekday - 2;
        if (newWeekday < 0) {
            newWeekday = 1;
        }
        
        NRWeekSetMeal *todaySeal = [self.model.marrMeals objectAtIndex:newWeekday];
        
        CGRect frame = self.innerSV.frame;
        CGRect rect = CGRectMake(frame.size.width*page + 5, 0, self.innerSV.bounds.size.width-10, self.innerSV.bounds.size.height);
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:rect];
        imageview.layer.masksToBounds = YES;
        imageview.contentMode = UIViewContentModeScaleToFill;
       [self.innerSV addSubview:imageview];
        
        NSURL *imageUrl = [NSURL URLWithString:todaySeal.mealImageUrl];
        __weak typeof (imageview) weakImageView = imageview;
        [imageview sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"wpt-default"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            CGFloat rate = CGRectGetHeight(imageview.frame)/image.size.height*2;
            CGFloat y = (image.size.height - CGRectGetHeight(imageview.frame))/2;
            CGImageRef cgimage = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, y, image.size.width*2, image.size.height * rate));
            UIImage *partImageView  = [UIImage imageWithCGImage:cgimage];
            
            [weakImageView setImageToBlur:partImageView blurRadius:5 completionBlock:nil];
        }];

        UIView *maskView = [UIView new];
        maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        maskView.frame = imageview.bounds;
        [imageview addSubview:maskView];
        UIView *wuContainerView = nil;
        
        NRDaySetmeal *dayWuSetmeal = [todaySeal.setMealsDic valueForKey:[NSString stringWithFormat:@"%d", (int)DinnerTypeWu]];
        if (dayWuSetmeal) {
            wuContainerView = [[UIView alloc] init];
            [maskView addSubview: wuContainerView];
            [wuContainerView makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(8);
                make.centerY.equalTo(maskView.centerY);
                make.height.equalTo(31);
            }];
            
            UILabel *wuTitleLabel = [UILabel new];
            wuTitleLabel.font = NRFont(fontSizeForTitle);
            wuTitleLabel.text = @"午餐";
            wuTitleLabel.textAlignment = NSTextAlignmentCenter;
            wuTitleLabel.textColor = [UIColor whiteColor];
            [wuContainerView addSubview:wuTitleLabel];
            [wuTitleLabel makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.top.equalTo(0);
                make.height.equalTo(fontSizeForTitle);
            }];
            _wuContentLabel = [UILabel new];
            _wuContentLabel.font = NRFont(fontSizeForContent);
            _wuContentLabel.text = dayWuSetmeal.foodsString;
            _wuContentLabel.textAlignment = NSTextAlignmentCenter;
            _wuContentLabel.textColor = [UIColor whiteColor];
            [wuContainerView addSubview:_wuContentLabel];
            [_wuContentLabel makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(0);
                make.top.equalTo(wuTitleLabel.bottom).offset(5);
                make.height.equalTo(fontSizeForContent);
            }];

        }
        
        NRDaySetmeal *dayZaoSetmeal = [todaySeal.setMealsDic valueForKey:[NSString stringWithFormat:@"%d", (int)DinnerTypeZao]];
        if (dayZaoSetmeal) {
            UIView *zaoContainerView = [[UIView alloc] init];
            [maskView addSubview: zaoContainerView];
            [zaoContainerView makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(8);
                make.height.equalTo(31);
                make.bottom.equalTo(wuContainerView.mas_top).offset(-10);
            }];
            
            UILabel *zaoTitleLabel = [UILabel new];
            zaoTitleLabel.font = NRFont(fontSizeForTitle);
            zaoTitleLabel.text = @"早餐";
            zaoTitleLabel.textAlignment = NSTextAlignmentCenter;
            zaoTitleLabel.textColor = [UIColor whiteColor];
            [zaoContainerView addSubview:zaoTitleLabel];
            [zaoTitleLabel makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.top.equalTo(0);
                make.height.equalTo(fontSizeForTitle);
            }];
            
            _zaoContentLabel = [UILabel new];
            _zaoContentLabel.font = NRFont(fontSizeForContent);
            _zaoContentLabel.text = dayZaoSetmeal.foodsString;
            _zaoContentLabel.textAlignment = NSTextAlignmentCenter;
            _zaoContentLabel.textColor = [UIColor whiteColor];
            [zaoContainerView addSubview:_zaoContentLabel];
            [_zaoContentLabel makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(0);
                make.top.equalTo(zaoTitleLabel.bottom).offset(5);
                make.height.equalTo(fontSizeForContent);
            }];
        }
        
        NRDaySetmeal *dayChaSetmeal = [todaySeal.setMealsDic valueForKey:[NSString stringWithFormat:@"%lu", DinnerTypeCha]];
        if (dayChaSetmeal) {
            UIView *chaContainerView = [[UIView alloc] init];
            [maskView addSubview: chaContainerView];
            [chaContainerView makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(8);
                make.height.equalTo(31);
                make.top.equalTo(wuContainerView.mas_bottom).offset(10);
            }];
            
            UILabel *chaTitleLabel = [UILabel new];
            chaTitleLabel.font = NRFont(fontSizeForTitle);
            chaTitleLabel.text = @"下午餐";
            chaTitleLabel.textAlignment = NSTextAlignmentCenter;
            chaTitleLabel.textColor = [UIColor whiteColor];
            [chaContainerView addSubview:chaTitleLabel];
            [chaTitleLabel makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.top.equalTo(0);
                make.height.equalTo(fontSizeForTitle);
            }];
            
            _chaContentLabel = [UILabel new];
            _chaContentLabel.font = NRFont(fontSizeForContent);
            _chaContentLabel.text = dayChaSetmeal.foodsString;
            _chaContentLabel.textAlignment = NSTextAlignmentCenter;
            _chaContentLabel.textColor = [UIColor whiteColor];
            [chaContainerView addSubview:_chaContentLabel];
            [_chaContentLabel makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(0);
                make.top.equalTo(chaTitleLabel.bottom).offset(5);
                make.height.equalTo(fontSizeForContent);
            }];
        }
        
        _weekLabel = [UILabel new];
        [maskView addSubview:_weekLabel];
        _weekLabel.textColor = [UIColor whiteColor];
        _weekLabel.textAlignment = NSTextAlignmentCenter;
        _weekLabel.font = NRFont(fontSizeForContent);
        _weekLabel.text = [NSString stringWithFormat:@"%@  %@", date, todaySeal.displayWeekday] ;
        [_weekLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(0);
            make.height.equalTo(15);
            make.bottom.equalTo(maskView.mas_bottom);
        }];
    }
}

- (void)setupOrderDetail {
    CGFloat y = _weekplansContailView.frame.origin.y +_weekplansContailView.bounds.size.height;
    _orderDetailContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, 133+15)];
    _orderDetailContainerView.backgroundColor = [UIColor whiteColor];
    [self.outerSV addSubview:_orderDetailContainerView];
    
    UIView *lineOne = [UIView new];
    lineOne.backgroundColor = RgbHex2UIColor(0xc6, 0xc6, 0xc6);
    [_orderDetailContainerView addSubview:lineOne];
    [lineOne makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(0);
        make.height.equalTo(@0.5);
    }];
    
    UIView *upContainerView = [UIView new];
    [_orderDetailContainerView addSubview:upContainerView];
    [upContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(@0);
        make.height.equalTo(@110);
    }];
    
    UIImageView *noteImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orderdetail-save"]];
    [upContainerView addSubview:noteImgView];
    [noteImgView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@12);
        make.width.equalTo(@12);
    }];
    
    _orderNoLabel = [UILabel new];
    _orderNoLabel.textColor = ColorBaseFont;
    _orderNoLabel.text = [NSString stringWithFormat:@"订单编号: %@", self.model.orderId];
    _orderNoLabel.font = SysFont(FontSmall);
    [upContainerView addSubview:_orderNoLabel];
    [_orderNoLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(paddingLeft);
        make.top.equalTo(@12);
        make.height.equalTo(FontSmall);
    }];
    
    _orderPayWayLabel = [UILabel new];
    _orderPayWayLabel.textColor = ColorBaseFont;
    NSString *payDesc = nil;
    switch (self.model.payType) {
        case PayTypeAli:
            payDesc = @"支付宝及时到账";
            break;
        case PayTypeWeChat:
            payDesc = @"微信支付";
            break;
        case PayTypeNone:
            payDesc = @"";
            break;
        default:
            break;
    }
    
    if (self.model.payType != PayTypeNone) {
        _orderPayWayLabel.text = [NSString stringWithFormat:@"付款方式: %@", payDesc];
        _orderPayWayLabel.font = SysFont(FontSmall);
        [upContainerView addSubview:_orderPayWayLabel];
        [_orderPayWayLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(paddingLeft);
            make.top.equalTo(_orderNoLabel.mas_bottom).offset(@10);
            make.height.equalTo(FontSmall);
        }];
    }
    
    _orderCouponLabel = [UILabel new];
    _orderCouponLabel.textColor = ColorBaseFont;
    _orderCouponLabel.text = [NSString stringWithFormat:@"优惠信息: %@", self.model.coupon];
    _orderCouponLabel.font = SysFont(FontSmall);
    [upContainerView addSubview:_orderCouponLabel];
    [_orderCouponLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(paddingLeft);
        if (self.model.payType != PayTypeNone) {
            make.top.equalTo(_orderPayWayLabel.mas_bottom).offset(@10);
        }
        else
            make.top.equalTo(_orderNoLabel.mas_bottom).offset(@10);
      
        make.height.equalTo(FontSmall);
    }];
    
    _orderSubmitTimeLabel = [UILabel new];
    _orderSubmitTimeLabel.textColor = ColorBaseFont;
    _orderSubmitTimeLabel.text = [NSString stringWithFormat:@"成交时间: %@", self.model.createTime];
    _orderSubmitTimeLabel.font = SysFont(FontSmall);
    [upContainerView addSubview:_orderSubmitTimeLabel];
    [_orderSubmitTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(paddingLeft);
        make.top.equalTo(_orderCouponLabel.mas_bottom).offset(@10);
        make.height.equalTo(FontSmall);
    }];
    
    UIView *lineTwo = [UIView new];
    lineTwo.backgroundColor = RgbHex2UIColor(0xe9, 0xe7, 0xe8);
    [upContainerView addSubview:lineTwo];
    [lineTwo makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(upContainerView.mas_bottom);
        make.height.equalTo(@0.5);
    }];
    
    UIView *downContainerView = [UIView new];
    downContainerView.backgroundColor = [UIColor clearColor];
    [_orderDetailContainerView addSubview:downContainerView];
    [downContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(upContainerView.mas_bottom);
        make.height.equalTo(@37);
    }];
    
    UIImageView *phoneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orderdetail-phone"]];
    [downContainerView addSubview:phoneImgView];
    [phoneImgView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@12);
        make.width.equalTo(@16.5);
    }];
    
    _customerServicePhoneLabel = [UILabel new];
    _customerServicePhoneLabel.textColor = [UIColor blackColor];
    _customerServicePhoneLabel.text = [NRGlobalManager sharedInstance].customerPhone;
    _customerServicePhoneLabel.font = SysFont(FontSmall);
    [downContainerView addSubview:_customerServicePhoneLabel];
    [_customerServicePhoneLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@12);
        make.left.equalTo(paddingLeft);
    }];
    
    UIView *lineThree = [UIView new];
    lineThree.backgroundColor = RgbHex2UIColor(0xc6, 0xc6, 0xc6);
    [_orderDetailContainerView addSubview:lineThree];
    [lineThree makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(0);
        make.bottom.equalTo(0);
        make.height.equalTo(@0.5);
    }];
}

- (void)setupTips {
    _tipContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, _orderDetailContainerView.frame.origin.y + _orderDetailContainerView.bounds.size.height, self.view.bounds.size.width, 33)];
    _tipContainerView.backgroundColor = RgbHex2UIColor(0xe2, 0xe2, 0xe2);
    [self.outerSV addSubview:_tipContainerView];
    
    UILabel *linianLabel = [UILabel new];
    linianLabel.text = [NSString stringWithFormat:@"食高一筹，%@", APPNAME];
    linianLabel.font  = NRFont(13);
    linianLabel.textColor = RgbHex2UIColor(0xbf, 0xbf, 0xbf);
    linianLabel.textColor = ColorRed_Normal;
    [_tipContainerView addSubview:linianLabel];
    [linianLabel makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_tipContainerView);
    }];
    
    UIView *leftLineView = [UIView new];
    leftLineView.backgroundColor = RgbHex2UIColor(0xc8, 0xc8, 0xc8);
     leftLineView.backgroundColor = ColorRed_Normal;
    [_tipContainerView addSubview:leftLineView];
    [leftLineView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_tipContainerView.centerY);
        make.left.equalTo(10);
        make.right.equalTo(linianLabel.mas_left).offset(-10);
        make.height.equalTo(0.5);
    }];
    
    UIView *rightLineView = [UIView new];
    [_tipContainerView addSubview:rightLineView];
    rightLineView.backgroundColor = RgbHex2UIColor(0xc8, 0xc8, 0xc8);
    rightLineView.backgroundColor = ColorRed_Normal;
    [rightLineView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_tipContainerView.centerY);
        make.right.equalTo(-10);
        make.left.equalTo(linianLabel.mas_right).offset(10);
        make.height.equalTo(0.5);
    }];
}

- (void)setupOperateView {
    [_operateContainerView removeFromSuperview];
    _operateContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT- NAV_BAR_HEIGHT - 60, SCREEN_WIDTH, 60)];
    _operateContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_operateContainerView];
    
    UIView *lineUp = [UIView new];
    lineUp.backgroundColor = RgbHex2UIColor(0xc6, 0xc6, 0xc6);
    [_operateContainerView addSubview:lineUp];
    [lineUp makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(0);
        make.height.equalTo(@0.5);
    }];
    
    UIView *lineBotton = [UIView new];
    lineBotton.backgroundColor = RgbHex2UIColor(0xc6, 0xc6, 0xc6);
    [_operateContainerView addSubview:lineBotton];
    [lineBotton makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(0);
        make.bottom.equalTo(0);
        make.height.equalTo(@0.5);
    }];
    
    NSMutableArray *marrButtons = [NSMutableArray array];
    switch (self.model.orderStatus) {
        case OrderStatusPaying:
            [marrButtons addObject:[self addCancelOrderButton]];
            break;
        case OrderStatusPayCompleted:
        case OrderStatusToRun:
        case OrderStatusRefunded:
            
        case OrderStatusChangeSuccess:
        case OrderStatusChangeFailure:
            
        case OrderStatusCancelled:
        case OrderStatusCancelTimeOut:
        case OrderStatusClosed:
        case OrderStatusConfirmFailure:
            [marrButtons addObject:[self addCallCusttomButton]];
            break;
            
        case OrderStatusRunning:
            [marrButtons addObject:[self addChangeOrderButton]];
            [marrButtons addObject:[self addRefundButton]];
            break;
        case OrderStatusRefunding:
            [marrButtons addObject:[self addCancelRefundButton]];
            break;
        case OrderStatusChanging:
            [marrButtons addObject:[self addCancelChangeButton]];
            break;
            
        case OrderStatusToComment://评价、分享、再来一周
            [marrButtons addObject:[self addCommentButton]];
//            [marrButtons addObject:[self addShareWeekPlanButton]];
            [marrButtons addObject:[self addAgainWeekButton]];
            break;
        case OrderStatusDone:
//            [marrButtons addObject:[self addShareWeekPlanButton]];
            [marrButtons addObject:[self addAgainWeekButton]];
            break;
        default:
            break;
    }
    
    
    UIButton *preButton = nil;
    CGFloat buttonWidth = 75 *self.appdelegate.autoSizeScaleX;
    CGFloat buttonHeight = 30*self.appdelegate.autoSizeScaleY;
    CGFloat marginRight = -12*self.appdelegate.autoSizeScaleX;
    
    for (UIButton *button in marrButtons) {
        [_operateContainerView addSubview:button];
        if (preButton == nil) {
            [button makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_operateContainerView.centerY);
                make.right.equalTo(marginRight);
                make.width.equalTo(buttonWidth);
                make.height.equalTo(buttonHeight);
            }];
        }
        else {
            [button makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_operateContainerView.centerY);
                make.right.equalTo(preButton.mas_left).offset(marginRight);
                make.width.equalTo(buttonWidth);
                make.height.equalTo(buttonHeight);
            }];
        }
        preButton = button;
    }
   
}

- (void)removeAllSubViews {
    [_orderStatusContainerView removeFromSuperview];
    [_postContainerView removeFromSuperview];
    [_weekplansContailView removeFromSuperview];
    [_orderDetailContainerView removeFromSuperview];
    [_tipContainerView removeFromSuperview];
    [_operateContainerView removeFromSuperview];
}


#pragma mark - Action
- (void)requestDetailData {
    [MBProgressHUD showActivityWithText:self.view text:@"正在加载..." animated:YES];
    NSDictionary *dicParam = @{ @"orderId": self.orderID };
    
    __weak typeof(self) weakself  = self;
    if (self.detailTask) {
        [self.detailTask cancel];
    }
    self.detailTask = [[NRNetworkClient sharedClient] sendPost:@"order/detail" parameters:dicParam success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        weakself.notNetwokVisiable = NO;
        
        if (errorCode == 0) {
            weakself.model = [[NROrderDetailModel alloc] init];
            NSString *orderID = [res valueForKey:@"orderId"];
            weakself.model.orderId = orderID;
            NSNumber *orderStatusNum = [res valueForKey:@"status"];
            weakself.model.orderStatus = [orderStatusNum integerValue];
            NSString *statusDesc = [res valueForKey:@"statusString"];
            weakself.model.statusDesc = statusDesc;
            
            NSString *toAddr = [res valueForKey:@"toAddr"];
            NSString *toName = [res valueForKey:@"toName"];
            NSString *toPhone = [res valueForKey:@"toPhone"];
            weakself.model.toAddr = toAddr;
            weakself.model.toName = toName;
            weakself.model.toPhone = toPhone;
            
            NSString *startDate = [res valueForKey:@"startDate"];
            NSString *totalPrice = [res valueForKey:@"totalPrice"];
            NSString *coupon = [res valueForKey:@"coupon"];
            NSNumber *payTypeNum = [res valueForKey:@"payType"];
            PayType payType = [payTypeNum integerValue];
            NSString *createTime = [res valueForKey:@"createTime"];
            weakself.model.createTime = createTime;
            weakself.model.startDate = startDate;
            weakself.model.totalPrice = totalPrice;
            weakself.model.coupon  = coupon;
            weakself.model.payType = payType;
            
            NSString *dates = [res valueForKey:@"dates"];
            NSArray *dateArr = [dates componentsSeparatedByString:@","];
            weakself.model.orderDates = [NSMutableArray arrayWithArray:dateArr];
            
            weakself.model.marrMeals =  [NSMutableArray array];
            NSArray *arrMeal = [res valueForKey:@"meals"];
            for (NSDictionary *dicItem in arrMeal) {
                NRWeekSetMeal *weekSetMeal = [NRWeekSetMeal new];
                
                weekSetMeal.weekday = [arrMeal indexOfObject:dicItem]+1;
                weekSetMeal.mealImageUrl = [dicItem valueForKey:@"image"]; // 套餐图片
                NSArray *arrSetMeals = [dicItem valueForKey:@"setMeals"];
                weekSetMeal.setMealsDic = [NSMutableDictionary dictionaryWithCapacity:3];
                for (NSDictionary *dicMeal in arrSetMeals) {
                    NRDaySetmeal *setmeal = [NRDaySetmeal new];
                    NSNumber *typeNum = (NSNumber *)[dicMeal valueForKey:@"mealType"];
                    setmeal.dinnerType = [typeNum integerValue];
                    setmeal.arrSingleFoodNames = [dicMeal valueForKey:@"names"];
                    [weekSetMeal.setMealsDic setValue:setmeal forKey:[NSString stringWithFormat:@"%d", (int)setmeal.dinnerType]];
                }
                
                [weakself.model.marrMeals addObject:weekSetMeal];
            }
            
            [weakself removeAllSubViews];
            [weakself setupOrderStatus];
            [weakself setupPostInfo];
            [weakself setupMealImages];
            [weakself setupOrderDetail];
            [weakself setupTips];
            [weakself setupOperateView];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakself.notNetwokVisiable = YES;
        [weakself processRequestError:error];
    }];
}

- (void)updateOrderDetail {
    _orderStatusLabel.text = [NSString stringWithFormat:@"周计划%@", self.model.statusDesc];
    _orderAmountLabel.text = [NSString stringWithFormat:@"周计划金额: %@", self.model.totalPrice];
    _orderStartDateLabel.text = [NSString stringWithFormat:@"周计划生效日期: %@", self.model.startDate];
}

- (void)back:(id)sender {
    [self.innerSV setContentOffset:CGPointMake(0, 0) animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    
    //TODO: 不合适 去更新当前
//    if (self.weakOrderListVC && self.isChanged) {
//        [self.weakOrderListVC viewDidCurrentView];
//    }
}

- (void)willCallCustomer {
    NSString *callTitle = [NSString stringWithFormat:@"客服: %@", [NRGlobalManager sharedInstance].customerPhone];
    if (ISIOS8_OR_LATER) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *callCustomerAction = [UIAlertAction actionWithTitle: callTitle
                                                                     style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                                                                         [self telCustomer];
                                                                     }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"sheet closed");
        }];
        
        [alertController addAction:callCustomerAction];
        [alertController addAction:closeAction];
        [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:callTitle otherButtonTitles:nil];
        if (actionSheet) {
            actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
            [actionSheet showInView:self.view.window];
        }
    }
}


#pragma mark - OrderOperateAction
- (void)cancelOrderAction:(id)sender {
    // 取消订单
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否取消订单?" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alertView.tag = alertViewTag_cancelOrder;
    [alertView show];
}

- (void)doCancelOrder {
    [MBProgressHUD showActivityWithText:self.view text:@"取消订单..." animated:YES];
    NSDictionary *dicData = @{ @"orderId": self.orderID };
    
    WeakSelf(self);
    [[self.viewModel cancelOrderWithParametres:dicData] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        weakSelf.model.orderStatus = newMod.orderstatus;
        weakSelf.model.statusDesc = newMod.orderStatusDesc;
        //TODO: 这个返回的状态码不对，所有暂时硬刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateOrderDetail];
            [weakSelf setupOperateView];
            if (self.refreshCmd) {
                [self.refreshCmd execute:newMod];
            }
        });
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
        [MBProgressHUD showDoneWithText:weakSelf.view text:@"订单已取消"];
    }];
}

- (void)refundAction:(id)sender {
    WeakSelf(self);
    NRRefundOrderView *refundView = [[NRRefundOrderView alloc] initWithHeight:200.f delegate:nil];
    refundView.weakOrderDetailVC = self;
    refundView.refundCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [weakSelf doRefundWithParams:(NSDictionary *)input];
        return [RACSignal empty];
    }];
    
    refundView.orderMod = self.orderSimpleInfoMod;
    [refundView showInView:self.view];
    refundView.tag = 200;
}

- (void)doRefundWithParams:(NSDictionary *)params {
    WeakSelf(self);
    [MBProgressHUD showActivityWithText:weakSelf.view text:@"提交退款..." animated:YES];
    [[self.viewModel refundWithParametres:params] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        weakSelf.model.orderStatus = newMod.orderstatus;
        weakSelf.model.statusDesc = newMod.orderStatusDesc;
        weakSelf.model.startDate = newMod.startDate;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateOrderDetail];
            [weakSelf setupOperateView];
            if (self.refreshCmd) {
                [self.refreshCmd execute:newMod];
            }
        });
    } error:^(NSError *error) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        [weakSelf processRequestError:error];
    } completed:^{
        [MBProgressHUD showDoneWithText:weakSelf.view text:@"已提交退款"];
    }];
}

- (void)cancelRefundAction:(id)sender {
    // 取消退款
    [MBProgressHUD showActivityWithText:self.view text:@"正在取消退款..." animated:YES];
    NSDictionary *dicParam = @{ @"orderId": self.orderID };
    
    WeakSelf(self);
    [[self.viewModel cancelRefundWithParametres:dicParam] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        weakSelf.model.orderStatus = newMod.orderstatus;
        weakSelf.model.statusDesc = newMod.orderStatusDesc;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateOrderDetail];
            [weakSelf setupOperateView];
            if (weakSelf.refreshCmd) {
                [weakSelf.refreshCmd execute:newMod];
            }
        });
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
        [MBProgressHUD showDoneWithText:weakSelf.view text:@"已取消退款"];
    }];
}

- (void)changeOrderAction:(id)sender {
    WeakSelf(self);
    CGFloat height = (437.0+10)*kAppUIScaleY;
    _changeOrderView = [[NRChangeOrderCalendarView alloc] init];
    _changeOrderView.viewModel = self.viewModel;
    _changeOrderView.contentViewHeight =  height;
    _changeOrderView.orderInfoMod = self.orderSimpleInfoMod;
    _changeOrderView.msetOrderDates = [NSMutableSet setWithArray:self.model.orderDates];
    _changeOrderView.changeCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [weakSelf doChangeWithOrderModle:weakSelf.orderSimpleInfoMod newDates:(NSArray *)input];
        return [RACSignal empty];
    }];
    
    [_changeOrderView setupUI];
    [_changeOrderView showInView:KeyWindow];
    [_changeOrderView getWorkdays];
    _changeOrderView.tag = 100;
}

- (void)doChangeWithOrderModle:(NROrderInfoModel *)orderModel newDates:(NSArray *)newDates{
    NSDictionary *dicParam = @{@"orderId": orderModel.orderID,
                               @"newDates": newDates,
                               @"reason": @"测试理由"};
    WeakSelf(self);
    __weak typeof(NRChangeOrderCalendarView) *weakCalView = _changeOrderView;
    [MBProgressHUD showActivityWithText:weakCalView text:@"提交变更..." animated:YES];
    [[weakSelf.viewModel changeOrderWithParametres:dicParam] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakCalView animated:YES];
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        weakSelf.model.orderStatus = newMod.orderstatus;
        weakSelf.model.statusDesc = newMod.orderStatusDesc;
        weakSelf.model.startDate =  newMod.startDate;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateOrderDetail];
            [weakSelf setupOperateView];
            if (weakSelf.refreshCmd) {
                [weakSelf.refreshCmd execute:newMod];
            }
        });
        
    } error:^(NSError *error) {
        [MBProgressHUD hideActivityWithText:weakCalView animated:YES];
        [weakSelf processRequestError:error];
    } completed:^{
        [weakCalView dismiss];
        [MBProgressHUD showDoneWithText:KeyWindow text:@"已提交变更"];
    }];
}

- (void)cancelChangeAction:(id)sender {
    // 取消变更
    WeakSelf(self);
    NSDictionary *dicParam = @{ @"orderId": self.orderID };
    [MBProgressHUD showActivityWithText:self.view text:@"正在取消变更..." animated:YES];
    
    [[self.viewModel cancelChangeOrderWithParametres:dicParam] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        weakSelf.model.orderStatus = newMod.orderstatus;
        weakSelf.model.statusDesc = newMod.orderStatusDesc;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateOrderDetail];
            [weakSelf setupOperateView];
            if (weakSelf.refreshCmd) {
                [weakSelf.refreshCmd execute:newMod];
            }
        });
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
        [MBProgressHUD showDoneWithText:weakSelf.view text:@"已取消变更"];
    }];
}

- (void)commentAction:(id)sender {
    // 去评论
    WeakSelf(self);
    NRWeekPlanCommentViewController *commentVC = [[NRWeekPlanCommentViewController alloc] initWithOrderInfo:self.orderSimpleInfoMod];
    commentVC.refreshCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [weakSelf requestDetailData];
        return [RACSignal empty];
    }];
    commentVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)againWeekAction:(id)sender {
    // 再来一周
    NRPlaceOrderViewController *placeOrderVC = [[NRPlaceOrderViewController alloc] init];
    placeOrderVC.wptID = self.orderSimpleInfoMod.wptId;
    
    NRWeekPlanListItemModel *newCurrentMod = [[NRWeekPlanListItemModel alloc] init];
    newCurrentMod.arrWPSID = self.orderSimpleInfoMod.smwIds;
    newCurrentMod.theWeekPlanImageUrl = self.orderSimpleInfoMod.wpThemeImgURL;
    newCurrentMod.theWeekPlanName = self.orderSimpleInfoMod.wpName;
    placeOrderVC.currentMod = newCurrentMod;
    
    placeOrderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:placeOrderVC animated:YES];
}

- (void)shareWeekPlanAction:(id)sender {
    //TODO: 分享
}

- (void)telCustomer {
    // 提示：不要将webView添加到self.view，如果添加会遮挡原有的视图
    if (!_webView) {
          _webView = [[UIWebView alloc] init];
    }
    
    NSString *phoneNum = [NSString stringWithFormat:@"tel://%@", [NRGlobalManager sharedInstance].customerPhone];
    NSURL *url = [NSURL URLWithString:phoneNum];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
}

#pragma mark - UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self telCustomer];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == alertViewTag_cancelOrder && buttonIndex == 0) {
        [self doCancelOrder];
    }
}

#pragma mark - Property
- (UIButton *)createButton {
    UIButton *retButton = [UIButton buttonWithType:UIButtonTypeCustom];
    retButton.backgroundColor = [UIColor whiteColor];
    retButton.layer.cornerRadius = CornerRadius;
    retButton.layer.borderColor = RgbHex2UIColor(0xa0, 0xa0, 0xa0).CGColor;
    retButton.layer.borderWidth = 0.5;
    retButton.layer.masksToBounds = YES;
    [retButton setTitleColor:ColorBaseFont forState:UIControlStateNormal];
    retButton.titleLabel.font = SysFont(14);
    return retButton;
}

- (UIScrollView *)outerSV {
    if (_outerSV == nil) {
        CGRect rect =  CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 60 - NAV_BAR_HEIGHT);
        _outerSV = [[UIScrollView alloc] initWithFrame:rect];
        _outerSV.scrollEnabled = YES;
        _outerSV.clipsToBounds = NO;
        _outerSV.bounces = YES;
    }
    
    return _outerSV;
}

- (UIScrollView *)innerSV {
    if (_innerSV) {
        return _innerSV;
    }
    
    _innerSV = [[UIScrollView alloc] init];
    _innerSV.frame = CGRectMake(25, 10, self.view.bounds.size.width-50, 156*self.appdelegate.autoSizeScaleY);
    _innerSV.pagingEnabled  = YES;
    _innerSV.pagingEnabled = YES;
    _innerSV.clipsToBounds = NO;
    _innerSV.showsHorizontalScrollIndicator = NO;
    _innerSV.showsVerticalScrollIndicator = NO;
    _innerSV.scrollsToTop = YES;
    _innerSV.delegate = self;
    _innerSV.backgroundColor = RgbHex2UIColor(0xe2, 0xe2, 0xe2);
    return _innerSV;
}

- (NSMutableParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        _paragraphStyle.lineSpacing = 4.0f;
        _paragraphStyle.minimumLineHeight = 14.0f;
        _paragraphStyle.maximumLineHeight = 15.0f;
        _paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        _paragraphStyle.alignment = NSTextAlignmentLeft;
        _paragraphStyle.lineHeightMultiple = 1.0f;
//        _paragraphStyle.headIndent = 4.0f;
//        _paragraphStyle.firstLineHeadIndent = 24.0f;
    }
    return _paragraphStyle;
}

#pragma mark - OperateButtons
- (UIButton *)addCancelOrderButton {
    UIButton *cancelButton = [self createButton];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    return cancelButton;
}

- (UIButton *)addRefundButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"退款" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(refundAction:) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

- (UIButton *)addCancelRefundButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"取消退款" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(cancelRefundAction:) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

- (UIButton *)addChangeOrderButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"变更" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(changeOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

- (UIButton *)addCancelChangeButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"取消变更" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(cancelChangeAction:) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

- (UIButton *)addCommentButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"评价" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

- (UIButton *)addAgainWeekButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"再来一周" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(againWeekAction:) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

- (UIButton *)addShareWeekPlanButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"分享" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(shareWeekPlanAction:) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

- (UIButton *)addCallCusttomButton {
    UIButton *theButton = [self createButton];
    [theButton setTitle:@"客服" forState:UIControlStateNormal];
    [theButton addTarget:self action:@selector(telCustomer) forControlEvents:UIControlEventTouchUpInside];
    return theButton;
}

#pragma mark - Override
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
