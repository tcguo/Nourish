//
//  NROrderListViewController.m
//  Nourish

//  订单列表

//  Created by gtc on 15/8/3.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NROrderListViewController.h"
#import "NROrderDetailController.h"
#import "UILabel+Additions.h"
#import "NRChangeOrderCalendarView.h"
#import "NRNavigationController.h"
#import "NRRefundOrderView.h"
#import "NROrderListViewModel.h"

#import "NRPlaceOrderViewController.h"
#import "NRWeekPlanListItemModel.h"
#import "NRWeekPlanCommentViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UITableView+BDSBottomPullToRefresh.h"

NSInteger const tagSheetActionForPay = 99999;

typedef NS_OPTIONS(NSUInteger, PullDirection){
    PullDirectionUp = 1 << 0,
    PullDirectionDown = 1 << 1,
};

@interface NROrderListViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
                                        OrderOperateDelegate>
{
    UIWebView *_webView;
    NRChangeOrderCalendarView *_changeOrderView;
}

@property (strong, nonatomic) UIView *nullView;
@property (strong, nonatomic) NSMutableArray *marrOrderMods;
@property (strong, nonatomic) NSMutableSet *msetOrderMods;

@property (copy, nonatomic) NSString *orderCreateTime;
@property (strong, nonatomic) NROrderInfoModel *operatingModel;
@property (copy, nonatomic)  NROrderDetailController *detailVC;

@property (nonatomic, strong) NROrderListViewModel *viewModel;
@property (weak, nonatomic) NSURLSessionDataTask *readyPayTask;
@property (nonatomic, strong) NSMutableArray *orderStatusCodes;

@property (nonatomic, strong)NRChangeOrderCalendarView *changeOrderView;

@end

@implementation NROrderListViewController

#pragma mark  - View Cycle
- (id)initWithOrderLabelType:(OrderLabelType)orderType {
    self = [super init];
    if (self) {
        self.orderLabelType = orderType;
        self.orderCreateTime = @"";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableViewList];
    self.view.backgroundColor = ColorViewBg;
    self.marrOrderMods = [NSMutableArray array];
    self.msetOrderMods = [NSMutableSet set];
    [self setupRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableViewList reloadData];
}

#pragma mark - private methods
- (void)setupRefresh {
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    WeakSelf(self);
    self.tableViewList.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableViewList.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableViewList.mj_footer.automaticallyHidden = YES;
}

- (void)addNullView {
    [self.tableViewList addSubview:self.nullView];
}

- (void)removeNullView {
    [self.nullView removeFromSuperview];
}

- (void)viewDidCurrentView {
    [self.tableViewList.mj_header beginRefreshing];
}

- (void)loadData {
    NSDictionary *paramsDic = @{ @"pageIndex": @(0),
                                 @"statusCodes": self.orderStatusCodes };
    
    [self.tableViewList.mj_header beginRefreshing];
    WeakSelf(self);
    [[self.viewModel loadOrderListWithParametres:paramsDic] subscribeNext:^(id x) {
        [self.tableViewList.mj_header endRefreshing];
        [weakSelf.marrOrderMods removeAllObjects];
        [weakSelf.msetOrderMods removeAllObjects];
        
        NSMutableArray *objs = (NSMutableArray *)x;
        if (ARRAYHASVALUE(objs)) {
            [weakSelf removeNullView];
            [weakSelf.marrOrderMods addObjectsFromArray:x];
            [weakSelf.tableViewList reloadData];
            if (weakSelf.viewModel.orderListNextPageIndex < 0) {
                [weakSelf.tableViewList.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.tableViewList.mj_footer endRefreshing];
            }
        } else {
            [weakSelf.tableViewList reloadData];
            [weakSelf addNullView];
        }
    } error:^(NSError *error) {
        [weakSelf.tableViewList.mj_header endRefreshing];
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

- (void)loadMoreData {
    WeakSelf(self);
    NSDictionary *paramsDic = @{ @"pageIndex": @(self.viewModel.orderListNextPageIndex),
                                 @"statusCodes": self.orderStatusCodes };
    
    [[self.viewModel loadOrderListWithParametres:paramsDic] subscribeNext:^(id x) {
        [weakSelf.marrOrderMods addObjectsFromArray:x];
        [weakSelf.tableViewList reloadData];
        
        if (weakSelf.viewModel.orderListNextPageIndex < 0) {
            [weakSelf.tableViewList.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.tableViewList.mj_footer endRefreshing];
        }
    } error:^(NSError *error) {
        [weakSelf.tableViewList.mj_footer endRefreshing];
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

#pragma mark - Action
- (void)requestOrderListWithStatus:(void(^)())callback  pullDirection:(PullDirection)direction {
    NSString *beforeAfter = [NSString string];
    if (direction == PullDirectionUp) {
        beforeAfter = @"before";
    }
    else
        beforeAfter = @"after";
    
    NSMutableArray *marrCreateTimes = [NSMutableArray array];
    for (NROrderInfoModel *mod in self.marrOrderMods) {
        [marrCreateTimes addObject:mod.createTime];
    }
    
    // 排序订单创建时间
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortedCreateTimes = [marrCreateTimes sortedArrayUsingDescriptors:sortDesc];
    
    if (direction == PullDirectionDown && sortedCreateTimes.count != 0) {
        self.orderCreateTime = @"";
        [self.marrOrderMods removeAllObjects];
        [self.tableViewList reloadData];
    }
    if (direction == PullDirectionUp && sortedCreateTimes.count != 0) {
        self.orderCreateTime = sortedCreateTimes.firstObject;
    }
    
    // 增加了下拉刷新已存在订单的状态
    NSDictionary *dicParam = @{ @"beforeAfter":beforeAfter,
                                @"statusCodes": self.orderStatusCodes,
                                @"createTime": self.orderCreateTime };
    
    __weak typeof(self) weakself = self;
    [[NRNetworkClient sharedClient] sendPost:@"order/list" parameters:dicParam success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        if (errorCode == 0) {
            NSArray *arrList = [res valueForKey:@"list"];
            NSMutableArray *arrSortOrderList = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dic in arrList) {
                NSString *orderID = [dic valueForKey:@"orderId"];
                NROrderInfoModel *model = [[NROrderInfoModel alloc] init];
                model.orderID = orderID;
                NSNumber *wptID = [dic valueForKey:@"wptId"];
                model.wptId = [wptID integerValue];
                model.wpName = [dic valueForKey:@"wpName"];
                model.wpThemeImgURL = [dic valueForKey:@"wpThemeImage"];
                model.smwIds = [dic valueForKey:@"smwIds"];
                model.startDate = [dic valueForKey:@"startDate"];
                model.endDate = [dic valueForKey:@"endDate"];
                model.createTime = [dic valueForKey:@"createTime"];
                
                NSNumber *days = [dic valueForKey:@"days"];
                model.days = [days unsignedIntegerValue];
                model.orderStatusDesc = [dic valueForKey:@"statusDesc"];
                NSNumber *status = [dic valueForKey:@"statusCode"];
                model.orderstatus = (OrderStatus)[status integerValue];
                
                model.realPrice = [NSNumber numberWithFloat:[[dic valueForKey:@"realPrice"] floatValue]];
                model.totalPrice = [NSNumber numberWithFloat:[[dic valueForKey:@"totalPrice"] floatValue]];
                NSString *dates = [dic valueForKey:@"dates"];
                model.arrDates = [dates componentsSeparatedByString:@","];
                
                if (![self.msetOrderMods containsObject:orderID]) {
                    //加载的新订单
                    [arrSortOrderList addObject:model];
                    [self.msetOrderMods addObject:orderID];
                }
                else {
                    //更新订单数据
                    for (NROrderInfoModel *item in weakself.marrOrderMods) {
                        if ([item.orderID isEqualToString:orderID]) {
                            NSUInteger idx = [weakself.marrOrderMods indexOfObject:item];
                            [weakself.marrOrderMods replaceObjectAtIndex:idx withObject:model];
                            break;
                        }
                    }
                }
                
            }
            
            //订单追加数据---下拉插入，上拉追加
            if (arrSortOrderList && arrSortOrderList.count != 0) {
                switch (direction) {
                    case PullDirectionUp:
                        [self.marrOrderMods addObjectsFromArray:arrSortOrderList];
                        break;
                    case PullDirectionDown:
                    {
                        NSIndexSet *idxSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, arrSortOrderList.count)];
                        [self.marrOrderMods insertObjects:arrSortOrderList atIndexes:idxSet];
                    }
                        break;
                    default:
                        break;
                }
            }
        }
        else {
            //后台数据请求失败
            [MBProgressHUD showErrormsgOnWindow:errorMsg];
        }
        
        if (callback) {
            callback();
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (callback) {
            callback();
        }
        [weakself processRequestError:error];
    }];
}

#pragma mark - OrderOperateAction
- (void)refundAction:(NROrderInfoModel *)orderModel {
    WeakSelf(self);
    
    NRRefundOrderView *refundView = [[NRRefundOrderView alloc] initWithHeight:200.f delegate:nil];
    refundView.weakOrderListVC = self;
    refundView.orderMod = orderModel;
    refundView.refundCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [weakSelf doRefundWithParams:(NSDictionary *)input];
        return [RACSignal empty];
    }];
    [refundView showInView:self.view];
    refundView.tag = 200;
}

- (void)doRefundWithParams:(NSDictionary *)params {
    WeakSelf(self);
    [MBProgressHUD showActivityWithText:weakSelf.view text:@"提交退款..." animated:YES];
    [[self.viewModel refundWithParametres:params] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        [weakSelf refresOrderInfoWithNewOrderMode:newMod isChange:NO];
        
        [MBProgressHUD showDoneWithText:KeyWindow text:@"已提交退款"];
    } error:^(NSError *error) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

- (void)cancelRefundAction:(NROrderInfoModel *)orderModel {
    // 取消退款
    [MBProgressHUD showActivityWithText:self.view text:@"取消退款..." animated:YES];
    NSDictionary *dicParam = @{@"orderId": orderModel.orderID};
    WeakSelf(self);
    [[self.viewModel cancelRefundWithParametres:dicParam] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        [weakSelf refresOrderInfoWithNewOrderMode:newMod isChange:NO];
        
        [MBProgressHUD showDoneWithText:KeyWindow text:@"已取消退款"];
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

- (void)changeOrderAction:(NROrderInfoModel *)orderModel {
    // 提交变更
    CGFloat height = (437.0f+10.0f)*kAppUIScaleY;
    WeakSelf(self);
    self.changeOrderView = [[NRChangeOrderCalendarView alloc] init];
    self.changeOrderView.viewModel = self.viewModel;
    self.changeOrderView.contentViewHeight =  height;
    self.changeOrderView.orderInfoMod = orderModel;
    self.changeOrderView.msetOrderDates = [NSMutableSet setWithArray:orderModel.arrDates];
    self.changeOrderView.changeCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [weakSelf doChangeWithOrderModle:orderModel newDates:(NSArray *)input];
        return [RACSignal empty];
    }];
    
    [self.changeOrderView setupUI];
    [self.changeOrderView showInView:KeyWindow];
    [self.changeOrderView getWorkdays];
    self.changeOrderView.tag = 100;
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
        [weakSelf refresOrderInfoWithNewOrderMode:newMod isChange:YES];
    } error:^(NSError *error) {
        [MBProgressHUD hideActivityWithText:weakCalView animated:YES];
        [weakSelf processRequestError:error];
    } completed:^{
        [weakCalView dismiss];
        [MBProgressHUD showDoneWithText:KeyWindow text:@"已提交变更" completionBlock:nil];
    }];
}

- (void)cancelChangeAction:(NROrderInfoModel *)orderModel {
    NSDictionary *dicParam = @{ @"orderId": orderModel.orderID };
    [MBProgressHUD showActivityWithText:self.view text:@"正在取消变更..." animated:YES];
    
    WeakSelf(self);
    [[self.viewModel cancelChangeOrderWithParametres:dicParam] subscribeNext:^(id x) {
        [MBProgressHUD hideActivityWithText:weakSelf.view animated:YES];
        NROrderInfoModel *newMod = (NROrderInfoModel *)x;
        [weakSelf refresOrderInfoWithNewOrderMode:newMod isChange:NO];
        [MBProgressHUD showDoneWithText:weakSelf.view text:@"已取消变更"];
    } error:^(NSError *error) {
        [weakSelf processRequestError:error];
    } completed:^{
    }];
}

- (void)commentAction:(NROrderInfoModel *)orderModel {
    // 去评论
    WeakSelf(self);
    NRWeekPlanCommentViewController *commentVC = [[NRWeekPlanCommentViewController alloc] initWithOrderInfo:orderModel];
    commentVC.refreshCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [weakSelf refresOrderInfoWithNewOrderMode:nil isChange:NO];
        return [RACSignal empty];
    }];
    commentVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)againWeekAction:(NROrderInfoModel *)orderModel {
    // 再来一周
    NRPlaceOrderViewController *placeOrderVC = [[NRPlaceOrderViewController alloc] init];
    placeOrderVC.wptID = orderModel.wptId;
    
    NRWeekPlanListItemModel *newCurrentMod = [[NRWeekPlanListItemModel alloc] init];
    newCurrentMod.arrWPSID = orderModel.smwIds;
    newCurrentMod.theWeekPlanImageUrl = orderModel.wpThemeImgURL;
    newCurrentMod.theWeekPlanName = orderModel.wpName;
    placeOrderVC.currentMod = newCurrentMod;
    
    placeOrderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:placeOrderVC animated:YES];
}

- (void)shareWeekPlanAction:(NROrderInfoModel *)orderModel {
    //TODO: 分享周计划
}

- (void)telCustomer {
    // 提示：不要将webView添加到self.view，如果添加会遮挡原有的视图
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [NRGlobalManager sharedInstance].customerPhone]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)payByAliWithOrderInfo:(NROrderInfoModel *)orderModel {
    [MobClick event:NREvent_Click_Pay_Ali];
    
    static NSString *const appScheme = @"alipaysdk";
    NSDictionary *dataDic = @{@"orderId": orderModel.orderID};
    [MBProgressHUD showActivityWithText:self.view text:@"正在支付..." animated:YES];
    __weak typeof(self) weakself = self;
    if (self.readyPayTask) {
        [self.readyPayTask cancel];
    }
    self.readyPayTask = [[NRNetworkClient sharedClient] sendPost:@"order/pay/ali/ready2pay" parameters:dataDic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        if (errorCode == 0) {
            // 提交支付宝支付
            NSString *orderString = [res valueForKey:@"data"];
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                
                // 支付回调
                // 1.验签 没做呢？？？
                // 2.根据不同的状态吗，进行跳转
                
                NSString *resultStatus = [resultDic valueForKey:@"resultStatus"];
                if ([resultStatus isEqualToString:@"9000"]) {
                    [MBProgressHUD showAlert:nil msg:@"支付成功" delegate:nil cancelBtnTitle:@"确定"];
                    // TODO: 只刷新单个订单
                    [weakself viewDidCurrentView];
                } else if ([resultStatus isEqualToString:@"8000"]) {
                    [MBProgressHUD showAlert:nil msg:@"正在处理中" delegate:nil cancelBtnTitle:@"确定"];
                    [weakself viewDidCurrentView];
                } else if ([resultStatus isEqualToString:@"4000"]) {
                    [MBProgressHUD showAlert:@"订单支付失败" msg:@"请您及时联系客服" delegate:nil cancelBtnTitle:@"确定"];
                } else if ([resultStatus isEqualToString:@"6001"]) {
                    [MBProgressHUD showAlert:nil msg:@"您已取消支付" delegate:nil cancelBtnTitle:@"确定"];
                } else if ([resultStatus isEqualToString:@"6002"]) {
                    [MBProgressHUD showAlert:nil msg:@"网络连接出错" delegate:nil cancelBtnTitle:@"确定"];
                }
                
            }];
        } else if (errorCode == 5003) {
            //订单日期和已有订单日期有重复, 可以选择取消订单、联系客服。
            [MBProgressHUD showErrormsgWithoutIcon:weakself.view title:errorMsg detail:nil];
        } else if (errorCode == 6000) {
            [MBProgressHUD showErrormsgWithoutIcon:weakself.view title:errorMsg detail:nil];
            
        } else {
            [MBProgressHUD showErrormsgWithoutIcon:weakself.view title:errorMsg detail:nil];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakself processRequestError:error];
    }];
}

- (void)payByWechatWithOrderInfo:(NROrderInfoModel *)orderModel {
    //TODO: 微信支付
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NRHistoryOrderCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *HistoryOrderCellIdenfier = @"HistoryOrderCellIdenfier";
    
    NRHistoryOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:HistoryOrderCellIdenfier];
    if (!cell) {
        cell = [[NRHistoryOrderCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:HistoryOrderCellIdenfier];
    }
    
    cell.operateDelegate = self;
    cell.myIndexPath = indexPath;
    cell.orderModel = [self.marrOrderMods objectAtIndex:indexPath.section];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.marrOrderMods.count;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NROrderInfoModel *orderMod = (NROrderInfoModel*)[self.marrOrderMods objectAtIndex:indexPath.section];
    NROrderDetailController *orderDetailVC =  [[NROrderDetailController alloc] initWithOrderID:orderMod.orderID];
    orderDetailVC.hidesBottomBarWhenPushed = YES;
    // orderDetailVC.weakOrderListVC = self;
    WeakSelf(self);
    orderDetailVC.refreshCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        if ([input isKindOfClass:[NROrderInfoModel class]]) {
            NROrderInfoModel *newModel = (NROrderInfoModel *)input;
            [weakSelf refresOrderInfoWithNewOrderMode:newModel isChange:NO];
        }
        
        return [RACSignal empty];
    }];
    
    orderDetailVC.orderSimpleInfoMod = orderMod;
    orderDetailVC.viewModel = self.viewModel;
    [self.navigationController pushViewController:orderDetailVC animated:YES];

    [self.tableViewList deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 131;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  10;
}


#pragma mark - OrderOperateDelegate
- (void)payForOrder:(NROrderInfoModel *)orderModel {
    //支付
    //    NSDictionary *dicParam = @{@"orderId": orderModel};
    //1. 首先先后台请求支付数据，并生成支付流水号
    //2. 调微信，支付宝的sdk
    //3. 回调后端url，解析支付结果
    
    if (ISIOS8_OR_LATER) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *aliPayAction = [UIAlertAction actionWithTitle:@"支付宝支付" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self payByAliWithOrderInfo:orderModel];
        }];
        
//        UIAlertAction *wechatePayAction = [UIAlertAction actionWithTitle:@"微信支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [self payByWechatWithOrderInfo:orderModel];
//        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [alertController addAction:aliPayAction];
//        [alertController addAction:wechatePayAction];
        [alertController addAction:closeAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
//       UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:@"支付宝支付" otherButtonTitles:@"微信支付", nil];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:@"支付宝支付" otherButtonTitles:nil];
        actionSheet.tag = tagSheetActionForPay;
        actionSheet.delegate = self;
        actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        [actionSheet showInView:self.view.window];
        self.operatingModel = orderModel;
    }
    
}

- (void)showOperateSheetList:(NSIndexPath *)indexPath {
    NRHistoryOrderCell *selCell = (NRHistoryOrderCell *)[self.tableViewList cellForRowAtIndexPath:indexPath];
    NROrderInfoModel *mod = selCell.orderModel;
    self.operatingModel = mod;
    NSString *phone = [NSString stringWithFormat:@"客服: %@", [NRGlobalManager sharedInstance].customerPhone];
    
    if (ISIOS8_OR_LATER) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *refundAction = [UIAlertAction actionWithTitle:@"退款" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self refundAction:mod];
        }];
        
        UIAlertAction *cancelRefundAction = [UIAlertAction actionWithTitle:@"取消退款" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self cancelRefundAction:mod];
        }];
        
        UIAlertAction *changeOrderAction = [UIAlertAction actionWithTitle:@"变更订单" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self changeOrderAction:mod];
        }];
        
        UIAlertAction *cancelChangeAction = [UIAlertAction actionWithTitle:@"取消变更" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self cancelChangeAction:mod];
        }];
        
       
        UIAlertAction *callCustomerAction = [UIAlertAction actionWithTitle:phone style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self telCustomer];
        }];
        
        UIAlertAction *commentAction = [UIAlertAction actionWithTitle:@"评价" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self commentAction:mod];
        }];
        
//        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [self shareWeekPlanAction:mod];
//        }];
        
        UIAlertAction *againWeekAction = [UIAlertAction actionWithTitle:@"再来一周" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self againWeekAction:mod];
        }];
        
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"sheet closed");
        }];
        
        switch (mod.orderstatus) {
            case OrderStatusPaying:
            case OrderStatusPayCompleted:
            case OrderStatusToRun:
            case OrderStatusRefunded:
                
            case OrderStatusChangeSuccess:
            case OrderStatusChangeFailure:
                
            case OrderStatusCancelled:
            case OrderStatusCancelTimeOut:
            case OrderStatusClosed:
            case OrderStatusConfirmFailure:
                break;
                
            case OrderStatusRunning:
                [alertController addAction:changeOrderAction];
                [alertController addAction:refundAction];
                break;
            case OrderStatusRefunding:
                [alertController addAction:cancelRefundAction];
                break;
            case OrderStatusChanging:
                [alertController addAction:cancelChangeAction];
                break;
            case OrderStatusToComment://评价、分享、再来一周
                [alertController addAction:commentAction];
//                [alertController addAction:shareAction];
                [alertController addAction:againWeekAction];
                break;
            case OrderStatusDone:
//                [alertController addAction:shareAction];
                [alertController addAction:againWeekAction];
                break;
                
      
            default:
                break;
        }
        
        [alertController addAction:callCustomerAction];
        [alertController addAction:closeAction];
        [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    else {
        NSString *closeTitle = @"关闭";
        
        UIActionSheet *actionSheet = nil;
        switch (mod.orderstatus) {
            case OrderStatusPaying:
            case OrderStatusPayCompleted:
            case OrderStatusToRun:
            case OrderStatusRefunded:
                
            case OrderStatusChangeSuccess:
            case OrderStatusChangeFailure:
                
            case OrderStatusCancelled:
            case OrderStatusCancelTimeOut:
            case OrderStatusClosed:
            case OrderStatusConfirmFailure:
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:kCustomerPhone otherButtonTitles:nil];
                break;
                
            case OrderStatusRunning:
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:@"变更订单" otherButtonTitles:@"退款", phone, nil];
                break;
            case OrderStatusRefunding:
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:@"取消退款" otherButtonTitles:phone, nil];
                break;
            case OrderStatusChanging:
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:@"取消变更" otherButtonTitles:phone, nil];
                break;
            case OrderStatusToComment://评价、分享、再来一周
//                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:@"评价" otherButtonTitles:@"分享", @"再来一周", phone, nil];
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:@"评价" otherButtonTitles:@"再来一周", phone, nil];
                break;
            case OrderStatusDone:
//                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:@"分享"otherButtonTitles: @"再来一周", phone, nil];
                 actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:closeTitle destructiveButtonTitle:@"再来一周"otherButtonTitles:phone, nil];
                break;
                
            default:
                break;
        }
        
        if (actionSheet) {
            actionSheet.tag = mod.orderstatus;
            actionSheet.delegate = self;
            actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
            [actionSheet showInView:self.view.window];
        }
    }
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Pay
    if (actionSheet.tag == tagSheetActionForPay) {
        if (buttonIndex == 0) {
            [self payByAliWithOrderInfo:self.operatingModel];
        }
        
//        else if (buttonIndex == 1) {
//            [self payByWechatWithOrderInfo:self.operatingModel];
//        }
        
        return;
    }
    
    //订单操作
    OrderStatus orderStatus = (OrderStatus)actionSheet.tag;
    switch (orderStatus) {
        case OrderStatusPaying:
        case OrderStatusPayCompleted:
        case OrderStatusToRun:
        case OrderStatusRefunded:
            
        case OrderStatusCancelled:
        case OrderStatusCancelTimeOut:
        case OrderStatusClosed:
        case OrderStatusConfirmFailure:
        {
            [self telCustomer];
        }
            break;
        case OrderStatusRunning:
        {
            //0:变更  1:退款
            if (buttonIndex == 0) {
                [self changeOrderAction:self.operatingModel];
            }
            else if (buttonIndex == 1) {
                [self refundAction:self.operatingModel];
            }
            else
                [self telCustomer];
        }
            break;
        case OrderStatusRefunding:
        {
            //取消退款、客服
            if (buttonIndex == 0) {
                [self cancelRefundAction:self.operatingModel];
            }
            else if (buttonIndex == 1) {
                [self telCustomer];
            }
        }
            break;
        case OrderStatusChanging:
        {
            //取消变更、客服
            if (buttonIndex == 0) {
                [self cancelChangeAction:self.operatingModel];
            }
            else if (buttonIndex == 1) {
                [self telCustomer];
            }
        }
            break;
        case OrderStatusToComment://评价、分享、再来一周
        {
            //评论、分享、再来一周
            if (buttonIndex == 0) {
                [self commentAction:self.operatingModel];
            }
//            else if (buttonIndex == 1) {
//                [self shareWeekPlanAction:self.operatingModel];
//            }
            else if (buttonIndex == 1) {
                [self againWeekAction:self.operatingModel];
            }
            else
                [self telCustomer];
            
        }
            break;
        case OrderStatusDone:
        {
//            if (buttonIndex == 0) {
//                [self shareWeekPlanAction:self.operatingModel];
//            }
            if (buttonIndex == 0) {
                [self againWeekAction:self.operatingModel];
            }
            else
                [self telCustomer];
        }
            break;
        default:
            break;
    }
    
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    NSLog(@"canceled");
}

#pragma mark - BDSBottomPullToRefreshDelegate
//- (void)onStartBottomPullToRefresh:(UITableView *)tableView {
//    [self loadMoreData];
//}

#pragma mark - Helper
- (void)processRequestError:(NSError *)error {
    __weak typeof(self) weakself = self;
    [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
    [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
    
    if (error.code == NRRequestErrorNetworkDisAvailablity) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NoNetwork];
    }
    else if (error.code == NRRequestErrorParseJsonError) {
        [MBProgressHUD showTips:KeyWindow text:Tips_ServiceException];
    }
    else if (error.code == 404) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NetworkError];
    }
    else if (error.code == 503) {
        [MBProgressHUD showTips:KeyWindow text:Tips_NetworkTimeOut];
    }
    else {
        if ([error.domain isEqualToString:NourishDomain]) {
            NSString *msg = [error.userInfo valueForKey:@"errorMsg"];
            [MBProgressHUD showTips:KeyWindow text:msg];
        }
        else {
            [MBProgressHUD showTips:KeyWindow text:Tips_NetworkError];
        }
    }
}

- (void)refresOrderInfoWithNewOrderMode:(NROrderInfoModel *)newMod isChange:(BOOL)ischange {
    WeakSelf(self);
    //TODO: 先暂时整体刷新-有点粗暴
    [weakSelf viewDidCurrentView];
    
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"orderID =%@", newMod.orderID];
//    NSArray *arrayPre = [weakSelf.marrOrderMods filteredArrayUsingPredicate:pre];
//    NROrderInfoModel *originalMod = [arrayPre firstObject];
//    originalMod.orderstatus = newMod.orderstatus;
//    originalMod.orderStatusDesc = newMod.orderStatusDesc;
//    if (ischange) {
//        originalMod.startDate = newMod.startDate;
//        originalMod.endDate = newMod.endDate;
//        originalMod.arrDates = newMod.arrDates;
//    }
//    
//    [weakSelf.tableViewList reloadData];
}

- (NROrderInfoModel*)queryorderModInArrayByID:(NSString *)orderID {
    for (NROrderInfoModel *item in self.marrOrderMods) {
        if ([item.orderID isEqualToString:orderID]) {
            return item;
        }
    }
    
    return nil;
}

#pragma mark - Property
- (UITableView *)tableViewList {
    if (!_tableViewList) {
        _tableViewList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_BAR_HEIGHT-44) style:UITableViewStyleGrouped];
        _tableViewList.dataSource = self;
        _tableViewList.delegate = self;
        _tableViewList.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableViewList.bottomRefreshDelegate = self;
        _tableViewList.backgroundColor = [UIColor clearColor];
    }
    
    return _tableViewList;
}

- (UIView *)nullView {
    if (!_nullView) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = 100;
        CGFloat y = (self.tableViewList.bounds.size.height - height)/2 - 100;
        CGFloat x = (self.tableViewList.bounds.size.width - width)/2;
        
        _nullView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _nullView.backgroundColor = [UIColor clearColor];
        
        UIImageView *nullImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"null"]];
        [_nullView addSubview:nullImgv];
        [nullImgv makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nullView.centerX);
            make.top.equalTo(_nullView.mas_top).offset(20);
        }];
        
        UILabel *nullLabel = [UILabel new];
        [_nullView addSubview:nullLabel];
        nullLabel.text = @"还木有订单~";
        nullLabel.textColor = ColorBaseFont;
        nullLabel.font = NRFont(14);
        
        [nullLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_nullView.centerX);
            make.top.equalTo(nullImgv.mas_bottom).offset(10);
        }];
    }
    
    return _nullView;
}

- (NROrderListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NROrderListViewModel alloc] init];
    }
    
    return _viewModel;
}

- (NSMutableArray *)orderStatusCodes {
    if (!_orderStatusCodes) {
        _orderStatusCodes = [NSMutableArray array];
        switch (self.orderLabelType) {
            case OrderLabelTypeAll:
            {
                NSNumber *statusCode = [NSNumber numberWithInteger:-1];
                [_orderStatusCodes addObject:statusCode];
            }
                break;
            case OrderLabelTypeNoPay:
            {
                NSNumber *statusCode = [NSNumber numberWithInteger:OrderStatusPaying];
                [_orderStatusCodes addObject:statusCode];
            }
                break;
            case OrderLabelTypeRunning:
            {
                NSNumber *statusCodeRunning = [NSNumber numberWithInteger:OrderStatusRunning];
                NSNumber *statusCodeRefunding = [NSNumber numberWithInteger:OrderStatusRefunding];
                NSNumber *statusCodeChanging = [NSNumber numberWithInteger:OrderStatusChanging];
                [_orderStatusCodes addObject:statusCodeRunning];
                [_orderStatusCodes addObject:statusCodeChanging];
                [_orderStatusCodes addObject:statusCodeRefunding];
            }
                break;
            case OrderLabelTypeWaitRun:
            {
                NSNumber *statusCode = [NSNumber numberWithInteger:OrderStatusToRun];
                NSNumber *statusPayCompleted = [NSNumber numberWithInteger:OrderStatusPayCompleted];
                [_orderStatusCodes addObject:statusCode];
                [_orderStatusCodes addObject:statusPayCompleted];
            }
                break;
            case OrderLabelTypeWaitComment:
            {
                NSNumber *statusCode = [NSNumber numberWithInteger:OrderStatusToComment];
                [_orderStatusCodes addObject:statusCode];
            }
                break;
            case OrderLabelTypeCanceled:
            {
                NSNumber *statusCodeCanceled = [NSNumber numberWithInteger:OrderStatusCancelled];
                NSNumber *statusCodeTimeOut = [NSNumber numberWithInteger:OrderStatusCancelTimeOut];
                [_orderStatusCodes addObject:statusCodeCanceled];
                [_orderStatusCodes addObject:statusCodeTimeOut];
            }
                break;
            default:
            {
                NSNumber *statusCode = [NSNumber numberWithInteger:-1];
                [_orderStatusCodes addObject:statusCode];
            }
                break;
        }
        
    }
    
    return _orderStatusCodes;
}



#pragma mark- Override
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
