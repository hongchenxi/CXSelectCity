//
//  HCXSelectCityController.m
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/22.
//  Copyright © 2016年 洪晨希. All rights reserved.
//

#import "HCXSelectCityController.h"
#import <Masonry.h>
#import "HCXHeadSectionCell.h"
@interface HCXSelectCityController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSArray *englishKeys;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, copy) NSDictionary *cityDict;

@property (nonatomic, copy) NSArray *hotCitys;
@end

@implementation HCXSelectCityController

- (NSMutableArray *)keys {
    if (!_keys) {
        _keys = [NSMutableArray array];
    }
    return _keys;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择城市";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSearchBar];
    [self setupContentTableView];
    [self loadData];
    self.hotCitys = @[@"上海",@"北京",@"广州",@"深圳",@"武汉",@"天津",@"西安",@"南京",@"杭州"];
}

- (void)setupSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.placeholder = @"输入城市名或拼音查询";
    searchBar.tintColor = [UIColor colorWithRed:242/255.0 green:87/255.0 blue:45/255.0 alpha:1.0];
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(64);
    }];
}

- (void)setupContentTableView {
    UITableView *contentTableView = [[UITableView alloc]init];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    [self.view addSubview:contentTableView];
    self.tableView = contentTableView;
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

- (void)loadData {
    NSURL *fileUrl = [[NSBundle mainBundle]URLForResource:@"citydict.plist" withExtension:nil];
    NSDictionary *tempDict = [NSDictionary dictionaryWithContentsOfURL:fileUrl];
    self.cityDict = tempDict;
    NSArray *chineseWordKey = @[@"定位城市", @"最近访问城市", @"热门城市"];
    self.englishKeys = [tempDict.allKeys sortedArrayUsingSelector:@selector(compare:)];
    [self.keys addObjectsFromArray:chineseWordKey];
    [self.keys addObjectsFromArray:self.englishKeys];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *cityArray = [self.cityDict objectForKey:self.keys[section]];
    return cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellHeadSectionIdentifier = @"HeadSectionCell";
    static NSString *cellIdentifier = @"Cell";
    
    HCXHeadSectionCell *headSectionCell = [tableView dequeueReusableCellWithIdentifier:cellHeadSectionIdentifier];
    
   NSInteger section =  indexPath.section;
    if (!headSectionCell) {
        headSectionCell = [[[NSBundle mainBundle]loadNibNamed:@"HCXHeadSectionCell" owner:nil options:nil]lastObject];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
     if((section == 2 || section == 0 || section == 1) && [self.tableView isEqual:tableView]){  //如果为头部Section
        if (indexPath.section == 0) {
            headSectionCell.citys = self.hotCitys;
            return headSectionCell;
        }
     }
    NSArray *cityArray = [self.cityDict objectForKey:self.keys[indexPath.section]];
    cell.textLabel.text = cityArray[indexPath.row];
    
    return cell;
}


- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *firstKeys = @[@"#", @"$", @"*"];
    return [firstKeys arrayByAddingObjectsFromArray:self.englishKeys];;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return self.keys[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 70;
    }
    return 40;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar endEditing:YES];
}

@end
