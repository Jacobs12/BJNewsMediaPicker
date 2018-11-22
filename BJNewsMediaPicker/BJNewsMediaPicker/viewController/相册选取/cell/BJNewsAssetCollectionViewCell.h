//
//  BJNewsAssetCollectionViewCell.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BJNewsAssetCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) IBOutlet UIImageView * imageView1;
@property (nonatomic,strong) IBOutlet UIImageView * selectedImageView;
@property (nonatomic,assign) BOOL isSelected;

+ (CGSize)itemSize;

- (void)selectedItem:(BOOL)isSelected;

- (void)setSelectedEnabled:(BOOL)isEnable;

@end
