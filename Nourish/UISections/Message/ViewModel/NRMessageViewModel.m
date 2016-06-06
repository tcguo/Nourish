//
//  NRMessageViewModel.m
//  Nourish
//
//  Created by tcguo on 16/3/29.
//  Copyright © 2016年 ___BaiduMGame___. All rights reserved.
//

#import "NRMessageViewModel.h"

@interface NRMessageViewModel ()

@property (nonatomic, assign, readwrite) NSInteger nextPageIndex;
@property (nonatomic, weak) RACDisposable *loadDispose;
@property (nonatomic, weak) RACDisposable *moreDispose;

@end

@implementation NRMessageViewModel

- (RACSignal *)loadMessageWithParametres:(NSDictionary *)parametres {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (self.loadDispose) {
            [self.loadDispose dispose];
        }
        
        self.loadDispose = [[self.networkClient rac_sendPost:@"msg/list" parameters:parametres] subscribeNext:^(id res) {
            NSNumber *nextPage = [res valueForKey:@"nextPageIndex"];
            self.nextPageIndex = [nextPage integerValue];
            NSMutableArray *messages = [res valueForKey:@"messages"];
            for (NSDictionary *msg in messages) {
                NRSystemMessageModel *mod = [[NRSystemMessageModel alloc] init];
                mod.title = [msg valueForKey:@"title"];
                mod.coverImageUrl = [msg valueForKey:@"imageUrl"];
                NSNumber *type = [msg valueForKey:@"type"];
                mod.msgType = [type intValue];
                mod.linkUrl = [msg valueForKey:@"detailUrl"];
                mod.date = [msg valueForKey:@"date"];
                [messages addObject:mod];
            }
            [subscriber sendNext:messages];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return self.loadDispose;
    }];
}

@end
