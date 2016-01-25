//
//  HCXSelectCityController.h
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/22.
//  Copyright © 2016年 洪晨希. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HCXSelectCityController;

@protocol HCXSelectCityControllerDelegate <NSObject>

@optional
- (void)didSelectedCity:(HCXSelectCityController *)seleccityVC selectedCityName:(NSString *)cityName;

@end

@interface HCXSelectCityController : UIViewController

@property (nonatomic, copy) NSArray *hotCitys;

@property (nonatomic, weak) id<HCXSelectCityControllerDelegate> delegate;

@end
