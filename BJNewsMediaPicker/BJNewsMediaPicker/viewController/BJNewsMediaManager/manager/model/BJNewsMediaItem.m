//
//  BJNewsMediaItem.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "BJNewsMediaItem.h"

/**
 图片属性
 */
@implementation BJNewsMediaImageItem

@end

/**
 视频属性
 */
@implementation BJNewsMediaVideoItem

@end

@implementation BJNewsMediaItem

- (BJNewsMediaImageItem *)imageItem{
    if(_imageItem == nil){
        _imageItem = [[BJNewsMediaImageItem alloc]init];
    }
    return _imageItem;
}

- (BJNewsMediaVideoItem *)videoItem{
    if(_videoItem == nil){
        _videoItem = [[BJNewsMediaVideoItem alloc]init];
    }
    return _videoItem;
}

#pragma mark - 图片

/**
 获取图片
 
 @param handler 完成回调
 */
- (void)requestImageResultHandler:(void (^) (UIImage * _Nullable result,NSDictionary * _Nullable info))handler{
    [[BJNewsMediaManager defaultManager] requestImageForAsset:self.phAsset resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if(handler){
            self.imageItem.image = result;
            self.videoItem.image = result;
            handler(result,info);
        }
    }];
}

#pragma mark - 相册视频

/**
 共三步：1.导出视频exportVideoProgress：
 2.连接服务器，确认videoID
 3.视频分段
 此为第一步，导出视频
 
 @param progress 上传进度回调
 @param handler 完成回调
 */
- (void)exportVideoProgress:(void (^) (float progress))progress completionHandler:(void (^) (NSString * filePath,UIImage * previewImage,NSInteger fileSize))handler{
    [[BJNewsMediaManager defaultManager] exportVideoWithAsset:self.phAsset progress:^(float progress) {
        
    } completionHandler:^(BOOL isSuc, NSString *filePath, NSInteger fileSize) {
        @try {
            if(handler == nil){
                return ;
            }
            self.videoItem.exportPath = filePath;
            if(self.videoItem.image != nil){
                if(handler){
                    handler(filePath,self.videoItem.image,fileSize);
                }
            }else{
                [self requestImageResultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if(handler){
                        handler(filePath,self.videoItem.image,fileSize);
                    }
                }];
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }];
}

/**
 共三步：1.导出视频exportVideoProgress：
 2.连接服务器，确认videoID
 3.视频分段
 此为第三步，将视频数据分段
 
 @param videoID 与服务器约定的VideoID
 @param handler 完成回调
 */
- (void)subsectionVideoWithID:(NSString *)videoID completionHandler:(void (^) (NSDictionary * result,NSString * resultPath,NSArray<NSString *> * paths))handler{
    [[BJNewsMediaManager defaultManager] subsectionVideoWithID:videoID path:self.videoItem.exportPath completionHandler:^(NSDictionary *result, NSString *resultPath, NSArray<NSString *> *paths) {
        if(handler){
            handler(result,resultPath,paths);
        }
    }];
}

#pragma mark - 拍摄视频

@end
