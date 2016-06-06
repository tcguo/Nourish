//
//  Config.h
//  Nourish
//
//  Created by gtc on 14/12/26.
//  Copyright (c) 2014年 ___BaiduMGame___. All rights reserved.
//

#ifndef Nourish_Config_h
#define Nourish_Config_h

#define APPNAME         @"诺食营养周"
#define APPNAME_En      @"Nourish"
#define Channel         @"100"
#define NourishDomain   @"NuoShiJi"

#define NourishVersion  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define DeviceName      [[UIDevice currentDevice] model]
#define OSName          [[UIDevice currentDevice] systemName]
#define OSVersion       [[UIDevice currentDevice] systemVersion]
#define OS              [NSString stringWithFormat:@"%@%@", OSName, OSVersion]
#define UUID            [[UIDevice currentDevice] identifierForVendor].UUIDString

#define AESKEY          @"^n0ur!shn0ur!sh$"
#define kCustomerPhone  @"18613866345"

//#define NourishBaseURLString                @"http://182.92.175.68:8080/appdata/"
#define NourishBaseURLString                @"http://appdata.51nourish.com/"

#define NourishHomePage                     @"http://www.51nourish.com/"

#define NR_APP_STORE_SOCRE_NEWURL           @"itms-apps://itunes.apple.com/app/id"
#define NR_APP_STORE_APPLEID                @"1073511962"

#endif
