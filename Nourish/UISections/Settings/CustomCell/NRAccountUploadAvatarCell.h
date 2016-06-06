//
//  NRAccountUploadAvatarCell.h
//  Nourish
//
//  Created by tcguo on 15/10/31.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRTableViewBaseCell.h"
#import "NRLoginManager.h"

@interface NRAccountUploadAvatarCell : NRTableViewBaseCell

- (void)updateUserAvatarWith:(NRLoginManager *)userInfo;

@end
