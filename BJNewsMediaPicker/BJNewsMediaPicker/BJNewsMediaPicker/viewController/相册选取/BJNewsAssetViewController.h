//
//  BJNewsAssetViewController.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "ViewController.h"
#import "BJNewsMediaItem.h"

@interface BJNewsAssetViewController : ViewController

/**
 图片，视频，图片和视频混合
 */
@property (nonatomic,assign) BJNewsAssetMediaType mediaType;

/**
 读取的最大数量
 */
@property (nonatomic,assign) NSInteger maxCount;

/**
 回调
 */
@property (nonatomic,copy) void (^callBack) (NSArray <BJNewsMediaItem *> * results);

@end
