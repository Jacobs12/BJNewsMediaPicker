//
//  BJNewsAssetCollectionViewCell.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "BJNewsAssetCollectionViewCell.h"

@interface BJNewsAssetCollectionViewCell ()

@property (nonatomic,strong) UIView * coverView;

@end

@implementation BJNewsAssetCollectionViewCell

+ (CGSize)itemSize{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 5 * 5) / 4.0;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectedImageView.layer.cornerRadius = self.selectedImageView.bounds.size.height / 2.0;
    self.selectedImageView.layer.masksToBounds = YES;
    self.selectedImageView.hidden = YES;
    //    self.selectedImageView.
}

- (UIView *)coverView{
    if(_coverView == nil){
        _coverView = [[UIView alloc]initWithFrame:self.imageView1.bounds];
        _coverView.backgroundColor = [UIColor whiteColor];
        _coverView.alpha = 0.8;
    }
    return _coverView;
}

- (void)selectedItem:(BOOL)isSelected{
    if(isSelected){
        self.selectedImageView.hidden = NO;
    }else{
        self.selectedImageView.hidden = YES;
    }
    self.isSelected = isSelected;
}

- (void)setSelectedEnabled:(BOOL)isEnable{
    if(isEnable){
        [self.coverView removeFromSuperview];
    }else{
        [self.imageView1 addSubview:self.coverView];
    }
}

@end
