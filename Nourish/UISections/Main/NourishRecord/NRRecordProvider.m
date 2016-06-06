//
//  NRRecordProvider.m
//  Nourish
//
//  Created by tcguo on 15/11/20.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordProvider.h"
#import "NRRecordDetailModel.h"
#import "NREnergyElementModel.h"
#import "NRLoginManager.h"

@interface NRRecordProvider ()

@property (nonatomic, weak) NSURLSessionDataTask *requestDailyRecord;

@end


@implementation NRRecordProvider

- (void)requestDailyRecordWithDate:(NSDate *)date completeBlock:(CompleteBlock)completeBlock {
    
    if (self.requestDailyRecord) {
        [self.requestDailyRecord cancel];
    }
    
    NSString *strDate = [NSDate stringFromDate:date format:nil];
    NSMutableDictionary *mdicParams = [NSMutableDictionary dictionary];
    [mdicParams setValue:strDate forKey:@"date"];

    self.requestDailyRecord = [[NRNetworkClient sharedClient] sendPost:@"mynourish/daily/record" parameters:mdicParams success:^(NSURLSessionDataTask *task, NSInteger errorCode, NSString *errorMsg, id res) {
        
        NSError *error = nil;
        NRRecordInfo *recordInfo = nil;
        
        if (errorCode == 0) {
            recordInfo = [[NRRecordInfo alloc] init];
            recordInfo.isVisitor   = [(NSNumber *)[res valueForKey:@"isVisitor"] boolValue];
            recordInfo.isNewUser   = [(NSNumber *)[res valueForKey:@"isNewUser"] boolValue];
            recordInfo.isOrderDate = [(NSNumber *)[res valueForKey:@"isOrderDate"] boolValue];
            recordInfo.userMod = [[NRUserInfoModel alloc] init];
            
            NSDictionary *userInfoDictionary = [res valueForKey:@"userInfo"];
            recordInfo.userMod.nickName  = [userInfoDictionary valueForKey:@"nickname"];
            recordInfo.userMod.age       = [(NSNumber *)[userInfoDictionary valueForKey:@"age"] unsignedIntegerValue];
            recordInfo.userMod.height    = [(NSNumber *)[userInfoDictionary valueForKey:@"height"] unsignedIntegerValue];
            recordInfo.userMod.weight    = [(NSNumber *)[userInfoDictionary valueForKey:@"weight"] unsignedIntegerValue];
            recordInfo.userMod.gender    = [(NSNumber *)[userInfoDictionary valueForKey:@"gender"] integerValue];
            recordInfo.userMod.avatarurl = [userInfoDictionary valueForKey:@"avatarUrl"];
            
//            if (recordInfo.isVisitor) {
//                // 游客，返回的诺小食的信息
//               
//            }
//            else {
//                
//                NRLoginManager *localUserInfo = [NRLoginManager sharedInstance];
//                recordInfo.userMod.nickName  = localUserInfo.nickName;
//                recordInfo.userMod.age       = [localUserInfo.age unsignedIntegerValue];
//                recordInfo.userMod.height    = [localUserInfo.height unsignedIntegerValue];
//                recordInfo.userMod.weight    = [localUserInfo.weight unsignedIntegerValue];
//                recordInfo.userMod.avatarurl = localUserInfo.avatarUrl;
//                recordInfo.userMod.gender    =
//            }
            
            // 当天信息
            NSDictionary *dayInfoDict = [res valueForKey:@"dayInfo"];
            if (!DICTIONARYHASVALUE(dayInfoDict)) {
                recordInfo.dayMod = nil;
            }
            else {
                recordInfo.dayMod              = [[NRRecordDayInfo alloc] init];
                recordInfo.dayMod.dayth        = [(NSNumber *)[dayInfoDict valueForKey:@"dayth"] unsignedIntegerValue];
                recordInfo.dayMod.themeName    = [dayInfoDict valueForKey:@"themeName"];
                recordInfo.dayMod.themeContent = [dayInfoDict valueForKey:@"themeContent"];
                recordInfo.dayMod.wpName       = [dayInfoDict valueForKey:@"wpName"];
                NSNumber *nrProvider           = [res valueForKey:@"nrProvide"];
                recordInfo.dayMod.nrProvide    = [nrProvider unsignedIntegerValue];
            }
            
            // 推荐软文
            NSArray *arrArticles = [res valueForKey:@"articles"];
            if (ARRAYHASVALUE(arrArticles)) {
                recordInfo.articles = [NSMutableArray array];
                for (NSDictionary *dic in arrArticles) {
                    NRRecordArticleInfo *article = [[NRRecordArticleInfo alloc] init];
                    article.title    = [dic valueForKey:@"title"];
                    article.subTitle = [dic valueForKey:@"partial"];
                    article.imageUrl = [dic valueForKey:@"imageUrl"];
                    article.pageUrl  = [dic valueForKey:@"pageUrl"];
                    [recordInfo.articles addObject:article];
                }
            }
            
            // 一天套餐营养
            NSArray *arrMeals = [res valueForKey:@"meals"];
            if (ARRAYHASVALUE(arrMeals)) {
                recordInfo.dinnerDetails = [NSMutableArray array];
                for (NSDictionary *dicSingleMeal in arrMeals) {
                    
                    NRRecordDetailModel *mod = [[NRRecordDetailModel alloc] init];
                    mod.isLoad               = NO;
                    mod.dinnerType           = [(NSNumber*)[dicSingleMeal valueForKey:@"mealType"] integerValue];
                    mod.distributionTime     = [dicSingleMeal valueForKey:@"time"];
                    mod.warmTips             = [dicSingleMeal valueForKey:@"desc"];
                    mod.setmealImageUrl      = [dicSingleMeal valueForKey:@"imageUrl"];
                    mod.marrSingleFoodNames  = [NSMutableArray array];
                    NSArray *arrSingleFoods  = [dicSingleMeal valueForKey:@"singleFoods"];
                    if (ARRAYHASVALUE(arrSingleFoods)) {
                        mod.marrEnergyList = [NSMutableArray array];
                        for (NSDictionary *dicSingleFood in arrSingleFoods) {
                            NREnergyElementModel *eleMod = [[NREnergyElementModel alloc] init];
                            eleMod.elementName  = [dicSingleFood valueForKey:@"name"];
                            eleMod.reliangVal   = [dicSingleFood valueForKey:@"calorie"];
                            eleMod.zhifangVal   = [dicSingleFood valueForKey:@"fatness"];
                            eleMod.danbaizhiVal = [dicSingleFood valueForKey:@"protein"];
                            eleMod.huahewuVal   = [dicSingleFood valueForKey:@"carbonhy"];
                            eleMod.qianweisuVal = [dicSingleFood valueForKey:@"cellulose"];
                            
                            [mod.marrEnergyList addObject:eleMod];
                            [mod.marrSingleFoodNames addObject:eleMod.elementName];
                        }
                    }
                    
                    [recordInfo.dinnerDetails addObject:mod];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(recordInfo, error);
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil, error);
        });
    }];
}

@end


@implementation NRRecordInfo


@end
