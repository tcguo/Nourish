//
//  NROrderCommentController.m
//  Nourish
//
//  Created by gtc on 15/3/17.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderCommentController.h"
#import "BMButton.h"
#import "NROrderCommentCell.h"
#import "NROrderCommentProvider.h"

@interface NROrderCommentController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readwrite, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *dateForComment;
@property (nonatomic, strong) NROrderCommentProvider *provider;
@property (nonatomic, assign) BOOL isCommented;

@end

@implementation NROrderCommentController

- (instancetype)initWithDate:(NSString *)date {
    self = [super init];

    if (self) {
        _dateForComment = date;
        _isCommented = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"发表评论";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupRightNavButtonWithTitle:@"提交" action:@selector(submitComment:)];
    [self.view addSubview:self.tableview];
    self.provider = [[NROrderCommentProvider alloc] init];
    [self loadData];
}

#pragma mark - Private Methods
- (void)loadData {
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showActivityWithText:self.view text:Tips_Loading animated:YES];

    [self.provider requestOrderCommentWithDate:self.dateForComment orderId:self.orderId completeBlock:^(id reslut, NSError *error) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        if (!error) {
            weakSelf.isCommented = weakSelf.provider.isCommented;
            if (weakSelf.isCommented) {
                 self.navigationItem.rightBarButtonItem = nil;
            }
            
            weakSelf.dataArray = reslut;
            [weakSelf.tableview reloadData];
            
        } else {
            [weakSelf processRequestError:error];
        }
    }];
}


- (void)submitComment:(id)sender {
    WeakSelf(self);
    if (self.isCommented) {
        [MBProgressHUD showErrormsgWithoutIcon:self.view title:@"今天的套餐已评价~" detail: nil];
        return;
    }
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setValue:self.orderId forKey:@"orderId"];
    [paramDic setValue:self.dateForComment forKey:@"date"];
    NSMutableArray *comments = [NSMutableArray array];
    
    // TODO: 评价内容是否可以为空
    for (NROrderCommentInfo *item in self.dataArray) {
        NSString *title = nil;
        if ([item.comment isEqualToString:kPlaceHolder] ||
            !STRINGHASVALUE(item.comment)) {
            switch (item.dinnerType) {
                case DinnerTypeZao:
                    title = @"早餐";
                    break;
                case DinnerTypeCha:
                    title = @"下午茶";
                default:
                    title = @"午餐";
                    break;
            }
            
            [MBProgressHUD showErrormsg:self.view msg:[NSString stringWithFormat:@"%@还没有评价", title]];
            return;
        }
        
        if (item.starValue == 0) {
            item.starValue = 5;
        }
    
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:[NSNumber numberWithInteger:item.setmealId] forKey:@"setmealId"];
        [dict setValue:[NSNumber numberWithInteger:item.dinnerType] forKey:@"mealType"];
        [dict setValue:[NSNumber numberWithInteger:item.starValue] forKey:@"star"];
        [dict setValue:item.comment forKey:@"content"];
        [comments addObject:dict];
    }
    
    [paramDic setValue:comments forKey:@"comments"];
    
    [self.provider submitCommentWithUserInfo:paramDic completeBlock:^(id reslut, NSError *error) {
        if (!error) {
            [MBProgressHUD showDoneWithText:weakSelf.view text:@"评价成功" completionBlock:^{
                if (weakSelf.refreshCmd) {
                    [weakSelf.refreshCmd execute:nil];
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [weakSelf processRequestError:error];
        }
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NROrderCommentCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *OrderCommentCellIdentifier = @"OrderCommentCellIdentifier";
    NROrderCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:OrderCommentCellIdentifier];
    
    if (!cell) {
        cell = [[NROrderCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderCommentCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.weakCommentVC = self;
    }
    
    NROrderCommentInfo *commmentinfo = self.dataArray[indexPath.row];
    commmentinfo.hasCommented = self.isCommented;
    cell.commentInfo = commmentinfo;
    cell.row = indexPath.row;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//}

#pragma mark - Property
- (UITableView *)tableview {
    if (!_tableview) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT);
        _tableview = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = [UIColor clearColor];
        _tableview.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
