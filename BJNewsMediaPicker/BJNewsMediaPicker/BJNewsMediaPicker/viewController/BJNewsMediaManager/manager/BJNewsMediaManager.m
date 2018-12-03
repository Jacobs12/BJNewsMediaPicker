//
//  BJNewsMediaManager.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "BJNewsMediaManager.h"

static BJNewsMediaManager * bjnews_media_manager = nil;

@interface BJNewsMediaManager (){
    BOOL _timerEnable;
}

@property (nonatomic,strong) BJNewsMediaCache * cacheManager;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) NSMutableArray <BJNewsExportSession *> * exportArray;

@end

@implementation BJNewsMediaManager

+ (BJNewsMediaManager *)defaultManager{
    if(bjnews_media_manager == nil){
        bjnews_media_manager = [[BJNewsMediaManager alloc]init];
    }
    return bjnews_media_manager;
}

- (BJNewsMediaCache *)cacheManager{
    if(_cacheManager == nil){
        _cacheManager = [BJNewsMediaCache defaultManager];
    }
    return _cacheManager;
}

#pragma mark - 计时器
- (NSMutableArray <BJNewsExportSession *> *)exportArray{
    if(_exportArray == nil){
        _exportArray = [[NSMutableArray alloc]init];
    }
    return _exportArray;
}

- (void)addExportSession:(BJNewsExportSession *)export{
    NSLog(@"加入");
    [self.exportArray addObject:export];
    _timerEnable = YES;
    [self startTimer];
}

- (void)startTimer{
    if(_timerEnable == NO){
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startTimer];
        [self refresh:nil];
    });
}

- (void)endTimer{
    _timerEnable = NO;
}

- (void)refresh:(id)sender{
    NSMutableArray * deleteArray = [[NSMutableArray alloc]init];
    for (BJNewsExportSession * model in self.exportArray) {
        if(model.exportProgress){
            float progress = model.exportSession.progress;
            model.exportProgress(progress);
        }
        if(model.exportSession.progress >= 1.0){
            [deleteArray addObject:model];
        }
    }
    for (BJNewsExportSession * session in deleteArray) {
        session.exportProgress = nil;
        [self.exportArray removeObject:session];
    }
    if(self.exportArray.count == 0){
        [self endTimer];
    }
}

#pragma mark - 获取图片

/**
 获取图片
 
 @param asset 图片资源asset
 @param handler 完成回调
 */
- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset resultHandler:(void (^) (UIImage * _Nullable result,NSDictionary * _Nullable info))handler{
    PHImageRequestOptions * assetOptions = [[PHImageRequestOptions alloc]init];
    assetOptions.synchronous = YES;
    assetOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    assetOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(500, 500) contentMode:PHImageContentModeAspectFit options:assetOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if(handler){
            handler(result,info);
        }
    }];
    return requestID;
}

/**
 取消读取图片
 
 @param requestID requestID description
 */
- (void)cancelImageRequestWithID:(PHImageRequestID)requestID{
    [[PHImageManager defaultManager] cancelImageRequest:requestID];
}

#pragma mark - 视频转码

/**
 视频转码导出mp4文件，并返回path及文件大小（相册中获取的视频）
 
 @param aAsset video资源
 @param aProgress 转码进度
 @param handler 完成回调
 */
- (void)exportVideoWithAsset:(PHAsset * _Nonnull)aAsset progress:(void (^) (float progress))aProgress completionHandler:( void (^) (BOOL isSuc,NSString * filePath,NSInteger fileSize))handler{
    PHVideoRequestOptions * videoOptions = [[PHVideoRequestOptions alloc]init];
    videoOptions.version = PHImageRequestOptionsVersionCurrent;
    videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestAVAssetForVideo:aAsset options:videoOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        if(asset == nil){
            if(handler){
                handler(NO,@"",0);
            }
            return;
        }
        AVURLAsset * tempAsset = (AVURLAsset *)asset;
        NSArray * tempArray = [tempAsset.URL.description componentsSeparatedByString:@"/"];
        if(tempArray== nil || tempArray.count == 0){
            if(handler){
                handler(NO,@"",0);
            }
            return;
        }
        NSArray * tempArray2 = [[NSString stringWithFormat:@"%@",[tempArray lastObject]] componentsSeparatedByString:@"."];
        if(tempArray2== nil || tempArray2.count == 0){
            if(handler){
                handler(NO,@"",0);
            }
            return;
        }
        NSString * fileName = [NSString stringWithFormat:@"%@",[tempArray2 firstObject]];
        NSString * filePath = [self.cacheManager exportPathWithFileName:fileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:filePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            NSInteger fileSize = 0;
            NSDictionary * itemAtt = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            if(itemAtt && itemAtt[@"NSFileSize"]){
                fileSize = [[NSString stringWithFormat:@"%@",itemAtt[@"NSFileSize"]] integerValue];
            }
            NSLog(@"%@",itemAtt);
            if(handler){
                handler(YES,filePath,fileSize);
            }
        }];
//        监听转码进度
        BJNewsExportSession * modelSession = [[BJNewsExportSession alloc]init];
        modelSession.exportSession = exportSession;
        modelSession.exportProgress = aProgress;
        [self addExportSession:modelSession];
    }];
}

/**
 视频转码导出mp4文件，并返回path及文件大小（沙河路径中的文件）
 
 @param path 沙河路径
 @param aProgress 进度
 @param handler 完成回调
 */
- (void)exportVideoWithPath:(NSString *)path progress:(void (^) (float progress))aProgress completionHandler:( void (^) (BOOL isSuc,NSString * filePath,NSInteger fileSize))handler{
    AVAsset * asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
    if(asset == nil){
        if(handler){
            handler(NO,@"",0);
        }
        return;
    }
    AVURLAsset * tempAsset = (AVURLAsset *)asset;
    NSArray * tempArray = [tempAsset.URL.description componentsSeparatedByString:@"/"];
    if(tempArray== nil || tempArray.count == 0){
        if(handler){
            handler(NO,@"",0);
        }
        return;
    }
    NSArray * tempArray2 = [[NSString stringWithFormat:@"%@",[tempArray lastObject]] componentsSeparatedByString:@"."];
    if(tempArray2== nil || tempArray2.count == 0){
        if(handler){
            handler(NO,@"",0);
        }
        return;
    }
    NSString * fileName = [NSString stringWithFormat:@"%@",[tempArray2 firstObject]];
    NSString * filePath = [self.cacheManager exportPathWithFileName:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = [NSURL fileURLWithPath:filePath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"视频导出完成");
        NSInteger fileSize = 0;
        NSDictionary * itemAtt = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if(itemAtt && itemAtt[@"NSFileSize"]){
            fileSize = [[NSString stringWithFormat:@"%@",itemAtt[@"NSFileSize"]] integerValue];
        }
        NSLog(@"%@",itemAtt);
        if(handler){
            handler(YES,filePath,fileSize);
        }
    }];
    //        监听转码进度
    BJNewsExportSession * modelSession = [[BJNewsExportSession alloc]init];
    modelSession.exportSession = exportSession;
    modelSession.exportProgress = aProgress;
    [self addExportSession:modelSession];
}

#pragma mark - 视频分段

/**
 将视频数据分段
 
 @param path 需要分段切片的视频地址
 @param handler 完成回调
 */
- (void)subsectionVideoWithID:(NSString *)videoID path:(NSString * _Nullable)path completionHandler:(void (^) (NSDictionary * result,NSString * resultPath,NSArray<NSString *> * paths))handler{
    if(path == nil || path.length == 0){
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * data = [[NSData alloc]initWithContentsOfFile:path];
        NSInteger count = 0;
        NSInteger length = 1024*200; // 每200K分一段
        NSInteger loc = 0;
        NSString * tempPath = [[BJNewsMediaCache defaultManager] subsectionVideoPathWithVideoID:videoID];
        NSArray * arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
        for (NSString * file in arr) {
            NSString * tPath = [NSString stringWithFormat:@"%@/%@",tempPath,file];
            [[NSFileManager defaultManager] removeItemAtPath:tPath error:nil];
        }
        while (1) {
            count ++;
            NSData * tempData = nil;
            if(loc + length >= data.length){
                tempData = [data subdataWithRange:NSMakeRange(loc, data.length - loc)];
                loc += length;
                [tempData writeToFile:[NSString stringWithFormat:@"%@/%ld",tempPath,(long)count] atomically:NO];
                break;
            }
            tempData = [data subdataWithRange:NSMakeRange(loc, length)];
            loc += length;
            [tempData writeToFile:[NSString stringWithFormat:@"%@/%ld",tempPath,(long)count] atomically:NO];
        }
        BJNewsMediaLogItem * logItem = [BJNewsMediaCache itemWithVideoID:videoID];
        [logItem updateSize:data.length exportPath:path subsectionPath:tempPath subsectionCount:count progress:0];
        [BJNewsMediaCache updateItem:logItem];
        if(handler){
            handler(@{},@"",@[]);
        }
    });
}

/**
 更新上传进度
 
 @param progress 上传进度
 @param videoID videoID
 */
- (void)updateMediaProgress:(float)progress videoID:(NSString *)videoID{
    
}

@end
