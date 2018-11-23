//
//  BJNewsCameraViewController.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "ViewController.h"
#import "BJNewsMediaItem.h"

@interface BJNewsCameraViewController : ViewController

/**
 回调
 */
@property (nonatomic,copy) void (^callBack) (BJNewsMediaItem * model);

@end
