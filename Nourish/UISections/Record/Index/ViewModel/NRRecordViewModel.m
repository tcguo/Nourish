//
//  NRRecordViewModel.m
//  Nourish
//
//  Created by tcguo on 16/4/6.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordViewModel.h"

@interface NRRecordViewModel ()

@property (nonatomic, copy, readwrite) NSString *shareTitle;
@property (nonatomic, copy, readwrite) NSString *shareDesc;
@property (nonatomic, copy, readwrite) NSString *shareLink;

@property (nonatomic, weak) RACDisposable *shareDispose;

@end

@implementation NRRecordViewModel

- (RACSignal *)fetchShareInfoWithParametres:(NSDictionary *)params {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.shareDispose) {
            [self.shareDispose dispose];
        }
        self.shareDispose = [[self.networkClient rac_sendPost:@"share/make/nourish-record" parameters:params] subscribeNext:^(id res) {
            self.shareTitle = [res valueForKey:@"title"];
            self.shareDesc = [res valueForKey:@"desc"];
            self.shareLink = [res valueForKey:@"url"];
            [subscriber sendNext:self];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return self.shareDispose;
    }];
}
@end
