//
//  NRPersonSettingViewController.m
//  Nourish
//
//  Created by gtc on 15/2/12.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRPersonSettingViewController.h"
#import "NRPersonSexSettingController.h"
#import "NRPersonAgeSettingController.h"
#import "NRPersonHeightSettingController.h"
#import "NRPersonWeightSettingController.h"
#import "NRLoginManager.h"

@interface NRPersonSettingViewController ()

@property (strong, nonatomic) NSMutableArray *marrMeuns;
@property (strong, nonatomic) NRLoginManager *loginManager;

@end


@implementation NRPersonSettingViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = @"个人设置";
    self.tableView.backgroundColor = ColorViewBg;
    [self setupRightMenuButton];
    
     _marrMeuns = [[NSMutableArray alloc] initWithCapacity:4];
    [_marrMeuns addObject:@"性别"];
    [_marrMeuns addObject:@"年龄"];
    [_marrMeuns addObject:@"身高"];
    [_marrMeuns addObject:@"体重"];
    
    self.loginManager = [NRLoginManager sharedInstance];
    self.userInfoModel = [[NRUserInfoModel alloc] init];
    self.userInfoModel.gender = self.loginManager.genderType;
    self.userInfoModel.age = [self.loginManager.age unsignedIntegerValue];
    self.userInfoModel.height = [self.loginManager.height unsignedIntegerValue];
    self.userInfoModel.weight = [self.loginManager.weight unsignedIntegerValue];
}

- (void)setupRightMenuButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(savePersonInfo:)];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, NRFont(FontNavBarButtonTextSize), NSFontAttributeName, nil];
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


#pragma mark - privateMethods

- (void)savePersonInfo:(id)sender {
    // 1.先校验
    NSMutableDictionary *mdicData = [NSMutableDictionary dictionary];
    [mdicData setValue:[NSNumber numberWithInteger:self.userInfoModel.gender] forKey:@"gender"];
    [mdicData setValue:[NSNumber numberWithInteger:self.userInfoModel.age] forKey:@"age"];
    [mdicData setValue:[NSNumber numberWithUnsignedInteger:self.userInfoModel.height] forKey:@"height"];
    [mdicData setValue:[NSNumber numberWithUnsignedInteger:self.userInfoModel.weight]  forKey:@"weight"];
    
    // TODO: 是否通知更新其他页用户信息
    // 2.保存提交
    [MBProgressHUD showActivityWithText:self.view text:@"保存中..." animated:YES];
    
    __weak typeof(self) weakself = self;
    [[NRNetworkClient sharedClient] sendPost:@"user/info/base/set" parameters:mdicData success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        
        if (errorCode == 0) {
             // 1.更新本页用户的信息
            [weakself.tableView reloadData];
            
            weakself.loginManager.age =  [mdicData valueForKey:@"age"];
            weakself.loginManager.height = [mdicData valueForKey:@"height"];
            weakself.loginManager.weight = [mdicData valueForKey:@"weight"];
            NSNumber *gender = [mdicData valueForKey:@"gender"];
            weakself.loginManager.genderType = [gender integerValue];
            
            [MBProgressHUD showDoneWithText:weakself.view text:@"保存成功！" completionBlock:nil];
            // ???? 感觉有点多余，其他页面直接每次都从userdefault中就可以了 2015-08-24 15:16:4
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section  == 0) {
        
        if (indexPath.row == 0) {
            NRPersonSexSettingController *sexVC = [[NRPersonSexSettingController alloc] initWithUserInfo:self.userInfoModel isfromRegister:NO];
            [self.navigationController pushViewController:sexVC animated:YES];
        }
        else if (indexPath.row == 1) {
             NRPersonAgeSettingController *ageVC = [[NRPersonAgeSettingController alloc] initWithUserInfo:self.userInfoModel isFromSexVC:NO];
            [self.navigationController pushViewController:ageVC animated:YES];
        }
        else if (indexPath.row == 2) {
            NRPersonHeightSettingController *heightVC = [[NRPersonHeightSettingController alloc] initWithUserInfo:self.userInfoModel isFromAgeVC:NO];
            [self.navigationController pushViewController:heightVC animated:YES];
        }
        else if (indexPath.row == 3) {
             NRPersonWeightSettingController *weightVC = [[NRPersonWeightSettingController alloc] initWithUserInfo:self.userInfoModel isFromHeightVC:NO];
            [self.navigationController pushViewController:weightVC animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40*self.appdelegate.autoSizeScaleY;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15*self.appdelegate.autoSizeScaleY;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.marrMeuns.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SettingsCell = @"PersonSettingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingsCell];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = NRFont(FontLabelSize);
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.font = SysFont(14);
    }
  
    cell.textLabel.text = [self.marrMeuns objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                if (self.userInfoModel.gender == GenderTypeMale) {
                    cell.detailTextLabel.text = @"男";
                }
                else
                    cell.detailTextLabel.text = @"女";
            }
                break;
            case 1:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu岁", (unsigned long)self.userInfoModel.age];
                break;
            case 2:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lucm", (unsigned long)self.userInfoModel.height];
                break;
            case 3:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lukg", (unsigned long)self.userInfoModel.weight];
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
