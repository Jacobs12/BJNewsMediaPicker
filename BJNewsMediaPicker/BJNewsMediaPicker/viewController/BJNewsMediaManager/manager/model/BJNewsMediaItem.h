//
//  BJNewsMediaItem.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJNewsMediaManager.h"

typedef NS_ENUM(NSInteger,BJNewsAssetMediaType){
    BJNewsAssetMediaTypeImage,        // 图片
    BJNewsAssetMediaTypeVideo,        // 视频
};

/**
 图片属性
 */
@interface BJNewsMediaImageItem : NSObject

@property (nonatomic,strong) UIImage * image;

@property (nonatomic,strong) NSDictionary * info;

@end

/**
 视频属性
 */
@interface BJNewsMediaVideoItem : NSObject

@property (nonatomic,strong) UIImage * image;

@property (nonatomic,strong) NSString * exportPath;

@property (nonatomic,strong) NSString * subsectionPath;

@end

@interface BJNewsMediaItem : NSObject

@property (nonatomic,assign) PHImageRequestID requestID;

/**
 图片
 */
@property (nonatomic,strong) BJNewsMediaImageItem * imageItem;

/**
 视频
 */
@property (nonatomic,strong) BJNewsMediaVideoItem * videoItem;

/**
 数据源
 */
@property (nonatomic,strong) PHAsset * phAsset;

/**
 是否被选中
 */
@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,assign) BJNewsAssetMediaType type;

#pragma mark - 图片
/**
 获取图片
 
 @param handler 完成回调
 */
- (void)requestImageResultHandler:(void (^) (UIImage * _Nullable result,NSDictionary * _Nullable info))handler;

#pragma mark - 相册视频

/**
 共三步：1.导出视频exportVideoProgress：
 2.连接服务器，确认videoID
 3.视频分段
 此为第一步，导出视频
 
 @param progress 上传进度回调
 @param handler 完成回调
 */
- (void)exportVideoProgress:(void (^) (float progress))progress completionHandler:(void (^) (NSString * filePath,UIImage * previewImage,NSInteger fileSize))handler;

/**
 共三步：1.导出视频exportVideoProgress：
 2.连接服务器，确认videoID
 3.视频分段
 此为第三步，将视频数据分段
 
 @param videoID 与服务器约定的VideoID
 @param handler 完成回调
 */
- (void)subsectionVideoWithID:(NSString *)videoID completionHandler:(void (^) (NSDictionary * result,NSString * resultPath,NSArray<NSString *> * paths))handler;

@end
