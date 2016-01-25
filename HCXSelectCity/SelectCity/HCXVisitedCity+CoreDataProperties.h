//
//  HCXVisitedCity+CoreDataProperties.h
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/25.
//  Copyright © 2016年 洪晨希. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HCXVisitedCity.h"

NS_ASSUME_NONNULL_BEGIN

@interface HCXVisitedCity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *visitedCityName;
@property (nullable, nonatomic, retain) NSDate *visitedTime;

@end

NS_ASSUME_NONNULL_END
