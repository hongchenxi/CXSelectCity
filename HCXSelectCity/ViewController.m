//
//  ViewController.m
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/22.
//  Copyright © 2016年 洪晨希. All rights reserved.
//

#import "ViewController.h"
#import "HCXSelectCityController.h"
@interface ViewController ()<HCXSelectCityControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.cityNameLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)presentSelectCityVC:(id)sender {
    
    HCXSelectCityController *selectVC = [[HCXSelectCityController alloc]init];
    selectVC.hotCitys = @[@"上海",@"北京",@"广州",@"深圳",@"武汉",@"天津",@"西安",@"南京",@"杭州",@"成都",@"重庆"];
    selectVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:selectVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)didSelectedCity:(HCXSelectCityController *)seleccityVC selectedCityName:(NSString *)cityName {
    if (cityName) {
        self.cityNameLabel.hidden = NO;
        self.cityNameLabel.text = cityName;
    }
    
}

@end
