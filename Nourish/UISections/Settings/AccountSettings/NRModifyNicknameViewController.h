//
//  NRModifyNicknameViewController.h
//  Nourish
//
//  Created by tcguo on 15/11/7.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRBaseViewController.h"
#import "NRAccountSettingsVC.h"

@interface NRModifyNicknameViewController : NRBaseViewController

- (instancetype)initWithNickName:(NSString *)nickname;

@property (nonatomic, readonly, copy) NSString *nickName;

@end
