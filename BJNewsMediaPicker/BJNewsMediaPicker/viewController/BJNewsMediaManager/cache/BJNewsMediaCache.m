//
//  BJNewsMediaCache.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "BJNewsMediaCache.h"

@implementation BJNewsMediaCache

+ (BJNewsMediaCache *)defaultManager{
    BJNewsMediaCache * manager = [[BJNewsMediaCache alloc] init];
    return manager;
}

#pragma mark -
#pragma mark - 根目录

/**
 根目录

 @return return value description
 */
- (NSString *)basePath{
#warning username
    NSString * path = [NSString stringWithFormat:@"%@/username",BJNEWS_MEDIA_PATH];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    return path;
}

#pragma mark - 日志路径

/**
 日志路径

 @return return value description
 */
- (NSString *)logPath{
    NSString * path = [NSString stringWithFormat:@"%@/log.plist",[self basePath]];
    return path;
}

#pragma mark - 视频缓存路径

/**
 拍摄视频缓存目录

 @return return value description
 */
- (NSString *)cameraBasePath{
    NSString * path = [NSString stringWithFormat:@"%@/temp",[self basePath]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    return path;
}

/**
 拍摄视频缓存路径

 @return return value description
 */
- (NSString *)cameraPath{
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyyMMddhhmmss";
    NSString * fileName = [df stringFromDate:[NSDate date]];
    NSString * path = [NSString stringWithFormat:@"%@/%@.mov",[self cameraBasePath],fileName];
    return path;
}

/**
 导出视频目录

 @return return value description
 */
- (NSString *)exportBasePath{
    NSString * path = [NSString stringWithFormat:@"%@/export",[self basePath]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    return path;
}

/**
 导出视频路径

 @param fileName 视频名称
 @return return value description
 */
- (NSString *)exportPathWithFileName:(NSString *)fileName{
    NSString * path = [NSString stringWithFormat:@"%@/%@.mp4",[self exportBasePath],fileName];
    return path;
}

#pragma mark - 将MP4文件分段后缓存位置

/**
 将MP4文件分段后缓存根目录

 @return return value description
 */
- (NSString *)subsectionVideoBasePath{
    NSString * path = [NSString stringWithFormat:@"%@/subsection",[self basePath]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    return path;
}

/**
 将MP4文件分段后缓存目录
 
 @return return value description
 */
- (NSString *)subsectionVideoPathWithVideoID:(NSString *)videoID{
    NSString * temp = [NSString stringWithFormat:@"%@/%@",[self subsectionVideoBasePath],[videoID md5]];
    if([[NSFileManager defaultManager] fileExistsAtPath:temp] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:temp withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return temp;
}

#pragma mark - 创建日志

/**
 创建日志

 @param items 日志
 */
- (void)createConfigWithArray:(NSArray <BJNewsMediaLogItem *>*)items{
    if(items == nil){
        items = @[];
    }
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    for (BJNewsMediaLogItem * item in items) {
        NSDictionary * dict = item.dictionary;
        if(dict == nil){
            continue;
        }
        [tempArray addObject:dict];
    }
    NSDictionary * dict = @{@"items":tempArray};
    NSString  * path = [self logPath];
    [dict writeToFile:path atomically:NO];
}


#pragma mark - 取出日志

/**
 获取所有日志

 @return return value description
 */
- (NSArray <BJNewsMediaLogItem *> *)logs{
    NSString * path = [self logPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
        [self createConfigWithArray:@[]];
    }
    NSDictionary * dict = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSArray * items = dict[@"items"];
    NSMutableArray * config = [[NSMutableArray alloc]init];
    for (NSDictionary * item in items) {
        BJNewsMediaLogItem * model = [[BJNewsMediaLogItem alloc]init];
        [model setValuesForKeysWithDictionary:item];
        [config addObject:model];
    }
    return config;
}

/**
 获取指定videoID的日志
 
 @param videoID videoID description
 @return return value description
 */
+ (BJNewsMediaLogItem *)itemWithVideoID:(NSString *)videoID{
    BJNewsMediaCache * cacheManager = [BJNewsMediaCache defaultManager];
    BJNewsMediaLogItem * item = nil;
    NSArray * array = [cacheManager logs];
    NSMutableArray * tempArray = nil;
    if(array && array.count > 0){
        tempArray = [[NSMutableArray alloc]initWithArray:array];
    }else{
        tempArray = [[NSMutableArray alloc]init];
    }
    for (BJNewsMediaLogItem * obj in tempArray) {
        if([obj.videoID isEqualToString:videoID]){
            item = obj;
        }
    }
    if(item == nil){
        item = [[BJNewsMediaLogItem alloc]init];
        item.videoID = videoID;
    }
    return item;
}

/**
 更新日志

 @param item 日志
 */
+ (void)updateItem:(BJNewsMediaLogItem *)item{
    BJNewsMediaCache * cacheManager = [BJNewsMediaCache defaultManager];
    BJNewsMediaLogItem * tempItem = nil;
    NSArray * array = [cacheManager logs];
    NSMutableArray * tempArray = [[NSMutableArray alloc]initWithArray:array];
    for (BJNewsMediaLogItem * obj in tempArray) {
        if([obj.videoID isEqualToString:item.videoID]){
            tempItem = obj;
        }
    }
    [tempArray removeObject:tempItem];
    [tempArray addObject:item];
    [cacheManager createConfigWithArray:tempArray];
}

/**
 移除日志

 @param videoID videoID description
 */
+ (void)removeItemWithVideoID:(NSString *)videoID{
    BJNewsMediaCache * cacheManager = [BJNewsMediaCache defaultManager];
    BJNewsMediaLogItem * tempItem = nil;
    NSArray * array = [cacheManager logs];
    NSMutableArray * tempArray = [[NSMutableArray alloc]initWithArray:array];
    NSMutableArray * deleteArray = [[NSMutableArray alloc]init];
    for (BJNewsMediaLogItem * obj in tempArray) {
        if([obj.videoID isEqualToString:videoID]){
            tempItem = obj;
        }
    }
    for (BJNewsMediaLogItem * obj in deleteArray) {
        [tempArray removeObject:obj];
    }
    [cacheManager createConfigWithArray:tempArray];
}

@end
