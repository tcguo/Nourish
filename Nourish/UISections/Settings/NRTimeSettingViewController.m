//
//  NRTimeSettingViewController.m
//  Nourish
//
//  Created by gtc on 15/2/12.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRTimeSettingViewController.h"
#import "NRTimetSettingsLXActionSheet.h"

//NSString *const kFTAnimationName12 = @"kFTAnimationName";

@interface NRTimeSettingViewController ()<UITableViewDataSource, UITableViewDelegate, LXActionSheetDelegate>
@property (nonatomic, strong) NRTimetSettingsLXActionSheet *actionSheet;
@property (strong, nonatomic) NSArray *arrDinnerTitles;
@property (strong, nonatomic) NSMutableArray *marrTimes;
@property (strong, nonatomic) NSMutableArray *marrSettingTimes;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (assign, nonatomic) NSInteger *selectedButtonIndex;

@end

@implementation NRTimeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    self.navigationItem.title = @"时间设置";
    // Do any additional setup after loading the view.
    
    self.arrDinnerTitles = [NSArray arrayWithObjects:@"早餐", @"午餐", @"下午茶", nil];
    self.marrTimes = [NSMutableArray arrayWithCapacity:3];
    NSArray *arrZaoTimes = [NSArray arrayWithObjects:@"6:00-6:30", @"6:30-7:00", @"7:00-7:30", nil];
    NSArray *arrWuTimes = [NSArray arrayWithObjects:@"11:00-11:30",@"11:30-12:00",@"12:00-12:30", nil];
    NSArray *arrChaTimes = [NSArray arrayWithObjects:@"15:00-15:30",@"15:30-16:00",@"16:00-16:30", nil];
    [self.marrTimes addObject:arrZaoTimes];
    [self.marrTimes addObject:arrWuTimes];
    [self.marrTimes addObject:arrChaTimes];
    
    self.marrSettingTimes = [NSMutableArray arrayWithObjects:arrZaoTimes.firstObject, arrWuTimes.firstObject, arrChaTimes.firstObject, nil];
    
    self.tableView.backgroundColor = ColorViewBg;
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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TimeSettingsIdentifier = @"TimeSettingsIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TimeSettingsIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TimeSettingsIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = ColorBaseFont;
    cell.textLabel.font = SysFont(FontLabelSize);
    
    cell.textLabel.text = [self.marrSettingTimes objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = self.arrDinnerTitles[indexPath.row];
    cell.detailTextLabel.font = NRFont(12);
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.actionSheet = [[NRTimetSettingsLXActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:self.marrTimes[indexPath.row]];
    [self.actionSheet showInView:self.view];
    
    self.selectedIndexPath = indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

#pragma mark - LXActionSheetDelegate

- (void)didClickOnButtonIndex:(NSInteger)buttonIndex
{
    if (self.selectedIndexPath) {
        NSString *time =  [self.marrTimes[self.selectedIndexPath.row] objectAtIndex:buttonIndex];
        [self.marrSettingTimes replaceObjectAtIndex:self.selectedIndexPath.row withObject:time];
    }
    
    [self.tableView reloadData];
}

- (void)didClickOnCancelButton
{
    
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
