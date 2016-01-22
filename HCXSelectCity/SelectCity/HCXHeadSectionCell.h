//
//  HCXHeadSectionCell.h
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/22.
//  Copyright © 2016年 洪晨希. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HCXHeadSectionCell;

@protocol HCXHeadSectionCellDelegate <NSObject>

@required
- (void)didClickCityName:(HCXHeadSectionCell *)cell cityName:(NSString *)cityName;

@end

@interface HCXHeadSectionCell : UITableViewCell

@property (nonatomic, strong) NSArray *citys;
@property (nonatomic, weak)id<HCXHeadSectionCellDelegate>delegate;

@end
