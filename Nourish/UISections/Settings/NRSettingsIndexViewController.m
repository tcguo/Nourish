//
//  NRSettingsViewController.m
//  Nourish
//  设置
//  Created by gtc on 15/1/5.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRSettingsIndexViewController.h"
#import "BMButton.h"

#import "NRMsgSettingViewController.h"
#import "NRTimeSettingViewController.h"
#import "NRAddrSettingViewController.h"
#import "NRPersonSettingViewController.h"
#import "NRAboutViewController.h"
#import "NRLoginViewController.h"
#import "NRNavigationController.h"

#import "NRAccountSettingsVC.h"
#import "NRSettingsIndexAccountCell.h"
#import "NRSettingsIndexAccountNotLoginCell.h"
#import "NRSettingsListItemCell.h"
#import "NRImageAndTitleCell.h"
#include "NRLoginManager.h"

@interface NRSettingsIndexViewController ()<LoginDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImageView *_avatarImgv;
    UILabel *_nicknameLabel;
    UILabel *_bindPhoneLabel;
    UIWebView *_webView;
}

@property (strong, nonatomic) NSMutableArray *marrMeuns;
@property (strong, nonatomic) NSArray *arrMeunIcons;
@property (strong, nonatomic) NSIndexPath *willSelIndexPath;
@property (strong, nonatomic) BMButton *logoutButton;
@property (strong, nonatomic) NRNavigationController *tempNC;
@property (strong, nonatomic) NRPersonSettingViewController *personsVC;
@property (strong, nonatomic) NRMsgSettingViewController *msgsVC;
@property (strong, nonatomic) NRTimeSettingViewController *timesVC;
@property (strong, nonatomic) NRAddrSettingViewController *addrsVC;

@property (strong, nonatomic) UIImagePickerController *imagePC;
@property (weak, nonatomic) NRLoginManager *loginManager;

@end

@implementation NRSettingsIndexViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kNotiName_LoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess) name:kNotiName_LogoutSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserAvatar) name:kNotiName_UpdateUserAvatar object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserNickName) name:kNotiName_UpdateNickName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBindPhone) name:kNotiName_UpdateBindPhone object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    
    self.navigationItem.title = @"设置";
    self.tableView.backgroundColor = ColorViewBg;
    self.willSelIndexPath = nil;
    self.loginManager = [NRLoginManager sharedInstance];
    
    self.marrMeuns = [[NSMutableArray alloc] initWithCapacity:6];
//    [self.marrMeuns addObject:@"消息设置"];
//    [self.marrMeuns addObject:@"配送时间"];
    [self.marrMeuns addObject:@"地址设置"];
    [self.marrMeuns addObject:@"个人设置"];
//    [self.marrMeuns addObject:@"检查更新"]; @"iconfont-updateversion",
    [self.marrMeuns addObject:[NSString stringWithFormat:@"喜欢%@？去评个分吧", APPNAME]];
    [self.marrMeuns addObject:[NSString stringWithFormat:@"关于%@", APPNAME]];

    self.arrMeunIcons = @[ @"iconfont-message", @"iconfont-distributionTime", @"iconfont-address", @"iconfont-personsetting",
                           @"iconfont-like", @"iconfont-about" ];
}

- (void)setupControls {
    CGFloat height = SCREEN_HEIGHT - NAV_BAR_HEIGHT - 128*self.appdelegate.autoSizeScaleY - 40*self.appdelegate.autoSizeScaleY*6 - 40;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    [footerView addSubview:self.logoutButton];
    
    [self.logoutButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(15);
        make.right.equalTo(-15);
        make.height.equalTo(40);
        make.top.equalTo(footerView.mas_bottom).offset(-50);
    }];
    
    self.tableView.tableFooterView = footerView;
}


#pragma mark - Controls
- (UIImagePickerController *)imagePC {
    if (!_imagePC) {
        _imagePC = [[UIImagePickerController alloc] init];
        _imagePC.delegate = self;
        _imagePC.allowsEditing = YES;
    }
    
    return _imagePC;
}

#pragma mark - Action
- (void)login {
    NRLoginViewController *loginVC = [NRLoginViewController sharedInstance];
    loginVC.hidesBottomBarWhenPushed = YES;
    
    self.tempNC = [[NRNavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:self.tempNC animated:YES completion:nil];
}

- (void)callCustomer {
    // 提示：不要将webView添加到self.view，如果添加会遮挡原有的视图
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
    }
    
    NSString *phoneNum = [NSString stringWithFormat:@"tel://%@", [NRGlobalManager sharedInstance].customerPhone];
    NSURL *url = [NSURL URLWithString:phoneNum];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
}


#pragma mark - Helper
- (void)enterControllerByIndexPath:(NSIndexPath *)idxPath {
    if (idxPath == nil || idxPath.section == 0) {
        return;
    }
    
    switch (idxPath.row) {
//        case 0:
//        {
//            self.msgsVC = [[NRMsgSettingViewController alloc] init];
//            self.msgsVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:self.msgsVC animated:YES];
//        }
//            break; 
//        case 1:
//        {
//            self.timesVC = [[NRTimeSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
//            self.timesVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:self.timesVC animated:YES];
//        }
//            break;
            
        case 0:
        {
            self.addrsVC = [[NRAddrSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
            self.addrsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:self.addrsVC animated:YES];
        }
            break;
            
        case 1:
        {
            self.personsVC = [[NRPersonSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
            self.personsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:self.personsVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //    NSString *const  UIImagePickerControllerMediaType ;指定用户选择的媒体类型（文章最后进行扩展）
    //    NSString *const  UIImagePickerControllerOriginalImage ;原始图片
    //    NSString *const  UIImagePickerControllerEditedImage ;修改后的图片
    //    NSString *const  UIImagePickerControllerCropRect ;裁剪尺寸
    //    NSString *const  UIImagePickerControllerMediaURL ;媒体的URL
    //    NSString *const  UIImagePickerControllerReferenceURL ;原件的URL
    //    NSString *const  UIImagePickerControllerMediaMetadata;当来数据来源是照相机的时候这个值才有效
    
    UIImage *theImage = nil;
    if ([picker allowsEditing]){
        //获取用户编辑之后的图像
        theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        _avatarImgv.image = theImage;
        // 异步上传
    } else {
        // 照片的元数据参数
        theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.loginManager.isLogined) {
            NRAccountSettingsVC *accountVC = [[NRAccountSettingsVC alloc] initWithStyle:UITableViewStyleGrouped];
            accountVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:accountVC animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        //判断是否登录
        if (!self.loginManager.isLogined) {
            self.willSelIndexPath = indexPath;
            NRLoginViewController *loginVC = [NRLoginViewController sharedInstance];
            loginVC.hidesBottomBarWhenPushed = YES;
            
            self.tempNC = [[NRNavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:self.tempNC animated:YES completion:nil];
        }
        else {
            [self enterControllerByIndexPath:indexPath];
        }
        
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSString *url = [NSString stringWithFormat:@"%@%@", NR_APP_STORE_SOCRE_NEWURL, NR_APP_STORE_APPLEID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        else {
            NRAboutViewController *aboutVC = [[NRAboutViewController alloc] init];
            aboutVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
    }
    else if (indexPath.section == 3) {
        [self callCustomer];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 128*kAppUIScaleY;
    }
    
    return 40*kAppUIScaleY;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.001;
    }
    else if (section == 3) {
        return 80;
    }
    else
        return 10;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    else if (section == 1) {
        return 10;
    }
    else
        return 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 2;
    }
    else if (section == 2) {
        return 2;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SettingsCell = @"SettingCell";
    static NSString *SettingsAccountCell = @"SettingsAccountCell";
    
    NRSettingsListItemCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (self.loginManager.isLogined) {
            NRSettingsIndexAccountCell *accountCell = [[NRSettingsIndexAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsAccountCell];
            accountCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [accountCell updateUserInfo];
            return accountCell;
        }
        else {
            NRSettingsIndexAccountNotLoginCell *noLoginCell = [[NRSettingsIndexAccountNotLoginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsAccountCell];
            noLoginCell.settingsIndexVC = self;
            noLoginCell.accessoryType = UITableViewCellAccessoryNone;
            return noLoginCell;
        }
    }
    else if (indexPath.section == 3) {
        NRImageAndTitleCell *phoneCell = [[NRImageAndTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        phoneCell.iconImageView.image = [UIImage imageNamed:@"iconfont-dianhua"];
        
        phoneCell.titleLabel.text = [NSString stringWithFormat:@"客服: %@", [NRGlobalManager sharedInstance].customerPhone];
        phoneCell.titleLabel.font = SysFont(16);
        phoneCell.titleLabel.textAlignment = NSTextAlignmentLeft;
        phoneCell.titleLabel.textColor = ColorRed_Normal;
        
        return phoneCell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:SettingsCell];
        if (!cell) {
            cell = [[NRSettingsListItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsCell];
        }
        
        if (indexPath.section == 1) {
            cell.textLabel.text = [self.marrMeuns objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:[self.arrMeunIcons objectAtIndex:indexPath.row]];
          
        }
        else {
            cell.textLabel.text = [self.marrMeuns objectAtIndex:indexPath.row+2];
            cell.imageView.image = [UIImage imageNamed:[self.arrMeunIcons objectAtIndex:indexPath.row+4]];
        }
        
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.font = NRFont(FontLabelSize);
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

#pragma mark - Notification
- (void)loginSuccess {
    [self.tableView reloadData];
    [self enterControllerByIndexPath:self.willSelIndexPath];
}

- (void)logoutSuccess {
    [self.tableView reloadData];
}

- (void)updateUserAvatar {
    [self.tableView reloadData];
}

- (void)updateUserNickName {
    [self.tableView reloadData];
}

- (void)updateBindPhone {
    [self.tableView reloadData];
}

#pragma mark - Override

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_UpdateUserAvatar object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_UpdateNickName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_LoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_LogoutSuccess object:nil];
}

@end
