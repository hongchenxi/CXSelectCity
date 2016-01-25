//
//  HCXSelectCityController.m
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/22.
//  Copyright © 2016年 洪晨希. All rights reserved.
//

#import "HCXSelectCityController.h"
#import <Masonry.h>
#import "HCXCity.h"
#import <Realm/Realm.h>
#import <CoreData/CoreData.h>
#import "HCXVisitedCity+CoreDataProperties.h"
static const CGFloat marginX = 15.0f;
static const CGFloat marginY = 10.0f;
static const CGFloat buttonHeight = 35.0f;
static const NSUInteger count = 3;//每行显示个数

@interface HCXSelectCityController ()<UITableViewDataSource, UITableViewDelegate> {
    UISearchBar *_searchBar;
    UITableView *_tableView;
    NSDictionary *_cities;
    NSMutableArray *_keys;  //分组索引
    NSMutableArray *_indexKeys; //侧边索引
    NSMutableArray *_cityNames;  //城市名
    NSArray *_filterData; //搜索结果
    UISearchDisplayController *_searchDisPlayController;
}
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation HCXSelectCityController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择城市";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configUI];
    [self loadData];
    [self setupContext];
    
    
}

-(void)setupContext{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]init];
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    
    NSError *error = nil;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *sqlitePath = [doc stringByAppendingPathComponent:@"visitedCities.sqlite"];
    
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:nil error:&error];
    
    context.persistentStoreCoordinator = store;
    
    self.context = context;
}


- (void)configUI {
    UITableView *contentTableView = [[UITableView alloc]init];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    [self.view addSubview:contentTableView];
    _tableView = contentTableView;
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"输入城市名或拼音查询";
    contentTableView.tableHeaderView = searchBar;
    contentTableView.sectionIndexColor = [UIColor lightGrayColor];
    _searchDisPlayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _searchDisPlayController.searchResultsDelegate = self;
    _searchDisPlayController.searchResultsDataSource = self;
}

- (void)loadData {
    NSURL *fileUrl = [[NSBundle mainBundle]URLForResource:@"citydict.plist" withExtension:nil];
    _cities = [[NSDictionary alloc] initWithContentsOfURL:fileUrl];
    _keys = [NSMutableArray arrayWithArray:[[_cities allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    _indexKeys = [NSMutableArray arrayWithArray:_keys];
    [_indexKeys insertObjects:@[@"#", @"$", @"*"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    [_keys insertObjects:@[@"定位城市", @"最近访问", @"热门城市"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    _cityNames = [NSMutableArray array];
    for (NSArray *cityNameArray in [_cities allValues]) {
        
        for (NSString *cityNameString in cityNameArray) {
            HCXCity *city = [[HCXCity alloc] init];
            city.cityName = cityNameString;
            // 转换为拼音
            NSMutableString *ms = [[NSMutableString alloc] initWithString:cityNameString];
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
            }
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                city.cityLetter = ms;
            }
            [_cityNames addObject:city];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return _keys[section];
    }
    else {
        return nil;
    }
    
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _tableView) {
        return _indexKeys;
    }
    else {
        return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == _tableView) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                   atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return index;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 2) {
        return 50.0f;
    }
    else if (indexPath.section == 2) {
        return 210.0f;
    }
    else {
        return 44.0f;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tableView) {
        return _keys.count;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _tableView) {
        if (section < 3) {
            return 1;
        }
        NSString *key = _keys[section];
        NSArray *cityNames = [_cities objectForKey:key];
        return cityNames.count;
    }
    else {
        // c忽略大小写，d忽略重音 根据中文和拼音筛选
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityName contains [cd] %@ OR cityLetter BEGINSWITH [cd] %@", _searchDisPlayController.searchBar.text,_searchDisPlayController.searchBar.text];
        _filterData = [[NSArray alloc] initWithArray:[_cityNames filteredArrayUsingPredicate:predicate]];
        return _filterData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"Cell";
   
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (tableView == _tableView) {
        [self configCell:cell IndexPath:indexPath];
    }
    else { //搜索结果
        cell.textLabel.text = [[_filterData objectAtIndex:indexPath.row] cityName];
    }
    
    return cell;
}

- (void)configCell:(UITableViewCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    CGFloat buttonWidth = ([UIScreen mainScreen].bounds.size.width - count * marginX) / 3 - 10;
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    cell.textLabel.text = nil;
    
    switch (indexPath.section) {
        case 0://定位城市
            {
                UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [cell.contentView addSubview:locationButton];
                [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(marginX);
                    make.centerY.equalTo(cell.contentView.mas_centerY);
                    make.width.mas_equalTo(buttonWidth);
                    make.height.mas_equalTo(buttonHeight);
                }];
                [locationButton setTitle:@"广州" forState:UIControlStateNormal];
                [locationButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                //TODO: 这里要设置normal和hight的背景图片
                locationButton.layer.borderWidth = 0.5;
                [locationButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
            break;
        case 1://最近访问
            {
                
//                NSMutableArray *visitedCitys = [[NSUserDefaults standardUserDefaults]objectForKey:@"visitedCitys"];
                NSMutableArray *visitedCities = [self queryVisitedCity];
                if (visitedCities.count == 0) {
                    return;
                }
                if (visitedCities.count > 3) {
//                    [visitedCitys removeLastObject];
                    NSArray *visitedArray = [visitedCities subarrayWithRange:NSMakeRange(0, 3)];
                    for (int i = 0; i < visitedArray.count; i++) {
                        UIButton *lastVisitButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [cell.contentView addSubview:lastVisitButton];
                        CGFloat lastVisitButtonX = marginX + (buttonWidth + marginX) * (i % 3);
                        [lastVisitButton mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_equalTo(buttonWidth);
                            make.height.mas_equalTo(buttonHeight);
                            make.centerY.equalTo(cell.contentView.mas_centerY);
                            make.left.mas_equalTo(lastVisitButtonX);
                        }];
                        HCXVisitedCity *visitedCity =  visitedArray[i];
                        [lastVisitButton setTitle:visitedCity.visitedCityName forState:UIControlStateNormal];
                        [lastVisitButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                        //TODO: 这里要设置normal和hight的背景图片
                        lastVisitButton.layer.borderWidth = 0.5;
                        [lastVisitButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
                }
                    
                }
                
            }
            break;
        case 2://热门城市
            {
                for (NSInteger i = 0; i < _hotCitys.count; i++) {
                    UIButton *hostCityButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [cell.contentView addSubview:hostCityButton];
                    [hostCityButton mas_makeConstraints:^(MASConstraintMaker *make) {
                        CGFloat hostCityButtonX = marginX + (buttonWidth + marginX) * (i % 3);
                        CGFloat hostCityButtonY = marginY + (buttonHeight + marginY) * (i / 3);
                        
                        make.left.mas_equalTo(hostCityButtonX);
                        make.top.mas_equalTo(hostCityButtonY);
                        make.width.mas_equalTo(buttonWidth);
                        make.height.mas_equalTo(buttonHeight);
                        
                    }];
                    [hostCityButton setTitle:_hotCitys[i] forState:UIControlStateNormal];
                    [hostCityButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    hostCityButton.layer.borderWidth = 0.5;
                    [hostCityButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
                
            }
            break;
        default:
            {
                NSString *key = [_keys objectAtIndex:indexPath.section];
                cell.textLabel.text = [[_cities objectForKey:key]objectAtIndex:indexPath.row];
            }
            
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _tableView) {
        NSString *key = [_keys objectAtIndex:indexPath.section];
        NSString *cityName = [[_cities objectForKey:key]objectAtIndex:indexPath.row];
        [self addCityName:cityName];

        if ([self.delegate respondsToSelector:@selector(didSelectedCity:selectedCityName:)]) {
            [self.delegate didSelectedCity:self selectedCityName:cityName];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    }
    else {
        
        NSString *cityName = [[_filterData objectAtIndex:indexPath.row]cityName];
        [self addCityName:cityName];
    
        if ([self.delegate respondsToSelector:@selector(didSelectedCity:selectedCityName:)]) {
            [self.delegate didSelectedCity:self selectedCityName:cityName];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)btnClicked:(UIButton *)btn {
    
    [self addCityName:btn.titleLabel.text];

    if ([self.delegate respondsToSelector:@selector(didSelectedCity:selectedCityName:)]) {
        [self.delegate didSelectedCity:self selectedCityName:btn.titleLabel.text];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 添加访问过的城市
- (void)addCityName:(NSString *)cityName {
    
    HCXVisitedCity *visitedCity = [NSEntityDescription insertNewObjectForEntityForName:@"HCXVisitedCity" inManagedObjectContext:self.context];
    
    visitedCity.visitedCityName = cityName;
    visitedCity.visitedTime = [NSDate date];
    
    NSError *error = nil;
    
    [self.context save:&error];
    
    if (!error) {
        NSLog(@"success");
    }else{
        NSLog(@"%@",error);
    }
    
}

#pragma mark - 查询访问过的城市
- (NSMutableArray *)queryVisitedCity {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"HCXVisitedCity"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"visitedTime" ascending:NO]];

    NSError *error = nil;
    
    NSArray *temp = [self.context executeFetchRequest:request error:&error];
    
    if (!error) {
        
//        for (HCXVisitedCity *visitedCity in temp) {
//            
//            NSLog(@"%@ %@",visitedCity.visitedCityName,visitedCity.visitedTime);
//        }
        
        NSMutableArray *temps = [NSMutableArray arrayWithArray:temp];
        return temps;
        
    }else{
        
        NSLog(@"%@",error);
        return 0;
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar endEditing:YES];
}

@end
