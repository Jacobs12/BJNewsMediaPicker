//
//  BJNewsMediaManager.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJNewsMediaCache.h"
#import <Photos/Photos.h>

@interface BJNewsMediaManager : NSObject

+ (BJNewsMediaManager *)defaultManager;

#pragma mark - 获取图片

/**
 获取图片
 
 @param asset 图片资源asset
 @param handler 完成回调
 */
- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset resultHandler:(void (^) (UIImage * _Nullable result,NSDictionary * _Nullable info))handler;

/**
 取消读取图片

 @param requestID requestID description
 */
- (void)cancelImageRequestWithID:(PHImageRequestID)requestID;

#pragma makr - 视频转码

/**
 视频转码导出mp4文件，并返回path及文件大小（相册中获取的视频）

 @param aAsset video资源
 @param aProgress 转码进度
 @param handler 完成回调
 */
- (void)exportVideoWithAsset:(PHAsset * _Nonnull)aAsset progress:(void (^) (float progress))aProgress completionHandler:( void (^) (BOOL isSuc,NSString * filePath,NSInteger fileSize))handler;

/**
 视频转码导出mp4文件，并返回path及文件大小（沙河路径中的文件）
 
 @param path 沙河路径
 @param aProgress 进度
 @param handler 完成回调
 */
- (void)exportVideoWithPath:(NSString *)path progress:(void (^) (float progress))aProgress completionHandler:( void (^) (BOOL isSuc,NSString * filePath,NSInteger fileSize))handler;

#pragma mark - 视频分段

/**
 将视频数据分段
 
 @param path 需要分段切片的视频地址
 @param handler 完成回调
 */
- (void)subsectionVideoWithID:(NSString *)videoID path:(NSString * _Nullable)path completionHandler:(void (^) (NSDictionary * result,NSString * resultPath,NSArray<NSString *> * paths))handler;

/**
 更新上传进度
 
 @param progress 上传进度
 @param videoID videoID
 */
- (void)updateMediaProgress:(float)progress videoID:(NSString *)videoID;

@end
