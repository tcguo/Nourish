//
//  NRAccountSettingsVC.m
//  Nourish
//
//  Created by gtc on 15/8/11.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAccountSettingsVC.h"
#import "NRBindPhoneViewController.h"
#import "NRModifyNicknameViewController.h"
#import "NRModifyPwdViewController.h"
#import "NRAccountUploadAvatarCell.h"
#import "NRLogoutCell.h"
#import "NRLoginManager.h"

@interface NRAccountSettingsVC ()<UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *marrTitles;
@property (nonatomic, strong) NSMutableArray *marrSubTitles;
@property (nonatomic, strong) UIImagePickerController *imagePC;
@property (nonatomic, weak) NRLoginManager *loginManager;
@property (nonatomic, weak) NSURLSessionDataTask *uploadTask;

@end

@implementation NRAccountSettingsVC

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = @"账号设置";
    self.tableView.backgroundColor = ColorViewBg;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:kNotiName_UpdateNickName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:kNotiName_UpdateBindPhone object:nil];
    [self setupUserInfo];
}

- (void)setupUserInfo {
    self.loginManager = [NRLoginManager sharedInstance];
    self.marrTitles = [NSMutableArray arrayWithCapacity:4];
    self.marrSubTitles = [NSMutableArray arrayWithCapacity:4];
    [self.marrTitles addObject:@"上传/修改头像"];
    [self.marrSubTitles addObject:@""];
    
    if (STRINGHASVALUE(self.loginManager.nickName)) {
        [self.marrTitles addObject:self.loginManager.nickName];
        [self.marrSubTitles addObject:@"修改"];
    }
    else {
        [self.marrTitles addObject:@"添加昵称"];
        [self.marrSubTitles addObject:@""];
    }
    
    [self.marrTitles addObject:@"修改账户密码"];
    [self.marrSubTitles addObject:@""];
    
    if (STRINGHASVALUE(self.loginManager.cellPhone)) {
        [self.marrTitles addObject:[NSString stringWithFormat:@"已绑定手机号%@", self.loginManager.cellPhone]];
        [self.marrSubTitles addObject:@"更换"];
    }
    else {
        [self.marrTitles addObject:@"绑定手机号"];
        [self.marrSubTitles addObject:@"绑定"];
    }
}

- (void)updateUserInfo {
    [self setupUserInfo];
    [self.tableView reloadData];
}

#pragma mark - Property
- (UIImagePickerController *)imagePC {
    if (!_imagePC) {
        _imagePC = [[UIImagePickerController alloc] init];
        _imagePC.delegate = self;
        _imagePC.allowsEditing = YES;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            _imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
             _imagePC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    return _imagePC;
}

#pragma mark - PrivateMethods
- (void)uploadAvatar {
    if (ISIOS8_OR_LATER) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *photographAction = [UIAlertAction actionWithTitle:@"立即拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self snapImage];
        }];
        
        UIAlertAction *localAlbumAction = [UIAlertAction actionWithTitle:@"从本地相册选" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self pickImage];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        
        [alertController addAction:photographAction];
        [alertController addAction:localAlbumAction];
        [alertController addAction:cancelAction];
        
        [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"立即拍照" otherButtonTitles: @"从本地相册选", nil];
        actionSheet.delegate = self;
        [actionSheet showInView:self.view];
    }
}

- (void)snapImage {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [MBProgressHUD showAlert:@"提示" msg:@"没有相机或相机不可用" delegate:nil cancelBtnTitle:@"确定"];
        return;
    }
    
    self.imagePC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePC animated:YES completion:nil];
    
}

- (void) pickImage {
    self.imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePC animated:YES completion:nil];
}

#pragma mark - Action
- (void)logoutAction:(id)sender {
    if (self.loginManager.isLogined) {
        //挽留一下下
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定退出？" message:@"退出登录后将无法查看订单，重新登录后\n即可查看" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alertView show];
    }
}

- (void)doLogout {
    // $$$$ 根据三方登录类型，执行不同的退出操
    // ???: 是否通知服务器注销用户
    // FIXME:
    
    //TODO: 清空本地所有用户信息
//    [[NRUserDefaultManager shareInstance] removeAll];
    
    [self.loginManager setToken:nil];
    [self.loginManager setSessionId:nil];
    [self.loginManager logoutUserInfo];
    
    // 发出全局通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_LogoutSuccess object:nil];
    [MBProgressHUD showDoneWithText:KeyWindow text:@"退出成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AccountCellIdetifier";
    if (indexPath.section == 1) {
        NRLogoutCell *cell = [[NRLogoutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
    
    if (indexPath.row == 0) {
        NRAccountUploadAvatarCell *avatarCell = [[NRAccountUploadAvatarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AvatarIdentifier"];
        [avatarCell updateUserAvatarWith:self.loginManager];
        avatarCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return avatarCell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        
        cell.detailTextLabel.text = [self.marrSubTitles objectAtIndex:indexPath.row];
        cell.detailTextLabel.font = NRFont(14);
        cell.detailTextLabel.textColor = ColorPlaceholderFont;
        cell.textLabel.text = [self.marrTitles objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = NRFont(FontLabelSize);
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.marrTitles.count;
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark  - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 60;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 30;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        // 退出登录
        [self logoutAction:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            [self uploadAvatar];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
            break;
        case 1:
        {
            NRModifyNicknameViewController *modifyNicknameVC = [[NRModifyNicknameViewController alloc] initWithNickName:self.loginManager.nickName];
            [self.navigationController pushViewController:modifyNicknameVC
                                                 animated:YES];
        }
            break;
        case 2:
        {
            NRModifyPwdViewController *modifyPwdVC = [[NRModifyPwdViewController alloc] init];
            [self.navigationController pushViewController:modifyPwdVC animated:YES];
        }
            break;
        case 3:
        {
            NRBindPhoneViewController *bindPhoneVC = [[NRBindPhoneViewController alloc] init];
            [self.navigationController pushViewController:bindPhoneVC animated:YES];
        }
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self snapImage];
    }
    else if (buttonIndex == 1) {
        [self pickImage];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    if (self.uploadTask) {
        [self.uploadTask cancel];
    }
    __weak typeof(self) weakself  = self;
    //提交保存
    NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
    [MBProgressHUD showActivityWithText:self.view text:@"正在上传..." animated:YES];
    
    self.uploadTask = [[NRNetworkClient sharedClient] sendUpload:@"user/info/avatar/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imgData name:@"file" fileName:@"1212" mimeType:@"image/*"];
        
    } success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
         [MBProgressHUD hideActivityWithText:self.view animated:YES];
        if (errorCode == 0) {
            [MBProgressHUD showDoneWithText:KeyWindow text:@"上传成功"];
            
            NSString *avatarUrl = [res valueForKey:@"url"];
            weakself.loginManager.avatarUrl = avatarUrl;
//            [self.userInfo archivedUserInfoData];
            [weakself setupUserInfo];
            [weakself.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_UpdateUserAvatar object:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString *errorMsg = [error.userInfo valueForKey:kErrorMsg];
        if (error.code == 2002) {
            //文件大小超过2M
            [MBProgressHUD showErrormsgWithoutIcon:weakself.view title:errorMsg detail:nil];
        }
        else if (error.code == 2003) {
            //不是图片
            [MBProgressHUD showErrormsgWithoutIcon:weakself.view title:errorMsg detail:nil];
        }
        else {
            [weakself processRequestError:error];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  {
    if (buttonIndex == 0) {
        //退出登录
        [self doLogout];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_UpdateNickName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName_UpdateBindPhone object:nil];
}

@end
