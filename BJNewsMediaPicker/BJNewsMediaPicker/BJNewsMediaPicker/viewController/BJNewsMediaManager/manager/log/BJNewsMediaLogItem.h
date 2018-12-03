//
//  BJNewsMediaLogItem.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJNewsMediaLogItem : NSObject

/**
 视频ID
 */
@property (nonatomic,copy) NSString * videoID;

/**
 视频大小
 */
@property (nonatomic,strong) NSNumber * size;

/**
 导出的视频的地址
 */
@property (nonatomic,copy) NSString * exportPath;

/**
 分段视频缓存地址
 */
@property (nonatomic,strong) NSString * subsectionPath;

/**
 分段数量
 */
@property (nonatomic,strong) NSNumber * subsectionCount;

/**
 当前上传的进度，默认为0
 */
@property (nonatomic,strong) NSNumber * progress;

- (void)updateSize:(NSInteger)size exportPath:(NSString *)exportPath subsectionPath:(NSString *)tempPath subsectionCount:(NSInteger)subsectionCount progress:(NSInteger)progress;

- (NSDictionary *)dictionary;

@end
