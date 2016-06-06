//
//  NRAboutViewController.m
//  Nourish
//
//  Created by gtc on 15/2/12.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAboutViewController.h"

@interface NRAboutViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *iconImages;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *subTitles;

@end

@implementation NRAboutViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = [NSString stringWithFormat:@"关于%@", APPNAME];
    // Do any additional setup after loading the view.
    self.iconImages = @[ @"about-icon-wechat", @"about-icon-weibo", @"about-icon-qq" ];
    self.titles = @[ @"微信公众号", @"微博", @"QQ 交流群" ];
    self.subTitles = @[ @"诺食计", @"@诺食计营养周", @"181269748" ];
    [self.view addSubview:self.tableView];
    [self setupHeaderView];
    [self setupFooterView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)setupHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 375/2)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-login"]];
    logoView.contentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:logoView];
    [logoView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(40);
        make.centerX.equalTo(headerView.centerX);
        make.height.and.width.equalTo(81);
    }];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    [headerView addSubview:versionLabel];
    versionLabel.textColor = RgbHex2UIColor(0x46, 0x46, 0x46);
    versionLabel.font = SysBoldFont(FontLabelSize);
    [versionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView.centerX);
        make.height.equalTo(16);
        make.top.equalTo(logoView.mas_bottom).offset(15);
    }];
    versionLabel.text = [NSString stringWithFormat:@"%@ %@",APPNAME, NourishVersion];
}

- (void)setupFooterView {
    CGFloat height = SCREEN_HEIGHT - NAV_BAR_HEIGHT - 375/2 - 4*50;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = footerView;
    
    UILabel *companyNameLabel = [[UILabel alloc] init];
    [footerView addSubview:companyNameLabel];
    [companyNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footerView);
        make.height.equalTo(13);
        make.top.equalTo(footerView.mas_bottom).offset(-45);
    }];
    companyNameLabel.textColor = RgbHex2UIColor(0x46, 0x46, 0x46);
    companyNameLabel.font = SysFont(12);
    companyNameLabel.text = @"诺食计（北京）科技有限公司";
    
    UILabel *websiteLabel = [[UILabel alloc] init];
    [footerView addSubview:websiteLabel];
    [websiteLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footerView);
        make.height.equalTo(10);
        make.top.equalTo(companyNameLabel.mas_bottom).offset(10);
    }];
    websiteLabel.textColor = RgbHex2UIColor(0x46, 0x46, 0x46);
    websiteLabel.font = SysFont(10);
    websiteLabel.text = @"www.51nourish.com";
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- NAV_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.scrollsToTop = YES;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *aboutIdentifier = @"aboutIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:aboutIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:aboutIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = RgbHex2UIColor(0x84, 0x84, 0x84);
        cell.detailTextLabel.textColor = RgbHex2UIColor(0x4d, 0x4d, 0x4d);
    }
    
    if (indexPath.row == 3) {
        return cell;
    }
    
    UIImage *image = [UIImage imageNamed:[self.iconImages objectAtIndex:indexPath.row]];
    cell.imageView.image = image;
    cell.textLabel.text = [self.titles objectAtIndex:indexPath.row];
   
    cell.detailTextLabel.text = [self.subTitles objectAtIndex:indexPath.row];
   
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
