  
//  NRPayCenterTableController.m
//  Nourish
//
//  Created by gtc on 15/3/20.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRPayCenterTableController.h"
#import "NROrderListContainerController.h"
#import "NRWeekPlanSelectViewController.h"

#import <AlipaySDK/AlipaySDK.h>
//#import "NRAliPayOrderInfo.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "WXApiObject.h"


static NSString *const appScheme = @"alipaysdk";

@interface NRPayCenterTableController ()<WXApiManagerDelegate>
{
    NSArray *_arrMenuIcons;
}

@property (strong, nonatomic) UILabel *amountLabel;
@property (strong, nonatomic) NSMutableDictionary *mdicPayTitles;
@property (strong, nonatomic) NSArray *iconNameList;
@property (weak, nonatomic) NSURLSessionDataTask *aliPayTask;
@property (assign, nonatomic) BOOL paySuccess;
@end


@implementation NRPayCenterTableController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftBack];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"支付";
    self.view.backgroundColor = ColorViewBg;
    self.paySuccess = NO;
    
    self.mdicPayTitles = [[NSMutableDictionary alloc] initWithCapacity:2];
    [self.mdicPayTitles setObject:@"推荐支付宝用户使用" forKey:@"支付宝支付"];
//    [self.mdicPayTitles setObject:@"推荐微信用户使用" forKey:@"微信支付"];
    
    UIImage *zhifubaoImg = [UIImage imageNamed:@"pay-zhifubao"];
//    UIImage *wechatImg = [UIImage imageNamed:@"login-appwx-logo"];
    self.iconNameList = @[ zhifubaoImg ];
    
    [WXApiManager sharedManager].delegate = self;
}

#pragma mark - Controls
- (UILabel *)amountLabel {
    if (_amountLabel) {
        return _amountLabel;
    }
    
    _amountLabel = [[UILabel alloc] init];
    _amountLabel.backgroundColor = [UIColor clearColor];
    _amountLabel.textColor = ColorRed_Normal;
    _amountLabel.font = NRFont(FontLabelSize);
    _amountLabel.text = [NSString stringWithFormat:@"您需要支付%lu元", (unsigned long)self.amount];
    return _amountLabel;
}

- (void)setAmount:(NSString *)amount {
    _amount = amount;
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)payByAli {
    __weak typeof(self) weakself = self;
    if (self.aliPayTask) {
        [self.aliPayTask cancel];
    }
    
    NSDictionary *dataDic = @{ @"orderId": self.orderID };
    [MBProgressHUD showActivityWithText:self.view text:@"正在支付..." animated:YES];
    self.aliPayTask = [[NRNetworkClient sharedClient] sendPost:@"order/pay/ali/ready2pay" parameters:dataDic success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        if (errorCode == 0) {
            //提交支付宝支付
            NSString *orderString = [res valueForKey:@"data"];
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
                
                //支付回调
                //1. 验签
                //2.根据不同的状态吗，进行跳转
                //
                //                9000
                //                订单支付成功
                //                8000
                //                正在处理中
                //                4000
                //                订单支付失败
                //                6001
                //                用户中途取消
                //                6002
                //                网络连接出错
                NSString *resultStatus = [resultDic valueForKey:@"resultStatus"];
                if ([resultStatus isEqualToString:@"9000"]) {
                    weakself.paySuccess = YES;
                    // 切换到订单列表
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"支付成功" delegate:weakself cancelButtonTitle:@"确认" otherButtonTitles: nil, nil];
                    alertView.tag = 1000;
                    [alertView show];
                }
                else if ([resultStatus isEqualToString:@"8000"]) {
                    weakself.paySuccess = YES;
                    [MBProgressHUD showAlert:@"提示" msg:@"正在处理中" delegate:nil cancelBtnTitle:@"确定"];
                }
                else if ([resultStatus isEqualToString:@"4000"]) {
                    [MBProgressHUD showAlert:@"订单支付失败" msg:@"请您及时联系客服" delegate:nil cancelBtnTitle:@"确定"];
                }
                else if ([resultStatus isEqualToString:@"6001"]) {
                    [MBProgressHUD showAlert:@"提示" msg:@"您已取消支付" delegate:nil cancelBtnTitle:@"确定"];
                }
                else if ([resultStatus isEqualToString:@"6002"]) {
                    [MBProgressHUD showAlert:@"提示" msg:@"网络连接出错" delegate:nil cancelBtnTitle:@"确定"];
                }
            }];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideActivityWithText:weakself.view animated:YES];
        NSString *errorMsg = [error.userInfo valueForKey:kErrorMsg];
        
        if (error.code == 5003) {
            //订单日期和已有订单日期有重复, 可以选择取消订单、联系客服。
            [MBProgressHUD showTips:KeyWindow text:errorMsg];
        } else if (error.code == 6000) {
            [MBProgressHUD showTips:KeyWindow text:errorMsg];
        } else {
            [weakself processRequestError:error];
        }
    }];
}

- (void)payByWeChat {
    //调起微信支付
//    PayReq* req             = [[[PayReq alloc] init]autorelease];
//    req.openID              = [dict objectForKey:@"appid"];
//    req.partnerId           = [dict objectForKey:@"partnerid"];
//    req.prepayId            = [dict objectForKey:@"prepayid"];
//    req.nonceStr            = [dict objectForKey:@"noncestr"];
//    req.timeStamp           = stamp.intValue;
//    req.package             = [dict objectForKey:@"package"];
//    req.sign                = [dict objectForKey:@"sign"];
    
//    [WXApi sendReq:req];

}

#pragma mark - WXApiManagerDelegate
- (void)managerDidRecvPayResponse:(PayResp *)response {
    NSString *strTitle = [NSString stringWithFormat:@"支付结果"];
    NSString *strMsg = nil;
    
    switch (response.errCode) {
        case WXSuccess:
            strMsg = @"支付结果：成功！";
            NSLog(@"支付成功－PaySuccess，retcode = %d", response.errCode);
            break;
            
        default:
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", response.errCode,response.errStr];
            NSLog(@"错误，retcode = %d, retstr = %@", response.errCode,response.errStr);
            break;
    }
}


#pragma mark - UITableDateDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return self.iconNameList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        return;
    }
    
    if (indexPath.row == 0) {
        // 请求签名数据
        [self payByAli];
        [MobClick event:NREvent_Click_Pay_Ali];
    }
    
    if (indexPath.row == 1) {
        [self payByWeChat];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *PayCellIdentifier = @"PayCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PayCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PayCellIdentifier];
    }
    
    cell.textLabel.font = NRFont(16);
    
    if (indexPath.section == 0) {
        
        cell.textLabel.text = [NSString stringWithFormat:@"您需要支付%@元", self.amount];
        cell.textLabel.textColor = ColorRed_Normal;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.imageView.image  = [self.iconNameList objectAtIndex:indexPath.row];
        cell.textLabel.text = ToString([[self.mdicPayTitles allKeys] objectAtIndex:indexPath.row]);
        cell.detailTextLabel.text = ToString([[self.mdicPayTitles allValues] objectAtIndex:indexPath.row]) ;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    return @"选择付款方式";
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    else
        return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        // 支付成功，跳转到订单列表
        NROrderListContainerController *orderVC = [[NROrderListContainerController alloc] init];
        orderVC.from = NROrderListFromPay;
        orderVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:orderVC animated:YES];
    } else if (alertView.tag == 2000) {
        if (buttonIndex == 1) {
            [self backToWeekPlanSelect];
        }
    }
}
- (void)backToWeekPlanSelect {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[NRWeekPlanSelectViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
             break;
        }
    }
}

- (void)back:(id)sender {
    if (self.paySuccess) {
        [self backToWeekPlanSelect];
    } else {
        if (ISIOS8_OR_LATER) {
            UIAlertController *alertContr = [UIAlertController alertControllerWithTitle:@"您还没有支付该订单" message:@"确定取消支付吗？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"去支付" style:UIAlertActionStyleDestructive handler:nil];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消支付" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self backToWeekPlanSelect];
            }];
            [alertContr addAction:confirmAction];
            [alertContr addAction:cancelAction];
            [self presentViewController:alertContr animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您还没有支付该订单" message:@"确定取消支付吗？" delegate:self cancelButtonTitle:@"去支付" otherButtonTitles:@"取消支付", nil];
            alertView.tag = 2000;
            [alertView show];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
