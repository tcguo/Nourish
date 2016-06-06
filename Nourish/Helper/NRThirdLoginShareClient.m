//
//  NRThirdLoginShareClient.m
//  Nourish
//
//  Created by gtc on 15/6/24.
//  Copyright (c) 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRThirdLoginShareClient.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

#import "WXApi.h"
#import "WXApiObject.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"

#import "WeiboSDK.h"


static NRThirdLoginShareClient *_instance = nil;

/** 由用户微信号和AppID组成的唯一标识，发送请求时第三方程序必须填写，用于校验微信用户是否换号登录*/
//static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact,snsapi_base";
//static NSString *kAuthOpenID = @"abcd";
static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *kAuthOpenID = @"0c806938e2413ce73eef92cc3";
static NSString *kAuthState = @"xxx";

static NSString *kShareUrl = @"http://www.51nourish.com/share_tmp/shareIndex.html";
static NSString *kLinkTagName = @"WECHAT_TAG_JUMP_SHOWNUOSHIJI";

//static NSString *kLinkTitle = @"诺食计：我今天吃的午餐相当丰盛";
//static NSString *kLinkDescription = @"诺食计为有周期性膳食计划的人群，针对其不同膳食目的，制定不同的营养餐周计划，并与地面高资质商家合作，完成营养餐的制作，定时配送到用户手中，同时完成每日饮食营养数据的推送与云记录，完成健康目标，保障餐饮安全，明明白白的吃动两平衡。";

static NSString *kRedirectURI = @"http://www.sina.com";

@interface NRThirdLoginShareClient ()<TencentSessionDelegate, WXApiManagerDelegate, WeiboSDKDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;//QQ请求对策
@property (nonatomic, strong) WBAuthorizeRequest *request;//微博请求对象

@property (nonatomic, copy) NSString *accessTokenQQ;
@property (nonatomic, copy) NSString *openIdQQ;
@property (nonatomic, copy) NSDate *expirationDateQQ;
@property (nonatomic, copy) NSString *accessTokenSinaWB;
@property (nonatomic, weak) NSURLSessionDataTask *dataTaskForSinaweibo;

@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareDesc;
@property (nonatomic, copy) NSString *shareLink;

@end


@implementation NRThirdLoginShareClient

+ (instancetype)shareInstance {
  
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance =  [[NRThirdLoginShareClient alloc] init];
        }
    });
    
    return _instance;
}

- (void)registerApp {
    // 注册微博SDK
    if (self.sinaWBEnabled) {
        [WeiboSDK registerApp:kWBAppKey];
        [WeiboSDK enableDebugMode:YES];
        
    }
    // 注册微信SDK
    if (self.wxEnabled) {
        [WXApi registerApp:kWXAppID withDescription:APPNAME];
    }
    
    if (self.qqEnabled) {
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kQQAppID andDelegate:self];
    }
}

- (BOOL)handleOpenURL:(NSURL *)url type:(ThirdLoginShareType)type {
    
    switch (type) {
        case ThirdLoginShareTypeQQ:
            return [TencentOAuth HandleOpenURL:url];
            break;
        case ThirdLoginShareTypeWeiXin:
            [WXApiManager sharedManager].delegate = self;
            return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
            break;
        case ThirdLoginShareTypeSinaWB:
            return [WeiboSDK handleOpenURL:url delegate:self];
            break;
        default:
            break;
    }
}


#pragma mark - Login
- (void)loginByQQ {
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_IDOL,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_PIC_T,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_DEL_IDOL,
                            kOPEN_PERMISSION_DEL_T,
                            kOPEN_PERMISSION_GET_FANSLIST,
                            kOPEN_PERMISSION_GET_IDOLLIST,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_GET_REPOST_LIST,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                            kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                            nil];
    
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kQQAppID andDelegate:self];
    _tencentOAuth.redirectURI = @"www.qq.com";
    
    if (self.accessTokenQQ) {
        [self.tencentOAuth setAccessToken:self.accessTokenQQ];
    }
    if (self.openIdQQ) {
        [self.tencentOAuth setOpenId:self.openIdQQ];
    }
    if (self.expirationDateQQ) {
        [self.tencentOAuth setExpirationDate:self.expirationDateQQ];
    }
    
    [self.tencentOAuth authorize:permissions inSafari:NO];
}

- (void)loginByWechat {
    NSString *session = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefault_SessionID];
    session = session ? session : @"";
    NSString *kAuthState = [NSString stringWithFormat:@"%d%@", arc4random()%100, session];
    NSString *wxOpenid = [[NSUserDefaults standardUserDefaults] objectForKey:kWXOpenid];
    wxOpenid = wxOpenid ? wxOpenid : kAuthOpenID;
    UIViewController *currentVC = (UIViewController *)self.thirdLoginShareDelegate;
    [WXApiRequestHandler sendAuthRequestScope:kAuthScope State:kAuthState OpenID:wxOpenid InViewController:currentVC];
}

- (void)loginBySinaWeibo {
//    self.request = [WBAuthorizeRequest request];
//    self.request.redirectURI = kWBRedirectURL;
//    self.request.scope = @"all";
//    self.request.shouldShowWebViewForAuthIfCannotSSO = YES;
    
//    self.request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
//                         @"Other_Info_1": [NSNumber numberWithInt:123],
//                         @"Other_Info_2": @[@"obj1", @"obj2"],
//                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}}; //test data
    
    [WeiboSDK sendRequest:self.request];
}

- (WBAuthorizeRequest *)request {
    if (!_request) {
        _request = [WBAuthorizeRequest request];
        _request.redirectURI = kWBRedirectURL;
        _request.scope = @"all";
        _request.shouldShowWebViewForAuthIfCannotSSO = YES;
    }
    
    return _request;
}

#pragma mark - Share
- (BOOL)shareToWeChatWithUserInfo:(NSDictionary *)userInfo {
    [self buildShareInfoWithUserInfo:userInfo];
    int imgId = [self getRandomNumber:1 to:23];
    UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"share_logo%d", imgId]];
    BOOL isSuccess = [WXApiRequestHandler sendLinkURL:self.shareLink
                                              TagName:kLinkTagName
                                                Title:self.shareTitle
                                          Description:self.shareDesc
                                           ThumbImage:thumbImage
                                              InScene:WXSceneSession];
    return isSuccess;
}

- (BOOL)shareToQQWithUserInfo:(NSDictionary *)userInfo {
    [self buildShareInfoWithUserInfo:userInfo];
    NSURL *linkurl = [NSURL URLWithString:self.shareLink];
    int imgId = [self getRandomNumber:1 to:23];
    NSString *imgName = [NSString stringWithFormat:@"share_logo%d@2x", imgId];
    NSString *logoPath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
    NSURL *imageUrl = [NSURL fileURLWithPath:logoPath];
    
    QQApiURLObject *obj = [[QQApiURLObject alloc] initWithURL:linkurl title:self.shareTitle description:self.shareDesc previewImageURL:imageUrl targetContentType:QQApiURLTargetTypeAudio];
    [obj setCflag:kQQAPICtrlFlagQQShare];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:obj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleQQSendResult:sent];
    return YES;
}

- (BOOL)shareToFriendCycleWithUserInfo:(NSDictionary *)userInfo {
    [self buildShareInfoWithUserInfo:userInfo];

    int imgId = [self getRandomNumber:1 to:23];
    UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"share_logo%d", imgId]];
    
    BOOL isSuccess = [WXApiRequestHandler sendLinkURL:self.shareLink
                                              TagName:kLinkTagName
                                                Title:self.shareTitle
                                          Description:self.shareDesc
                                           ThumbImage:thumbImage
                                              InScene:WXSceneTimeline];
    return isSuccess;
}

- (BOOL)shareToZoneWithUserInfo:(NSDictionary *)userInfo {
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kQQAppID
                                                andDelegate:self];
    
    NSURL *linkurl = [NSURL URLWithString:self.shareLink];
    
    int imgId = [self getRandomNumber:1 to:23];
    NSString *imgName = [NSString stringWithFormat:@"share_logo%d@2x", imgId];
    NSString *logoPath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
    NSURL *imageUrl = [NSURL fileURLWithPath:logoPath];
    
//    QQApiObject *newobj = [QQApiNewsObject objectWithURL:linkurl title:kLinkTitle description:kLinkDescription previewImageURL:imageUrl];
    
    QQApiURLObject *obj = [[QQApiURLObject alloc] initWithURL:linkurl title:self.shareTitle description:self.shareDesc previewImageURL:nil targetContentType:QQApiURLTargetTypeAudio];
    //    [obj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
    obj.previewImageData = [NSData dataWithContentsOfURL:imageUrl];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:obj];
    //    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleQQSendResult:sent];
    
    return YES;
}

- (BOOL)shareToSinaWBWithUserInfo:(NSDictionary *)userInfo {
    [self buildShareInfoWithUserInfo:userInfo];
//    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
////    authRequest.redirectURI = kRedirectURI;
//    authRequest.redirectURI = kWBRedirectURL;
//    authRequest.scope = @"all";
//    authRequest.shouldShowWebViewForAuthIfCannotSSO = YES;
    
    WBMessageObject *message = [WBMessageObject message];
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = [NSString stringWithFormat:@"id%ld", (long)[[NSDate date] timeIntervalSince1970]];
    webpage.title = self.shareTitle;
    webpage.description = self.shareDesc;
    
    int imgId = [self getRandomNumber:1 to:23];
    NSString *imgName = [NSString stringWithFormat:@"share_logo%d@2x", imgId];
    // 大小小于32k
    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName ofType:@"png"]];
    webpage.webpageUrl = self.shareLink;
    message.mediaObject = webpage;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:self.request access_token:self.accessTokenSinaWB];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    return [WeiboSDK sendRequest:request];
}

#pragma mark - Helper
- (void)buildShareInfoWithUserInfo:(NSDictionary *)userInfo {
    self.shareTitle = [userInfo valueForKey:@"title"];
    self.shareDesc = [userInfo valueForKey:@"desc"];
    self.shareLink = [userInfo valueForKey:@"url"];
}

- (void)handleQQSendResult:(QQApiSendResultCode)sendResult {
    switch (sendResult) {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

-(int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

#pragma mark - WXApiManagerDelegate
- (void)managerDidRecvAuthResponse:(SendAuthResp *)response{
//    NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d lang:%@ country:%@", response.code, response.state, response.errCode, response.lang, response.country];
    
    NSDate *expiredDate = nil;
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:kWXOpenid];
    NSString *wxAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kWXAccess_Token];
    
//    if (wxAccessToken) {
//        // 2.刷新或续期access_token使用
//        NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:kWXRefresh_Token];
//        NSString *urlForRefreshToken = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", kWXAppID, refreshToken];
//        NSURLRequest *refreshtokenReq = [NSURLRequest requestWithURL:[NSURL URLWithString:urlForRefreshToken]];
//        NSError *error = nil;
//        NSData *refreshTokenRespData = [NSURLConnection sendSynchronousRequest:refreshtokenReq returningResponse:nil error:&error];
//
//        if (refreshtokenReq != nil) {
//            NSError *serialError;
//            NSMutableDictionary *dict = NULL;
//            dict = [NSJSONSerialization JSONObjectWithData:refreshTokenRespData options:NSJSONReadingMutableLeaves error:&serialError];
//            NSLog(@"dict = %@", dict);
//
//            if (dict) {
//                wxAccessToken = [dict valueForKey:@"access_token"];
//                openID = [dict valueForKey:@"openid"];
//                NSString *refresh_token = [dict valueForKey:@"refresh_token"];
////                NSString *scope = [dict valueForKey:@"scope"];
//                NSNumber *expires_in = [dict valueForKey:@"expires_in"];
//                expiredDate = [NSDate dateWithTimeIntervalSinceNow:[expires_in integerValue]];
//                [[NSUserDefaults standardUserDefaults] setValue:refresh_token forKey:kWXRefresh_Token];
//                [[NSUserDefaults standardUserDefaults] setValue:wxAccessToken forKey:kWXAccess_Token];
//                [[NSUserDefaults standardUserDefaults] setValue:openID forKey:kWXOpenid];
//            }
//        }
//        else {
//            // 失败
//        }
//    }
    
    
    [MBProgressHUD showActivityWithText:KeyWindow text:@"登录中..." animated:YES];
    
    //1.通过code获取access_token
    NSString *access_token_URL = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    NSString *params = [NSString stringWithFormat:@"?appid=%@&secret=%@&code=%@&grant_type=authorization_code", kWXAppID, kWXAppAppSecret, response.code];
    NSString *concatUrl = [NSString stringWithFormat:@"%@%@", access_token_URL, params];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:concatUrl]];
    
    NSError *error = nil;
    NSData *tokenRespData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error == nil && tokenRespData != nil) {
        //解析服务端返回json数据
        NSError *error;
        NSMutableDictionary *dict = NULL;
        dict = [NSJSONSerialization JSONObjectWithData:tokenRespData options:NSJSONReadingMutableLeaves error:&error];
        NSLog(@"dict = %@", dict);
        
        wxAccessToken = [dict valueForKey:@"access_token"];
        openID = [dict valueForKey:@"openid"];
        NSString *refresh_token = [dict valueForKey:@"refresh_token"];
        //                NSString *scope = [dict valueForKey:@"scope"];
        NSNumber *expires_in = [dict valueForKey:@"expires_in"];
        expiredDate = [NSDate dateWithTimeIntervalSinceNow:[expires_in integerValue]];
        
        [[NSUserDefaults standardUserDefaults] setValue:refresh_token forKey:kWXRefresh_Token];
        [[NSUserDefaults standardUserDefaults] setValue:wxAccessToken forKey:kWXAccess_Token];
        [[NSUserDefaults standardUserDefaults] setValue:openID forKey:kWXOpenid];
    }
    else {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        [MBProgressHUD showErrormsg:KeyWindow msg:@"授权失败"];
        return;
    }
    
    //3.获取用户个人信息（UnionID机制
    NSString *url_userInfo = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", wxAccessToken, openID];
    NSURLRequest *requestForUserInfo = [NSURLRequest requestWithURL:[NSURL URLWithString:url_userInfo]];
    NSData *userInfoRespData = [NSURLConnection sendSynchronousRequest:requestForUserInfo returningResponse:nil error:nil];
    
    if (userInfoRespData != nil) {
        NSError *error;
        NSMutableDictionary *dict = nil;
        dict = [NSJSONSerialization JSONObjectWithData:userInfoRespData options:NSJSONReadingMutableLeaves error:&error];
        NSLog(@"dict = %@", dict);
        
        // 用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空
        NSString *headimgurl = [dict valueForKey:@"headimgurl"];
        NSString *nickname = [dict valueForKey:@"nickname"];
        NSString *openid = [dict valueForKey:@"openid"]; // 普通用户的标识，对当前开发者帐号唯一
        
        //        NSArray *priviArray = [dict valueForKey:@"privilege"]; // privilege	用户特权信息，json数组，如微信沃卡用户为（chinaunicom）
        //        NSString *unionid = [dict valueForKey:@"unionid"]; // 用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。
        //        NSString *province = [dict valueForKey:@"province"]; // 国家，如中国为CN
        //        NSString *city = [dict valueForKey:@"city"];
        
        // 提交给服务器
        NSMutableDictionary *mdicData = [[NSMutableDictionary alloc] init];
        NSString *expirationDateString = [NSDate stringFromDate:expiredDate format:@"yyyy-MM-dd HH:mm:ss"];
        [mdicData setValue:expirationDateString forKey:@"expirationDate"];
        [mdicData setValue:openid forKey:@"userIdThird"];
        [mdicData setValue:[NSNumber numberWithInteger:ThirdLoginShareTypeWeiXin] forKey:@"platformType"];
        [mdicData setValue:wxAccessToken forKey:@"accessToken"];
        [mdicData setValue:nickname forKey:@"nickname"];
        [mdicData setValue:headimgurl forKey:@"avatarUrl"];
        [self.thirdLoginShareDelegate requestSaveThirdUserInfo:mdicData];
    }
    else {
        [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
        [MBProgressHUD showAlert:@"提示" msg:@"登录失败！" delegate:nil cancelBtnTitle:@"确定"];
    }
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin {
    self.accessTokenQQ    = self.tencentOAuth.accessToken;
    self.openIdQQ         = self.tencentOAuth.openId;
    self.expirationDateQQ = self.tencentOAuth.expirationDate;  //有效期三个月
    
//    NSDictionary *postData = self.tencentOAuth.passData;
    
    if (self.accessTokenQQ.length > 0) {
        [MBProgressHUD showActivityWithText:KeyWindow text:@"登录中..." animated:YES];
        
        //发起回调 getUserInfoResponse函数
        BOOL isSuccess = [self.tencentOAuth getUserInfo];
        if (!isSuccess) {
            [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
            [MBProgressHUD showAlert:@"提示" msg:@"登录失败！" delegate:nil cancelBtnTitle:@"确定"];
        }
    }
    else {
        [MBProgressHUD showAlert:@"提示" msg:@"登录失败\n没有获取到AccessToken!\n" delegate:nil cancelBtnTitle:@"确定"];
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
    [MBProgressHUD showAlert:@"提示" msg:@"登录失败！" delegate:nil cancelBtnTitle:@"确定"];
}

/**
 * 登录时网络有问题的回调！
 */
- (void)tencentDidNotNetWork {
    [MBProgressHUD showAlert:@"提示" msg:@"登录失败\n网络出错!\n" delegate:nil cancelBtnTitle:@"确定"];
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*) response {
    NSMutableDictionary *mdicData = [[NSMutableDictionary alloc] init];
    [mdicData setValue:self.openIdQQ forKey:@"userIdThird"];
    [mdicData setValue:[NSNumber numberWithInteger:ThirdLoginShareTypeQQ] forKey:@"platformType"];
    [mdicData setValue:self.accessTokenQQ forKey:@"accessToken"];
    
    NSDate *expirated = self.tencentOAuth.expirationDate;
    NSString *expirationDateString = [NSDate stringFromDate:expirated format:@"yyyy-MM-dd HH:mm:ss"];
    [mdicData setValue:expirationDateString forKey:@"expirationDate"];

    if (response.retCode == URLREQUEST_SUCCEED && response.detailRetCode == kOpenSDKErrorSuccess) {

#ifdef DEBUG
        NSLog(@"QQ message = %@", response.message);
#endif
        
        NSDictionary *dic = response.jsonResponse;
        NSString *nickName = [dic valueForKey:@"nickname"];
        NSString *avatarUrl = [dic valueForKey:@"figureurl_qq_2"]; // 100*100px
        
//        NSString *gender = [dic valueForKey:@"gender"];
//        NSString *age = [dic valueForKey:@"age"];
        
        [mdicData setValue:nickName forKey:@"nickname"];
        if (avatarUrl) {
            [mdicData setValue:avatarUrl forKey:@"avatarUrl"];
        }
    }
    else {
        NSLog(@"QQ message = %@", response.message);
    }
    
    if (self.thirdLoginShareDelegate) {
        [self.thirdLoginShareDelegate requestSaveThirdUserInfo:mdicData];
    }
}


#pragma mark - WeiboSDKDelegate
/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
    //    WeiboSDKResponseStatusCodeSuccess               = 0,//成功
    //    WeiboSDKResponseStatusCodeUserCancel            = -1,//用户取消发送
    //    WeiboSDKResponseStatusCodeSentFail              = -2,//发送失败
    //    WeiboSDKResponseStatusCodeAuthDeny              = -3,//授权失败
    //    WeiboSDKResponseStatusCodeUserCancelInstall     = -4,//用户取消安装微博客户端
    //    WeiboSDKResponseStatusCodePayFail               = -5,//支付失败
    //    WeiboSDKResponseStatusCodeShareInSDKFailed      = -8,//分享失败 详情见response UserInfo
    //    WeiboSDKResponseStatusCodeUnsupport             = -99,//不支持的请求
    //    WeiboSDKResponseStatusCodeUnknown               = -100,
    
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        WBSendMessageToWeiboResponse *sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        if (OBJHASVALUE(sendMessageToWeiboResponse.authResponse)) {
            self.accessTokenSinaWB = [sendMessageToWeiboResponse.authResponse accessToken];
        }

        
        //        if (accessToken)
        //        {
        //            self.wbtoken = accessToken;
        //        }
        //        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        //        if (userID) {
        //            self.wbCurrentUserID = userID;
        //        }
        //        [alert show];
        //        [alert release];
        
    } else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"授权失败"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
//                        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
           
            [MBProgressHUD showActivityWithText:KeyWindow text:Tips_Loading animated:YES];
            
            WBAuthorizeResponse *authResp = (WBAuthorizeResponse *)response;
            self.accessTokenSinaWB = authResp.accessToken;
            
//            NSDictionary *requestUserInfo = response.requestUserInfo;
            NSString *refreshToken = authResp.refreshToken;
//            NSDictionary *userInfoDic = authResp.userInfo;
            
            NSMutableDictionary *respUserInfoDic = [NSMutableDictionary dictionary];
            NSString *expirationDateString = [NSDate stringFromDate:authResp.expirationDate format:@"yyyy-MM-dd HH:mm:ss"];
            [respUserInfoDic setValue:expirationDateString forKey:@"expirationDate"];
            [respUserInfoDic setValue:authResp.userID forKey:@"userIdThird"];
            [respUserInfoDic setValue:[NSNumber numberWithInteger:ThirdLoginShareTypeSinaWB] forKey:@"platformType"];
            [respUserInfoDic setValue:self.accessTokenSinaWB forKey:@"accessToken"];
            
            // 获取用户资料 https://api.weibo.com/2/users/show.json
            
            static NSString * const weiboShowUrl = @"https://api.weibo.com/2/users/show.json";
            NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
            [paramsDic setValue:kWBAppKey forKey:@"source"];
            [paramsDic setValue:self.accessTokenSinaWB forKey:@"access_token"];
            [paramsDic setValue:authResp.userID forKey:@"uid"];
            
            if (self.dataTaskForSinaweibo) {
                [self.dataTaskForSinaweibo cancel];
            }
            
            self.dataTaskForSinaweibo = [[NRNetworkClient sharedClient] GET:weiboShowUrl parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSString *screen_name = [responseObject valueForKey:@"screen_name"]; // 昵称
                NSString *avatar_large = [responseObject valueForKey:@"avatar_large"];
                [respUserInfoDic setValue:screen_name forKey:@"nickname"];
                [respUserInfoDic setValue:avatar_large forKey:@"avatarUrl"];
                
                if (self.thirdLoginShareDelegate) {
                    [self.thirdLoginShareDelegate requestSaveThirdUserInfo:respUserInfoDic];
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD hideActivityWithText:KeyWindow animated:YES];
                [MBProgressHUD showErrormsgWithoutIcon:KeyWindow title:@"登录出错" detail:nil];
            }];
        }
    }
    else if ([response isKindOfClass:WBPaymentResponse.class]) {
//        NSString *title = NSLocalizedString(@"支付结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        
    }
}

@end
