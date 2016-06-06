//
//  NRRecordArticleViewController.m
//  Nourish
//
//  Created by tcguo on 15/11/20.
//  Copyright © 2015年 ___BaiduMGame___. All rights reserved.
//

#import "NRRecordArticleViewController.h"
#import "NRRecordArticleCell.h"
#import "NRRecordArticleInfo.h"
#import "NRRecordArticleDetailViewController.h"

@interface NRRecordArticleViewController ()

@property (nonatomic, strong) NRRecordArticleDetailViewController *articleDetailVC;

@end


@implementation NRRecordArticleViewController

- (void)viewDidLoad {
    [super viewDidLoadWithBarStyle:NRBarStyleLeftNone];
    // Do any additional setup after loading the view.
    self.tableView.scrollsToTop = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _articles = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}


- (void)setArticles:(NSMutableArray *)articles {
    _articles = articles;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

- (NRRecordArticleCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *recordArticleIdentifier = @"recordArticleIdentifier";
    NRRecordArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:recordArticleIdentifier];
    if (!cell) {
        cell = [[NRRecordArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recordArticleIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NRRecordArticleInfo *article = [self.articles objectAtIndex:indexPath.row];
    cell.articleInfo = article;
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 356/2*self.appdelegate.autoSizeScaleY+196/2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NRRecordArticleInfo *article = [self.articles objectAtIndex:indexPath.row];
    if (!self.articleDetailVC) {
        _articleDetailVC = [[NRRecordArticleDetailViewController alloc] init];
        _articleDetailVC.hidesBottomBarWhenPushed = YES;
    }
    
    self.articleDetailVC.articleTitle = article.title;
    self.articleDetailVC.detailUrl = article.pageUrl;
    
    [self.navigationController pushViewController:self.articleDetailVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
