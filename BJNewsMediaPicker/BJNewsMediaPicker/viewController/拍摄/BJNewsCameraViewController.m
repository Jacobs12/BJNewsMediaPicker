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

@interface BJNewsCameraViewController ()<AVCaptureFileOutputRecordingDelegate>{
    BJNewsAssetMediaType _mediaType;
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
 输出照片
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *iOutput;

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

@end

@implementation BJNewsCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)createView{
    [self.view addSubview:self.photoButton];
    [self.view addSubview:self.videoButton];
}

- (UIButton *)photoButton{
    if(_photoButton == nil){
        _photoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _photoButton.frame = CGRectMake(100, 100, 100, 60);
        [_photoButton setTitle:@"拍照" forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton *)videoButton{
    if(_videoButton == nil){
        _videoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _videoButton.frame = CGRectMake(100, 200, 100, 60);
        [_videoButton setTitle:@"开始" forState:UIControlStateNormal];
        [_videoButton addTarget:self action:@selector(takeVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoButton;
}

- (AVCaptureSession *)iSession{
    if(_iSession == nil){
        _iSession = [[AVCaptureSession alloc]init];
    }
    return _iSession;
}

- (void)initCamera{
    self.iSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //    前后摄像头
    NSArray * deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * device in deviceArray) {
        if(device.position == AVCaptureDevicePositionBack){
            self.iDevice = device;
        }
    }
    //添加摄像头设备
    //对设备进行设置时需上锁，设置完再打开锁
    [self.iDevice lockForConfiguration:nil];
    if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [self.iDevice setFlashMode:AVCaptureFlashModeAuto];
    }
    if ([self.iDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self.iDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([self.iDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        [self.iDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    [self.iDevice unlockForConfiguration];
    //添加音频设备
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    
    self.iInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.iDevice error:nil];
    
    self.iOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *setDic = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    self.iOutput.outputSettings = setDic;
    
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
    
    self.iPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.iSession];
    [self.iPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.iPreviewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.iPreviewLayer atIndex:0];
    
    [self.iSession startRunning];
}

/**
 设置拍摄模式：照片、视频
 
 @param mediaType 拍摄模式
 */
- (IBAction)setMediaType:(BJNewsAssetMediaType)mediaType {
    _mediaType = mediaType;
    
    //    self.videoBtn.selected = !self.videoBtn.selected;
    if (mediaType == BJNewsAssetMediaTypeVideo) {
        
        [self.iSession beginConfiguration];
        [self.iSession removeOutput:self.iOutput];
        if ([self.iSession canAddOutput:self.iMovieOutput]) {
            [self.iSession addOutput:self.iMovieOutput];
            
            //            [self.takePhotoBtn setTitle:@"开始" forState:UIControlStateNormal];
            
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
        if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeOn]) {
            [self.iDevice setFlashMode:AVCaptureFlashModeOn];
            //            [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"闪光灯已开启"];
        }
    } else{
        if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
            [self.iDevice setFlashMode:AVCaptureFlashModeOff];
            //            [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"闪光灯已关闭"];
        }
    }
    
    [self.iDevice unlockForConfiguration];
}

/**
 切换前后摄像头
 
 @param sender sender description
 */
- (IBAction)changePositionAction:(id)sender {
    
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *newDevice;
    AVCaptureDeviceInput *newInput;
    
    
    if (self.iDevice.position == AVCaptureDevicePositionBack) {
        for (AVCaptureDevice *device in deviceArray) {
            if (device.position == AVCaptureDevicePositionFront) {
                newDevice = device;
            }
        }
    } else {
        for (AVCaptureDevice *device in deviceArray) {
            if (device.position == AVCaptureDevicePositionBack) {
                newDevice = device;
            }
        }
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
    }
    
}

- (IBAction)takePhotoAction:(id)sender {
    
    AVCaptureConnection *connection = [self.iOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        NSLog(@"没有摄像头权限");
    } else{
        [self.iOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (!imageDataSampleBuffer) {
                NSLog(@"error");
            } else{
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [UIImage imageWithData:imageData];
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
            }
        }];
    }
}

- (void)takeVideoAction:(BOOL)isRecord{
    if(isRecord == YES){
        AVCaptureConnection *connect = [self.iMovieOutput connectionWithMediaType:AVMediaTypeVideo];
        if(!connect){
            NSLog(@"没有摄像头权限");
        }else{
            NSDateFormatter * df = [[NSDateFormatter alloc]init];
            df.dateFormat = @"yyyyMMddhhmmss";
            NSString * fileName = [df stringFromDate:[NSDate date]];
            //            NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"cameraVideo.mov"]];
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
            
            //保存视频到相册
            ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
            [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:filePath] completionBlock:^(NSURL *assetURL, NSError *error) {
                NSLog(@"视频保存成功");
            }];
        }
    }];
    //    //保存视频到相册
    //    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    //    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:nil];
    //    NSLog(@"视频保存成功");
}
@end
