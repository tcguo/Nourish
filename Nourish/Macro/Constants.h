//
//  Constants.h
//  Nourish
//
//  Created by gtc on 14/12/26.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#ifndef Nourish_Constants_h
#define Nourish_Constants_h

#define bgColorWithImageName(o)                 [UIColor colorWithPatternImage:[UIImage imageNamed:(o)]]
#define IMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"BMGame" withExtension:@"bundle"]] pathForResource:file ofType:ext]]
// ---
#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define RgbHex2UIColor(r, g, b)                 [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define RgbHex2UIColorWithAlpha(r, g, b, a)     [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]
#define CArrayLength(arr)                       (sizeof(arr) / sizeof(*(arr)))
#define GetStringFromCArraySafely(arr, idx)     (((idx) >= 0) && (((idx) < CArrayLength(arr))) ? (arr)[idx] : @"")
#define GetNumberFromCArraySafely(arr, idx)     (((idx) >= 0) && (((idx) < CArrayLength(arr))) ? (arr)[idx] : 0)
#define NSNumWithInt(i)                         ([NSNumber numberWithInt:(i)])
#define NSNumWithFloat(f)                       ([NSNumber numberWithFloat:(f)])
#define NSNumWithBool(b)                        ([NSNumber numberWithBool:(b)])
#define IntFromNSNum(n)                         ([(n) intValue])
#define FloatFromNSNum(n)                       ([(n) floatValue])
#define BoolFromNSNum(n)                        ([(n) boolValue])
#define ToString(o)                             [NSString stringWithFormat:@"%@", (o)]
#define ToImage(o)                              [UIImage imageNamed:(o)]



#define WeakSelf(s)  __weak typeof(s) weakSelf = s

// 判断字符串是否有值
#define STRINGHASVALUE(str)		(str && [str isKindOfClass:[NSString class]] && [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
// 判断obj 不为空
#define OBJHASVALUE(obj) (obj!=nil&&![obj isKindOfClass:[NSNull class]])
// 判断字典是否有值
#define DICTIONARYHASVALUE(dic)    (dic && [dic isKindOfClass:[NSDictionary class]] && [dic count] > 0)
// 判断数组是否有值
#define ARRAYHASVALUE(array)    (array && [array isKindOfClass:[NSArray class]] && [array count] > 0)
// 判断对象是否为null值
#define OBJECTISNULL(obj)       [obj isEqual:[NSNull null]]

#define TempPath        NSTemporaryDirectory()
#define CachesPath      [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define DocumentsPath   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
// ------

#define kAppUIScaleX   (SCREEN_HEIGHT > 480 ? SCREEN_WIDTH/320 : 1.0)
#define kAppUIScaleY   (SCREEN_HEIGHT > 480 ? SCREEN_HEIGHT/568 : 1.0)

// Color
#define ColorRed_Normal  RgbHex2UIColor(0xf2, 0x44, 0x27)
#define ColorRed_Seleted  RgbHex2UIColor(0xd3, 0x46, 0x1e)
#define ColorViewBg RgbHex2UIColor(0xec, 0xeb, 0xf1)
#define ColorGrayDisabled RgbHex2UIColor(0xdb, 0x65, 0x3d)
#define ColorGrayBg RgbHex2UIColor(0xf2, 0xf2, 0xf2)
#define ColorGragBorder RgbHex2UIColor(0xda, 0xda, 0xda)
#define ColorLine RgbHex2UIColor(0xbe, 0xbc, 0xbd)
#define ColorBaseFont RgbHex2UIColor(0x67, 0x67, 0x67)
#define ColorPlaceholderFont RgbHex2UIColor(0xaa, 0xaa, 0xaa)

//control height
#define ButtonDefaultWidth 280
#define ButtonDefaultHeight 44
#define TextFieldDefaultHeight 40
#define TextFieldDefaultWidth 280
#define LabelDefaultHeight 15

//FontSize
#define SpacingBetweenTextFieldAndLabel 2
#define CornerRadius 3.0f
#define FontButtonTitleSize 18
#define FontNavTitleSize 19
#define FontNavBarButtonTextSize 16
#define FontLabelSize 15
#define FontTextFieldSize 16
#define LineSpacing 3 //Label多行的行间距

//Const
#define kAlphaNum                           @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@._"
#define kAlpha                              @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
#define kNumbers                            @"0123456789"
#define kPageSize                           20

//#define kUserDefault_ThirdLoginType         @"ThirdLoginType"
#define kUserDefault_Token                  @"userToken"
#define kUserDefault_SessionID              @"sessionid"
#define kUserDefault_UserInfo               @"UserInfo"
#define kUserDefault_ShowIntroduction       @"ShowIntroduction"
#define kUserDefault_CustomerPhone          @"kCustomerPhone"

//notifition name
#define kNotiName_LoginSuccess              @"LoginSuccess"
#define kNotiName_LogoutSuccess             @"LogoutSuccess"
#define kNotiName_UpdateUserAvatar          @"UpdateUserAvatar" //通知更新用户头像
#define kNotiName_UpdateNickName            @"UpdateNickName"//通知更新用户昵称
#define kNotiName_UpdateUserAgeAndWeight    @"UpdateAgeAndWeight"//通知更新年龄性别身高体重
#define kNotiName_UpdateBindPhone           @"kNotiName_UpdateBindPhone"

//#define kNotiName_RefreshCurrOrder          @"kNotiName_RefreshCurrOrder" //刷新当前订单

#define keyAddressVersion                   @"keyAddressVersion"
#define keyLatitude                         @"keyLatitude" //维度
#define keyLongitude                        @"keyLongitude"//经度
#define kErrorMsg                           @"errorMsg"

//--高德key
#ifdef NRENTERPRISE
    #define kAMapKey                            @"7e96e77edca7ca3bcc747242443b1c2f"
#else
    #define kAMapKey                            @"06ea8381a7ae64efa9d271ee767f49dc"
#endif

//--BaiduPush
#define kBaiduPushApiKey                    @"uZUZbNLgEDNXj30OGsNTHqFb"
//-- BaiduMobSat百度移动统计
#define kBaiduMobStatAppKey                 @"9c511acd9e"

//--SinaWeibo SDK
#define kWBAppKey                           @"2699622755"
#define kWBAppSecret                        @"57c9db8eda380e1b9e0a87d73d7d833d"
#define kWBRedirectURL                      @"https://api.weibo.com/oauth2/default.html"
//---Wechat SDK
#define kWXAppID                            @"wxf8f1651a10ff8593"
#define kWXAppAppSecret                     @"3bc0ceb6414d863556ebd364ddcd2b65"
#define kWXAccess_Token                     @"WXAccess_Token" // 保存微信访问token的 key
#define kWXRefresh_Token                    @"WXRefresh_Token"
#define kWXOpenid                           @"WXOpenid"

//---QQ SDK
#define kQQAppID                            @"1104881055"
#define kQQAPPKEY                           @"ZMYzrnGVOok8cGSD"

//---Douban SDK
#define kDoubanAPIKey                       @"0496a414ae3475be0dc3ec3e0a9d613a"
#define kDoubanSecret                       @"a0a2f7cd9ab4cd6b"
//---友盟
#define kUMengAppkey                        @"56ef667f67e58e8592000f2f"

//OS version
#define  isViewLandscape  UIInterfaceOrientationIsLandscape(self.previousOrientation)
#define  ISIOS6          [[[UIDevice currentDevice]systemVersion] floatValue]<7.0
#define  ISIOS7_OR_LATER [[[UIDevice currentDevice]systemVersion] floatValue]>=7.0
#define  ISIOS8_OR_LATER [[[UIDevice currentDevice]systemVersion] floatValue]>=8.0
#define  ISIOS9_OR_LATER [[[UIDevice currentDevice]systemVersion] floatValue]>=9.0

#define NAV_BAR_HEIGHT (ISIOS7_OR_LATER? 64 : 44)
#define TAB_BAR_HEIGHT          [[UIApplication sharedApplication] statusBarFrame].size.height
#define KeyWindow               [UIApplication sharedApplication].keyWindow
#define SCREEN_WIDTH			([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT			([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_SCALE            (1.0f/[UIScreen mainScreen].scale)

// custom font
#define NRFontName @"NotoSansHans-Light"
#define NRFont(fontsize)  [UIFont fontWithName:NRFontName size:(fontsize)]
#define SysFont(fontsize)  [UIFont systemFontOfSize:(fontsize)]
#define SysBoldFont(fontsize) [UIFont systemFontOfSize:(fontsize)]

// 排除不做适配的viewTag
#define ExceptTag 9999
#define AppDelegateInstance (AppDelegate *)[UIApplication sharedApplication].delegate

// 当前开通的城市 code
#define CoverCities @[ @"010" ]
// 默认加载图片
#define DefaultImageName @"wpt-default"
#define DefaultImageName_Avatar @"avatar-default"

// 提示语
#define Tips_Loading @"加载中..."
#define Tips_NoNetwork @"网络不可用"
#define Tips_ServiceException @"接口数据异常"
#define Tips_NetworkError @"网络请求失败"
#define Tips_NetworkTimeOut @"请求超时,请稍后重试"

#define Tips_LOAD_WAITING                   @"加载中,请稍等..."
#define Tips_LOAD_NO_MORE                   @"没有更多了"
#define Tips_LOAD_NETWORKFAIL_AND_RETRY     @"数据加载失败,请检查网络连接后点击重试"
#define Tips_LOAD_SERVERFAIL_AND_RETRY      @"数据加载失败,请稍后重试"
#define Tips_LOAD_NO_DATA                   @"暂无数据"


#import "AppDelegate.h"
CG_INLINE CGRect
CGRectMakeNew(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX;
    rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX;
    rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}

typedef NS_ENUM(NSUInteger, DinnerType) {
    DinnerTypeZao = 1,
    DinnerTypeWu = 2,
    DinnerTypeCha = 3,
};

typedef NS_ENUM(NSUInteger, DinnerPrice) {
    DinnerPriceZao = 49,
    DinnerPriceWu = 39,
    DinnerPriceCha = 59,
};


typedef NS_ENUM(NSUInteger, WeekDay) {
    WeekDayMonday = 1,
    WeekDayTuesday =2,
    WeekDayWedensday =3,
    WeekDayThursday =4,
    WeekDayFirday = 5,
    WeekDaySaturday = 6,
    WeekDaySunday =7,
};

typedef NS_ENUM(NSUInteger, PayType) {
    PayTypeNone = 0,
    PayTypeAli = 1,
    PayTypeWeChat = 2,
};

typedef NS_ENUM(NSInteger, GenderType) {
    GenderTypeMale = 1,
    GenderTypeFemale = -1,
    GenderTypeUnknown = 0,
};

typedef NS_ENUM(NSInteger, NRRequestError) {
    NRRequestErrorNetworkDisAvailablity = 101,
    NRRequestErrorServiceError, // 接口失败
    NRRequestErrorParseJsonError,
    NRRequestErrorNetworkException,
    NRRequestErrorNetworkTimeOut,
    NRRequestErrorCancelled,
};

/**
 *  订单状态
 */
typedef NS_ENUM(NSUInteger, OrderStatus){
    /**
     *  待付款 操作：支付+取消
     */
    OrderStatusPaying = 0,
    /**
     * (支付完成)已确认 操作：打客服
     */
     OrderStatusPayCompleted = 1,
    /**
     *待执行 操作：打客服
     */
    OrderStatusToRun = 2,
    /**
     *正在执行 操作：变更+退款
     */
    OrderStatusRunning = 3,
    /**
     * 待评价 操作：评价+分享+再来一周
     */
    OrderStatusToComment = 4,
    /**
     *  订单评价完成了订单终止 操作：分享+再来一周
     */
    OrderStatusDone = 5,
    /**
     * 变更中 操作:半小时内可取消+之后打客服
     */
     OrderStatusChanging = 100,
    /**
     * 变更成功 操作:打客服
     */
    OrderStatusChangeSuccess = 101,
    /**
     * 退款中 操作:1小时内可取消+之后打客服
     */
    OrderStatusRefunding = 200,
    /**
     * //已退款
     */
     OrderStatusRefunded = 201,
    
    /**
     * //用户已取消
     */
     OrderStatusCancelled = 1000,
    /**
     * //系统取消的超时未支付
     */
     OrderStatusCancelTimeOut = 1001,
    /**
     * //商家确认下单失败
     */
    OrderStatusConfirmFailure = 1002,
    /**
     * //客服关闭订单
     */
    OrderStatusClosed = 1003,
    /**
     * //商家确认变更失败 操作:打客服
     */
     OrderStatusChangeFailure = 1004,
};

#endif
