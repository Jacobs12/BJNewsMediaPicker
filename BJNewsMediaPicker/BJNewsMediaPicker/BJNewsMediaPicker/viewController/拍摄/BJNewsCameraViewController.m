//
//  BJNewsCameraViewController.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "BJNewsCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BJNewsAssetViewController.h"

@interface BJNewsCameraViewController ()<AVCaptureFileOutputRecordingDelegate,AVCapturePhotoCaptureDelegate>{
    BJNewsAssetMediaType _mediaType;
    NSString * _folderName;
}

/*
 *  AVCaptureSession:它从物理设备得到数据流（比如摄像头和麦克风），输出到一个或
 *  多个目的地，它可以通过
 *  会话预设值(session preset)，来控制捕捉数据的格式和质量
 */
@property (nonatomic, strong) AVCaptureSession *iSession;

/**
 设备，用于切换前后摄像头
 */
@property (nonatomic, strong) AVCaptureDevice *iDevice;

/**
 音频输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput *iInput;

/**
 输出照片的配置
 */
@property (nonatomic,strong) AVCapturePhotoSettings * photoSettings;

/**
 输出照片
 */
//@property (nonatomic, strong) AVCaptureStillImageOutput *iOutput;
@property (nonatomic, strong) AVCapturePhotoOutput *iOutput;

/**
 视频输出
 */
@property (nonatomic, strong) AVCaptureMovieFileOutput *iMovieOutput;

/**
 预览层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *iPreviewLayer;

@property (nonatomic,strong) UIButton * videoButton;

@property (nonatomic,strong) UIButton * photoButton;

@property (nonatomic,strong) UIButton * cameraButton;

@property (nonatomic,strong) UIButton * flashButton;

/**
 本地视频按钮
 */
@property (nonatomic,strong) UIButton * assetButton;

@end

@implementation BJNewsCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _folderName = @"新京报";
    [self initCamera];
    [self createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.iSession && self.iSession.isRunning == NO){
        [self.iSession startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(self.iSession && self.iSession.isRunning == YES){
        [self.iSession stopRunning];
    }
}

#pragma mark - 配置硬件设备信息

/**
 创建设备会话

 @return return value description
 */
- (AVCaptureSession *)iSession{
    if(_iSession == nil){
        _iSession = [[AVCaptureSession alloc]init];
    }
    return _iSession;
}

/**
 配置输入以及输出
 */
- (void)initCamera{
//    设置高清晰度
    self.iSession.sessionPreset = AVCaptureSessionPresetHigh;
//    获取后置摄像头
    self.iDevice = [self cameraWithPostion:AVCaptureDevicePositionBack];
    //添加摄像头设备
    //对设备进行设置时需上锁，设置完再打开锁
    NSDictionary * setDict = @{AVVideoCodecKey:AVVideoCodecJPEG};
    self.photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDict];
    self.iOutput = [[AVCapturePhotoOutput alloc]init];
    
    [self.iDevice lockForConfiguration:nil];
    //    if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
    //        [self.iDevice setFlashMode:AVCaptureFlashModeAuto];
    //    }
    if([self.iOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeAuto)]){
        self.photoSettings.flashMode = AVCaptureFlashModeAuto;
    }
//    设置设备持续自动对焦
    if ([self.iDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self.iDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    if ([self.iDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        [self.iDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    [self.iDevice unlockForConfiguration];
    //添加音频设备
    //    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDevice * audioDevice = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInMicrophone] mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified].devices.firstObject;
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    
    self.iInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.iDevice error:nil];
    //    < iOS10
    //    self.iOutput = [[AVCaptureStillImageOutput alloc]init];
    //    NSDictionary *setDic = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //    self.iOutput.outputSettings = setDic;
    //    NSDictionary * setDict = @{AVVideoCodecKey:AVVideoCodecJPEG};
    //    [self.iOutput setPhotoSettingsForSceneMonitoring:[AVCapturePhotoSettings photoSettingsWithFormat:setDict]];
    
    self.iMovieOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    if ([self.iSession canAddInput:self.iInput]) {
        [self.iSession addInput:self.iInput];
    }
    if ([self.iSession canAddOutput:self.iOutput]) {
        [self.iSession addOutput:self.iOutput];
    }
    if ([self.iSession canAddInput:audioInput]) {
        [self.iSession addInput:audioInput];
    }
//    预览层
    self.iPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.iSession];
    [self.iPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.iPreviewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.iPreviewLayer atIndex:0];
    
    [self.iSession startRunning];
}

/**
 获取前后摄像头
 
 @param position position description
 @return return value description
 */
- (AVCaptureDevice *)cameraWithPostion:(AVCaptureDevicePosition)position{
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *devicesIOS10 = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        NSArray *devicesIOS  = devicesIOS10.devices;
        for (AVCaptureDevice *device in devicesIOS) {
            if ([device position] == position) {
                return device;
            }
        }
        return nil;
    } else {
        // Fallback on earlier versions
        //    前后摄像头
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray * deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice * device in deviceArray) {
            if(device.position == AVCaptureDevicePositionBack){
                return device;
            }
        }
#pragma clang diagnostic pop
        
        return nil;
    }
}

/**
 设置拍摄模式：照片、视频
 
 @param mediaType 拍摄模式
 */
- (IBAction)setMediaType:(BJNewsAssetMediaType)mediaType {
    _mediaType = mediaType;
    if (mediaType == BJNewsAssetMediaTypeVideo) {
        [self.iSession beginConfiguration];
        [self.iSession removeOutput:self.iOutput];
        if ([self.iSession canAddOutput:self.iMovieOutput]) {
            [self.iSession addOutput:self.iMovieOutput];
            //设置视频防抖
            AVCaptureConnection *connection = [self.iMovieOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
            }
        } else{
            [self.iSession addOutput:self.iOutput];
        }
        
        [self.iSession commitConfiguration];
        
    } else{
        [self.iSession beginConfiguration];
        [self.iSession removeOutput:self.iMovieOutput];
        if ([self.iSession canAddOutput:self.iOutput]) {
            [self.iSession addOutput:self.iOutput];
        } else{
            [self.iSession addOutput:self.iMovieOutput];
        }
        [self.iSession commitConfiguration];
    }
}

#pragma mark - create view

- (void)createView{
    [self.view addSubview:self.photoButton];
    [self.view addSubview:self.videoButton];
    [self.view addSubview:self.cameraButton];
    [self.view addSubview:self.flashButton];
    [self.view addSubview:self.assetButton];
}

- (UIButton *)photoButton{
    if(_photoButton == nil){
        _photoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _photoButton.frame = CGRectMake(100, 200, 100, 60);
        [_photoButton setTitle:@"拍照" forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton *)videoButton{
    if(_videoButton == nil){
        _videoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _videoButton.frame = CGRectMake(100, 200, 60, 60);
        _videoButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height - _videoButton.bounds.size.width / 2.0 - 80);
        _videoButton.layer.cornerRadius = _videoButton.bounds.size.height / 2.0;
        _videoButton.layer.masksToBounds = YES;
        _videoButton.backgroundColor = [UIColor whiteColor];
        [_videoButton setTitle:@"开始" forState:UIControlStateNormal];
        [_videoButton addTarget:self action:@selector(takeVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoButton;
}

- (UIButton *)cameraButton{
    if(_cameraButton == nil){
        _cameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cameraButton.frame = CGRectMake(100, 300, 100, 60);
        [_cameraButton setTitle:@"切换" forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(changePositionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)flashButton{
    if(_flashButton == nil){
        _flashButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _flashButton.frame = CGRectMake(100, 400, 100, 60);
        [_flashButton setTitle:@"闪光灯" forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}

- (UIButton *)assetButton{
    if(_assetButton == nil){
        _assetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _assetButton.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 100, 100, 60);
        [_assetButton setTitle:@"本地视频" forState:UIControlStateNormal];
        [_assetButton addTarget:self action:@selector(assetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _assetButton;
}



#pragma mark - 按钮点击事件

/**
 拍照按钮点击
 
 @param button 拍照按钮
 */
- (void)takePhoto:(UIButton *)button{
    if(_mediaType != BJNewsAssetMediaTypeImage){
        [self setMediaType:BJNewsAssetMediaTypeImage];
    }
    [self takePhotoAction:button];
}

- (void)takeVideo:(UIButton *)button{
    if(_mediaType != BJNewsAssetMediaTypeVideo){
        [self setMediaType:BJNewsAssetMediaTypeVideo];
    }
    if([self.videoButton.titleLabel.text isEqualToString:@"开始"]){
        [self.videoButton setTitle:@"停止" forState:UIControlStateNormal];
        [self takeVideoAction:YES];
    }else{
        [self.videoButton setTitle:@"开始" forState:UIControlStateNormal];
        [self takeVideoAction:NO];
    }
}

/**
 开启、关闭闪光灯
 
 @param sender sender description
 */
- (IBAction)flashAction:(id)sender {
    
    [self.iDevice lockForConfiguration:nil];
    
    UIButton *flashButton = (UIButton *)sender;
    flashButton.selected = !flashButton.selected;
    if (flashButton.selected) {
//        if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeOn]) {
//            [self.iDevice setFlashMode:AVCaptureFlashModeOn];
//            //            [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"闪光灯已开启"];
//        }
        if([self.iOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeOn)]){
            self.photoSettings.flashMode = AVCaptureFlashModeOn;
        }
    } else{
//        if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
//            [self.iDevice setFlashMode:AVCaptureFlashModeOff];
//            //            [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"闪光灯已关闭"];
//        }
        if([self.iOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeOff)]){
            self.photoSettings.flashMode = AVCaptureFlashModeOff;
        }
    }
    
    [self.iDevice unlockForConfiguration];
}

/**
 切换前后摄像头
 
 @param sender sender description
 */
- (IBAction)changePositionAction:(id)sender {
    
//    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *newDevice;
    AVCaptureDeviceInput *newInput;
    
    
    if (self.iDevice.position == AVCaptureDevicePositionBack) {
//        for (AVCaptureDevice *device in deviceArray) {
//            if (device.position == AVCaptureDevicePositionFront) {
//                newDevice = device;
//            }
//        }
        newDevice = [self cameraWithPostion:AVCaptureDevicePositionFront];
    } else {
//        for (AVCaptureDevice *device in deviceArray) {
//            if (device.position == AVCaptureDevicePositionBack) {
//                newDevice = device;
//            }
//        }
        newDevice = [self cameraWithPostion:AVCaptureDevicePositionBack];
    }
    
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    if (newInput!=nil) {
        
        [self.iSession beginConfiguration];
        
        [self.iSession removeInput:self.iInput];
        if ([self.iSession canAddInput:newInput]) {
            [self.iSession addInput:newInput];
            self.iDevice = newDevice;
            self.iInput = newInput;
        } else{
            [self.iSession addInput:self.iInput];
        }
        
        [self.iSession commitConfiguration];
        
        [self.iDevice lockForConfiguration:nil];
        if ([self.iDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.iDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        [self.iDevice unlockForConfiguration];
    }
    
}

- (void)assetButtonClick:(UIButton *)button{
    BJNewsAssetViewController * vc = [[BJNewsAssetViewController alloc]init];
    vc.maxCount = 1;
    vc.mediaType = BJNewsAssetMediaTypeVideo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)takePhotoAction:(id)sender {
    
    AVCaptureConnection *connection = [self.iOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        NSLog(@"没有摄像头权限");
    } else{
//        [self.iOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//            if (!imageDataSampleBuffer) {
//                NSLog(@"error");
//            } else{
//                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                UIImage *image = [UIImage imageWithData:imageData];
//
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//
//            }
//        }];
  
//        [self.iOutput setPhotoSettingsForSceneMonitoring:];
        NSDictionary * setDict = @{AVVideoCodecKey:AVVideoCodecJPEG};
        self.photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDict];
        if([self.iOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeAuto)]){
            self.photoSettings.flashMode = AVCaptureFlashModeAuto;
        }
        [self.iOutput capturePhotoWithSettings:self.photoSettings delegate:self];
        
    }
}

- (void)takeVideoAction:(BOOL)isRecord{
    if(isRecord == YES){
        AVCaptureConnection *connect = [self.iMovieOutput connectionWithMediaType:AVMediaTypeVideo];
        if(!connect){
            NSLog(@"没有摄像头权限");
        }else{
            NSURL * url = [NSURL fileURLWithPath:[[BJNewsMediaCache defaultManager] cameraPath]];
            NSLog(@"%@",url.path);
            if (![self.iMovieOutput isRecording]) {
                [self.iMovieOutput startRecordingToOutputFileURL:url recordingDelegate:self];
            }
        }
    }else{
        if ([self.iMovieOutput isRecording]) {
            [self.iMovieOutput stopRecording];
        }
    }
}

#pragma mark - delegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error{
    NSLog(@"拍照结束");
    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithData:data];
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"%@",outputFileURL.path);
    BJNewsMediaItem * model = [[BJNewsMediaItem alloc]init];
    NSLog(@"正在转码");
    [[BJNewsMediaManager defaultManager] exportVideoWithPath:outputFileURL.path progress:^(float progress) {
        
    } completionHandler:^(BOOL isSuc, NSString *filePath, NSInteger fileSize) {
        if(isSuc){
            if([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path]){
                [[NSFileManager defaultManager] removeItemAtPath:outputFileURL.path error:nil];
            }
            model.videoItem.exportPath = filePath;
            NSLog(@"转码完成");
            if(self.callBack){
                self.callBack(model);
            }
            [self writeVideoAtPath:filePath];
        }
    }];
}

#pragma mark - 写入本地相册

- (void)writeVideoAtPath:(NSString *)path{
    if([self isExistFolder:_folderName] == NO){
        [self createFolder:_folderName completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(success){
                [self saveVideoPath:path];
            }else{
                NSLog(@"相册创建失败");
            }
        }];
    }else{
        [self saveVideoPath:path];
    }
}

- (BOOL)isExistFolder:(NSString *)folderName {
    //首先获取用户手动创建相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    __block BOOL isExisted = NO;
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //folderName是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:folderName])  {
            isExisted = YES;
        }
    }];
    
    return isExisted;
}

- (void)createFolder:(NSString *)folderName completionHandler:(void (^) (BOOL success, NSError * _Nullable error))handler{
    if (![self isExistFolder:folderName]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //添加HUD文件夹
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:folderName];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(handler){
                handler(success,error);
            }
            if (success) {
                NSLog(@"创建相册文件夹成功!");
            } else {
                NSLog(@"创建相册文件夹失败:%@", error);
            }
        }];
    }
}

- (void)saveImagePath:(NSString *)imagePath{
    NSURL *url = [NSURL fileURLWithPath:imagePath];
    //标识保存到系统相册中的标识
    __block NSString *localIdentifier;
    //首先获取相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //Camera Roll是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:self->_folderName])  {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //请求创建一个Asset
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                //相册中添加照片
                [collectonRequest addAssets:@[placeHolder]];
                
                localIdentifier = placeHolder.localIdentifier;
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"保存图片成功!");
                } else {
                    NSLog(@"保存图片失败:%@", error);
                }
            }];
        }
    }];
}

- (void)saveVideoPath:(NSString *)videoPath {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    
    //标识保存到系统相册中的标识
    __block NSString *localIdentifier;
    
    //首先获取相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //folderName是我们写入照片的相册
        NSLog(@"相册名称:%@",assetCollection.localizedTitle);
        if ([assetCollection.localizedTitle isEqualToString:self->_folderName])  {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //请求创建一个Asset
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                //相册中添加视频
                [collectonRequest addAssets:@[placeHolder]];

                localIdentifier = placeHolder.localIdentifier;
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"保存视频成功!");
                } else {
                    NSLog(@"保存视频失败:%@", error);
                }
            }];
        }
    }];
}

@end
