//
//  BJNewsMediaCache.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+BJNewsMediaMD5.h"
#import "BJNewsMediaLogItem.h"
#import "BJNewsConfig.h"

@interface BJNewsMediaCache : NSObject

+ (BJNewsMediaCache *)defaultManager;

#pragma mark - 路径

/**
 拍摄视频缓存路径
 
 @return return value description
 */
- (NSString *)cameraPath;

/**
 导出视频路径
 
 @param fileName 视频名称
 @return return value description
 */
- (NSString *)exportPathWithFileName:(NSString *)fileName;

/**
 将MP4文件分段后缓存目录
 
 @return return value description
 */
- (NSString *)subsectionVideoPathWithVideoID:(NSString *)videoID;

#pragma mark - 日志处理

/**
 获取所有日志
 
 @return return value description
 */
- (NSArray <BJNewsMediaLogItem *> *)logs;

/**
 获取指定videoID的日志
 
 @param videoID videoID description
 @return return value description
 */
+ (BJNewsMediaLogItem *)itemWithVideoID:(NSString *)videoID;

/**
 更新日志
 
 @param item 日志
 */
+ (void)updateItem:(BJNewsMediaLogItem *)item;

/**
 移除日志
 
 @param videoID videoID description
 */
+ (void)removeItemWithVideoID:(NSString *)videoID;

@end
