//
//  NRDayReportController.m
//  Nourish

//  诺食记---每日报告

//  Created by gtc on 15/1/30.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRDayReportController.h"
#import "NRSetmealDetailCell.h"
#import "UIImageView+WebCache.h"

#define BgColorOfCell RgbHex2UIColor(0xef, 0xf0, 0xea)

@implementation NRDayReportEnergyInfo

@end

@interface NRDayReportController ()<UITableViewDataSource, UITableViewDelegate>
{
    UIView *_tableHeaderView;
    
    UILabel *_themeLabel;
    UILabel *_themeIntroductionLabel;
    UILabel *_weekplanLabel;
    UILabel *_daythLabel;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *arrElements;
@property (strong, nonatomic) NSArray *arrElementVals;

@property (strong, nonatomic) NSMutableArray *marrElements;
@property (strong, nonatomic) NSMutableArray *marrElementVals;

@property (strong, nonatomic) UIButton *footerButton;

// session
@property (weak, nonatomic) NSURLSessionDataTask *reportTask;

@end

@implementation NRDayReportController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"每日报告";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    self.arrElements = [NSArray arrayWithObjects:@"热量", @"蛋白质", @"碳水化合物", @"脂肪", @"维生素", @"钠", @"纤维素", nil];
//    self.arrElementVals = [NSArray arrayWithObjects:@"100大卡", @"200克", @"300克", @"0.55克", @"1.20克", @"0.02克", @"0.50克", nil];
    
    self.marrElements = [NSMutableArray array];
//    self.marrElementVals = [NSMutableArray arrayWithArray:self.arrElementVals];
    
    [self requestData];
}

- (void)setDayInfo:(NRRecordDayInfo *)dayInfo {
    _dayInfo = dayInfo;
    [self setupControls];
    _themeLabel.text = _dayInfo.themeName;
    _themeIntroductionLabel.text = _dayInfo.themeContent;
    _weekplanLabel.text = _dayInfo.wpName;
    NSString *strDate = [NSDate stringFromDate:self.currentDate format:@"yyyy.MM.dd"];
    _daythLabel.text = [NSString stringWithFormat:@"第%ld天 %@", (unsigned long)_dayInfo.dayth, strDate];
}

- (void)setupControls {

    [self.view addSubview:self.tableView];
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 172)];
    self.tableView.tableHeaderView = _tableHeaderView;
    UIImageView *imgvUserInfo = [[UIImageView alloc] init];
    [_tableHeaderView addSubview:imgvUserInfo];
  
    [imgvUserInfo makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tableHeaderView.mas_top).offset(10);
        make.left.equalTo(_tableHeaderView.mas_left).offset(0);
        make.right.equalTo(_tableHeaderView.mas_right).offset(0);
        make.bottom.equalTo(_tableHeaderView.mas_bottom).offset(-15);
    }];
    
    int height = 294/2 *kAppUIScaleY;
    if (self.wuImageUrl.length != 0) {
        NSURL *url = [NSURL URLWithString:self.wuImageUrl];
        [imgvUserInfo sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:DefaultImageName] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            int scale = 2;
            if (SCREEN_WIDTH >400) {
                scale  = 3;
            }
            
            CGFloat rate = height/image.size.height;
            CGFloat y = (image.size.height - height)/2;
            CGImageRef cgimage = CGImageCreateWithImageInRect([image CGImage], CGRectMake(5, y*scale, (image.size.width-10)*scale, image.size.height*scale*rate));
            
            imgvUserInfo.image = [UIImage imageWithCGImage:cgimage];
        }];
    }
    
    UIView *maskView = [UIView new];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [imgvUserInfo addSubview:maskView];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(imgvUserInfo).width.insets(padding);
    }];
    
    // 主题
    _themeLabel = [UILabel new];
    _themeLabel.font = SysFont(19);
    _themeLabel.textColor = RgbHex2UIColor(0xff, 0xfe, 0x00);
    [maskView addSubview:_themeLabel];
    [_themeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(maskView.mas_top).offset(@36);
        make.left.equalTo(maskView.mas_left).offset(@58);
        make.height.equalTo(@19);
    }];
    
    _themeIntroductionLabel = [UILabel new];
    _themeIntroductionLabel.font = SysFont(12);
    _themeIntroductionLabel.textColor = [UIColor whiteColor];
    [maskView addSubview:_themeIntroductionLabel];
    [_themeIntroductionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_themeLabel.mas_bottom).offset(@6);
        make.left.equalTo(maskView.mas_left).offset(@58);
        make.height.equalTo(@12);
    }];
   
    UIImageView *riliImagv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record-rili"]];
//    riliImagv.contentMode = UIViewContentModeScaleAspectFit;
    [maskView addSubview:riliImagv];
    [riliImagv makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_themeIntroductionLabel.mas_bottom).offset(@12);
        make.left.equalTo(maskView.mas_left).offset(@58);
        make.height.equalTo(@33);
        make.width.equalTo(@33);
    }];
    
    _weekplanLabel = [UILabel new];
    _weekplanLabel.font = SysFont(14);
    _weekplanLabel.textColor = [UIColor whiteColor];
    [maskView addSubview:_weekplanLabel];
    [_weekplanLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(riliImagv.mas_top);
        make.left.equalTo(riliImagv.mas_right).offset(@5);
        make.height.equalTo(@14);
    }];

    _daythLabel = [UILabel new];
    _daythLabel.font = SysFont(14);
    _daythLabel.textColor = RgbHex2UIColor(0xff, 0xfe, 0x00);
    [maskView addSubview:_daythLabel];
    [_daythLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weekplanLabel.mas_bottom).offset(@5);
        make.left.equalTo(riliImagv.mas_right).offset(@5);
        make.height.equalTo(@14);
    }];
    
    self.footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.footerButton.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 38);
    [self.footerButton setTitle:@"更多营养元素" forState:UIControlStateNormal];
    [self.footerButton setTitle:@"没有更多了" forState: UIControlStateDisabled];
    [self.footerButton setTitleColor: RgbHex2UIColor(0xa0, 0xa0, 0xa2) forState:UIControlStateNormal];
    self.footerButton.titleLabel.font = SysFont(12);
    [self.footerButton addTarget:self action:@selector(appendElements:) forControlEvents:UIControlEventTouchUpInside];
    self.footerButton.backgroundColor = BgColorOfCell;
    self.tableView.tableFooterView = self.footerButton;
    self.footerButton.enabled = NO;
}

#pragma mark - Controls
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 0, self.view.bounds.size.width-10, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        // 为了防止tableView不能滑动到tabbar之上
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    }
    
    return _tableView;
}

#pragma mark - Action
- (void)requestData {
    NSString *strDate = [NSDate stringFromDate:self.currentDate format:nil];
    NSInteger nuo = self.isNuoxiaoshi ? 1 : 0;
    NSDictionary *dicParams = @{ @"nuo": [NSNumber numberWithInteger:nuo],
                                 @"date": strDate};
    
    [MBProgressHUD showActivityWithText:self.view text:@"加载中..." animated:YES];
    __weak typeof(self) weakself = self;
    if (self.reportTask) {
        [self.reportTask cancel];
    }
    self.reportTask = [[NRNetworkClient sharedClient] sendPost:@"mynourish/daily/report" parameters:dicParams success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
            
        NSArray *energylist = [res valueForKey:@"energyList"];
        for (NSDictionary *energy in energylist) {
            NSString *name = [energy valueForKey:@"name"];
            NSString *count = [energy valueForKey:@"count"];
            NSNumber *isStar = (NSNumber *)[energy valueForKey:@"star"];
            NRDayReportEnergyInfo *energyInfo = [[NRDayReportEnergyInfo alloc] init];
            energyInfo.name = name;
            energyInfo.count = count;
            energyInfo.isDayStar = [isStar boolValue];
            [weakself.marrElements addObject:energyInfo];
        }
        
        [weakself.tableView reloadData];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        [weakself processRequestError:error];
    }];
}

- (void)appendElements:(id)sender {
    // load more data
    if (self.footerButton.enabled == NO) {
        return;
    }
    
    [self requestData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.marrElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *DetailCellWithIdentifier = @"DetailCell";
    NRSetmealDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:DetailCellWithIdentifier];
    
    if (detailCell == nil) {
        detailCell = [[NRSetmealDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DetailCellWithIdentifier];
         detailCell.backgroundColor = RgbHex2UIColor(0xef, 0xf0, 0xea);
        detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger row = indexPath.row;
    NRDayReportEnergyInfo *energyInfo = (NRDayReportEnergyInfo*)[self.marrElements objectAtIndex:row];
    detailCell.lblName.text = energyInfo.name;
    detailCell.lblText.text = energyInfo.count;
    detailCell.isLeadActor = energyInfo.isDayStar;
    
    return detailCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30*kAppUIScaleY;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 25);
    headerView.backgroundColor = BgColorOfCell;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.textColor = RgbHex2UIColor(0XA0, 0XA0, 0XA2);
    nameLabel.font = SysFont(13);
    nameLabel.text = @"营养元素";
    [headerView addSubview:nameLabel];
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView.centerY);
        make.left.equalTo(10);
        make.height.equalTo(@13);
    }];
    
    UILabel *valueLabel = [UILabel new];
    valueLabel.textColor = RgbHex2UIColor(0XA0, 0XA0, 0XA2);
    valueLabel.font = SysFont(13);
    valueLabel.text = @"总量";
    [headerView addSubview:valueLabel];
    [valueLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView.centerY);
        make.centerX.equalTo(headerView.centerX);
        make.height.equalTo(@13);
    }];
    
    UILabel *actorLabel = [UILabel new];
    actorLabel.textColor = RgbHex2UIColor(0XA0, 0XA0, 0XA2);
    actorLabel.font = SysFont(13);
    actorLabel.text = @"今日主角";
    [headerView addSubview:actorLabel];
    [actorLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView.centerY);
        make.right.equalTo(headerView.mas_right).offset(-10);
        make.height.equalTo(@13);
    }];
    
    return headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



