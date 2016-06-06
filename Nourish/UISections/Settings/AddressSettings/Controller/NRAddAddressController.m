//
//  NRAddAddressController.m
//  Nourish
//
//  Created by gtc on 15/3/6.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRAddAddressController.h"
#import "NRAddrWriteCell.h"
#import "NRAddrSelectCell.h"
#import "LXActivity.h"
#import "NRHideKeyBoard.h"
#include "NRLoginManager.h"
#import "NRAddressViewModel.h"

#define kAddrProvine  @"kAddrProvine"
#define kAddrCity  @"kAddrCity"
#define kAddrDis  @"kAddrDis"
#define kAddrTown  @"kAddrTown"

#import "NRWriteAddressViewController.h"

@interface NRAddAddressController ()
{
//    LXActivity *_activityViewForProvince;
//    LXActivity *_activityViewForStreet;
}
@property (nonatomic, assign) AddrOperateType operateType;

@property (nonatomic, strong) NSMutableArray *marrTitles;
@property (nonatomic, strong) NSMutableArray *marrPlaceHolders;
@property (nonatomic, strong) NRAddressViewModel *viewModel;

@end

@implementation NRAddAddressController

- (id)initWithStyle:(UITableViewStyle)style operateType:(AddrOperateType)type {
    self = [super initWithStyle:style];
    if (self) {
         self.operateType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.tableView.backgroundColor = ColorViewBg;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = ColorViewBg;
    self.tableView.tableFooterView = footerView;
    
    self.marrTitles = [NSMutableArray arrayWithCapacity:4];
    [self.marrTitles addObject:@"姓名:"];
    [self.marrTitles addObject:@"电话:"];
    [self.marrTitles addObject:@"收货地址:"];
    [self.marrTitles addObject:@"详细地址:"];

    self.marrPlaceHolders = [NSMutableArray arrayWithCapacity:4];
    [self.marrPlaceHolders addObject:@"你的姓名"];
    [self.marrPlaceHolders addObject:@"配送人员联系你的电话"];
    [self.marrPlaceHolders addObject:@"办公楼学校、小区、街道"];
    [self.marrPlaceHolders addObject:@"请输入写字楼具体位置"];
   
    if (self.operateType == AddrOperateTypeAdd) {
        self.navigationItem.title = @"新增地址";
        self.editModel = [[NRDistributionAddrModel alloc] init];
    }else {
        self.navigationItem.title = @"编辑地址";
    }
    
    [self setupRightNavButtonWithTitle:@"保存" action:@selector(save:)];
//    [self requestRegeo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

//- (UIToolbar *)createTooBar:(NSString *)selectorName
//{
//    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
////    [toolBar setBarStyle:UIBarStyleBlackTranslucent];
////    toolBar.barTintColor = ColorViewBg;
//    
//     UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    
//    SEL sel = NSSelectorFromString(selectorName);
//    UIBarButtonItem * barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:sel];
//    
//    toolBar.items = @[spaceItem, barButtonDone];
//    barButtonDone.tintColor = ColorRed_Normal;
//    
//    return toolBar;
//}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //分割线充满左右
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Action
- (void)save:(id)sender {
    [self hideKeyBoard];
    
    NSArray *arrCells = self.tableView.visibleCells;
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:2 inSection:0];
    NRAddrSelectCell *seleCell = (NRAddrSelectCell*)[self.tableView cellForRowAtIndexPath:idxPath];
    self.editModel.poiName = seleCell.textField.text;
    if (self.editModel.poiName.length == 0) {
        [MBProgressHUD showAlert:@"提示" msg:@"请填写收货地址" delegate:nil cancelBtnTitle:@"确定"];
        return;
    }
    
    for (UITableViewCell *cell in arrCells) {
        NRAddrWriteCell *newCell = (NRAddrWriteCell *)cell;
        switch (newCell.textField.tag) {
            case 0:
                self.editModel.name = newCell.textField.text;
                if (self.editModel.name.length == 0) {
                    [MBProgressHUD showAlert:@"提示" msg:@"请输入姓名" delegate:nil cancelBtnTitle:@"确定"];
                    return;
                }
                break;
            case 1:
                self.editModel.phone = newCell.textField.text;
                if ( self.editModel.phone.length == 0) {
                    [MBProgressHUD showAlert:@"提示" msg:@"请输入手机号码，以便配送人员联系你" delegate:nil cancelBtnTitle:@"确定"];
                    return;
                }
                break;
            case 3:
                self.editModel.detailAddress = newCell.textField.text;
                if (self.editModel.detailAddress.length == 0) {
                    [MBProgressHUD showAlert:@"提示" msg:@"请输入详细地址" delegate:nil cancelBtnTitle:@"确定"];
                    return;
                }
                break;
            default:
                break;
        }
    }
    
    NSNumber *addrId = self.operateType == AddrOperateTypeEdit ? [NSNumber numberWithInteger:self.editModel.addressID] : [NSNumber numberWithInteger:0];
    GenderType gender = [[NRLoginManager sharedInstance] genderType];
    NSDictionary *dicParam = @{ @"id": addrId,
                                @"name": self.editModel.name,
                                @"phone": self.editModel.phone,
                                @"gender": [NSNumber numberWithInteger:gender],
                                @"adcode":[NSNumber numberWithInteger:[self.editModel.adcode integerValue]],
                                @"poiName": self.editModel.poiName,
                                @"poiAddress": STRINGHASVALUE(self.editModel.poiAddress)?self.editModel.poiAddress : @"",
                                @"poiType": self.editModel.poiType == nil? @"test":self.editModel.poiType,
                                @"detail": self.editModel.detailAddress,
                                @"x":[NSNumber numberWithDouble:self.editModel.longitude],
                                @"y":[NSNumber numberWithDouble: self.editModel.latitude]
                              };
    
    [MBProgressHUD showActivityWithText:self.view text:@"保存中..." animated:YES];
    __weak typeof(self) weakself = self;
    [[self.viewModel upsertWithParameters:dicParam] subscribeNext:^(id x) {
        NSNumber *successNumber = (NSNumber *)x;
        [MBProgressHUD hideHUDForView:weakself.view animated:NO];
        if ([successNumber boolValue]) {
            [MBProgressHUD showDoneWithText:KeyWindow text:@"保存成功"];
            [weakself.navigationController popViewControllerAnimated:YES];
            //刷新地址列表
            if([weakself.delegate respondsToSelector:@selector(addAddressCompleted)]) {
                [weakself.delegate addAddressCompleted];
            }
        }else {
            [MBProgressHUD showErrormsg:KeyWindow msg:@"保存失败"];
        }
    } error:^(NSError *error) {
        [weakself processRequestError:error];
    } completed:^{
    }];
}

- (void)hideKeyBoard {
    NSArray *arrCells = self.tableView.visibleCells;
    
    for (UITableViewCell *cell in arrCells) {
        NRAddrWriteCell *newCell = (NRAddrWriteCell *)cell;
        [newCell.textField resignFirstResponder];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ReuseIdtifierForAddAddr = @"reuseIdtifierForAddAddr";
    static NSString *ReuseIdtifierForAddAddr_AutoLocation = @"ReuseIdtifierForAddAddr_AutoLocation";

    if (indexPath.row == 2) {
        NRAddrSelectCell *seleCell = [[NRAddrSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdtifierForAddAddr_AutoLocation];
        seleCell.textField.enabled = NO;
        seleCell.textField.placeholder = [self.marrPlaceHolders objectAtIndex:indexPath.row];
        seleCell.textField.tag = indexPath.row;
        seleCell.selectionStyle = UITableViewCellSelectionStyleNone;
        seleCell.titleLabel.text = [self.marrTitles objectAtIndex:indexPath.row];
        seleCell.textField.text = self.editModel.poiName;
        seleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return seleCell;
    }
    
    NRAddrWriteCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdtifierForAddAddr];
    if (!cell) {
        cell = [[NRAddrWriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdtifierForAddAddr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textField.placeholder = [self.marrPlaceHolders objectAtIndex:indexPath.row];
    cell.textField.tag = indexPath.row;
    cell.titleLabel.text = [self.marrTitles objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        if (self.operateType == AddrOperateTypeEdit) {
            cell.textField.text = self.editModel.name;
        }
    }
    else if (indexPath.row == 1) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        if (self.operateType == AddrOperateTypeEdit) {
            cell.textField.text = self.editModel.phone;
        }
    }
    else {
        cell.textField.enabled = YES;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        if (self.operateType == AddrOperateTypeEdit) {
            cell.textField.text = self.editModel.detailAddress;
        }
    }
    
    [cell relayoutSubviews];
    return cell;
}

#pragma mark -  UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2 ) {
        [self hideKeyBoard];
        NRWriteAddressViewController *writeVC = [[NRWriteAddressViewController alloc] init];
        writeVC.weakAddAddrVC = self;
        writeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:writeVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 80;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    
    return 7.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 7.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = ColorViewBg;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = ColorViewBg;
    return view;
}

#pragma mark - Property
- (NRAddressViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NRAddressViewModel alloc] init];
    }
    return _viewModel;
}

#pragma mark - UIPickerViewDataSource

/*

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 1000) {
        return 3;
    }
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1000) {
        switch (component) {
            case 0:
                return [self.marrProvinces count];
                break;
            case 1:
                return [self.marrCities count];
                break;
            case 2:
                return [self.marrDistricts count];
                break;
                
            default:
                break;
        }
    }
    
    return [self.marrTowns count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1000) {
        switch (component) {
            case 0:
                return ((NRAreaModel *)[self.marrProvinces objectAtIndex:row]).name;
                break;
            case 1:
                return ((NRAreaModel *)[self.marrCities objectAtIndex:row]).name;
                break;
            case 2:
                return ((NRAreaModel *)[self.marrDistricts objectAtIndex:row]).name;
                break;
                
            default:
                break;
        }
    }
    
    return ((NRAreaModel *)[self.marrTowns objectAtIndex:row]).name;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
//        pickerLabel.minimumFontSize = 8.;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
//        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [pickerLabel setFont:SysFont(15)];
    }
    // Fill the label text here
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger selrow = [pickerView selectedRowInComponent:component];
    if (pickerView.tag == 1000) {
        switch (component) {
            case 0:
            {
                NRAreaModel *mod = [self.marrProvinces objectAtIndex:row];
                self.selProv = mod.name;
                self.selProvAdcode = [NSString stringWithFormat:@"%d", mod.ID];
                [self.marrCities removeAllObjects];
                [self.marrCities addObjectsFromArray:[NRAreaTableTool queryByParentID:mod.ID andLevel:2].allValues];
                [pickerView reloadComponent:component+1];
            }
                break;
            case 1:
            {
                NRAreaModel *mod = [self.marrCities objectAtIndex:row];
                self.selCity = mod.name;
                self.selCityAdcode = [NSString stringWithFormat:@"%d", mod.ID];
                [self.marrDistricts removeAllObjects];
                [self.marrDistricts addObjectsFromArray:[NRAreaTableTool queryByParentID:mod.ID andLevel:3].allValues];
                [pickerView reloadComponent:component+1];
            }
                break;
            case 2:
            {
                NRAreaModel *mod = [self.marrDistricts objectAtIndex:row];
                self.selDis = mod.name;
                self.selDisAdcode = [NSString stringWithFormat:@"%d", mod.ID];
                [self.marrTowns removeAllObjects];
                [self.marrTowns addObjectsFromArray:[NRAreaTableTool queryByParentID:mod.ID andLevel:4].allValues];
                [self.streetPickerView reloadAllComponents];
                [self.streetPickerView selectRow:0 inComponent:0 animated:NO];
                
            }
                break;
                
            default:
                break;
        }
    }
    else {
        NRAreaModel *mod = [self.marrTowns objectAtIndex:selrow];
        self.selTown = mod.name;
        self.selTownAdcode = [NSString stringWithFormat:@"%d", mod.ID];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (pickerView.tag == 1000) {
        if (component == 0) {
            return 100;
            return 110/320 *self.view.bounds.size.width;
        }
        else if (component == 1) {
            return 120;
            return 100/320 * self.view.bounds.size.width;
        }
        else{
            return 100;
            return 110/320 *self.view.bounds.size.width;
        }
    }
    
    return self.view.bounds.size.width;
}
 
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
