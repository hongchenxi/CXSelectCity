//
//  HCXCityCollectionViewCell.m
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/22.
//  Copyright © 2016年 洪晨希. All rights reserved.
//

#import "HCXCityCollectionViewCell.h"

@interface HCXCityCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIButton *cityName;

@end
@implementation HCXCityCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setCityString:(NSString *)cityString {
    _cityString = [cityString copy];
    [self.cityName setTitle:cityString forState:UIControlStateNormal];
}

@end
