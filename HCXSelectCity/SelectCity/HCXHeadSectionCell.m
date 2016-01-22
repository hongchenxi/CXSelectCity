//
//  HCXHeadSectionCell.m
//  HCXSelectCity
//
//  Created by 洪晨希 on 16/1/22.
//  Copyright © 2016年 洪晨希. All rights reserved.
//

#import "HCXHeadSectionCell.h"
#import "HCXCityCollectionViewCell.h"
@interface HCXHeadSectionCell()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HCXHeadSectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"self.citys.count:%ld",self.citys.count);
    return self.citys.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cityCollectionViewCell";
    [collectionView registerClass:[HCXCityCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    HCXCityCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    collectionViewCell.cityString = self.citys[indexPath.row];
    
    return collectionViewCell;
}

/**
 *  每个cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(width / 3 - 20, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cityName = self.citys[indexPath.row];
    if ([self respondsToSelector:@selector(didClickCityName:cityName:)]) {
        [self.delegate didClickCityName:self cityName:cityName];
    }
}
@end
