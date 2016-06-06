//
//  NRShareActivityView.h
//  Nourish
//
//  Created by tcguo on 15/12/11.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRActivityView.h"

typedef void(^ShareBlock)();
@interface NSShareViewItem : NSObject

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName shareBlock:(ShareBlock)block;
@property (nonatomic, copy) ShareBlock shareBlock;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *title;

@end

@interface NRShareActivityView : NRActivityView

@property (nonatomic, strong) NSMutableArray *dataArray;

@end


