//
//  ViewController.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "ViewController.h"
#import "BJNewsAssetViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BJNewsCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rightButtonClick:(id)sender{
    BJNewsAssetViewController * vc = [[BJNewsAssetViewController alloc]init];
    vc.maxCount = 1;
    vc.mediaType = BJNewsAssetMediaTypeVideo;
    vc.callBack = ^(NSArray<BJNewsMediaItem *> *results) {
        for (BJNewsMediaItem * item in results) {
            [item exportVideoProgress:^(float progress) {
                
            } completionHandler:^(NSString *filePath, UIImage *previewImage, NSInteger fileSize) {
                NSLog(@"导出完成");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                dispatch_async(dispatch_get_main_queue(), ^{
                    MPMoviePlayerViewController * vc = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:filePath]];
                    [self.navigationController presentMoviePlayerViewControllerAnimated:vc];
                });
                [item subsectionVideoWithID:@"11312" completionHandler:^(NSDictionary *result, NSString *resultPath, NSArray<NSString *> *paths) {
                    NSLog(@"分段完成");
                }];
            }];
          
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)cameraButtonClick:(id)sender{
    BJNewsCameraViewController * vc = [[BJNewsCameraViewController alloc]init];
    vc.callBack = ^(BJNewsMediaItem *model) {
        NSLog(@"%@",model.videoItem.exportPath);
        dispatch_async(dispatch_get_main_queue(), ^{
            MPMoviePlayerViewController * vc = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:model.videoItem.exportPath]];
            [self.navigationController presentMoviePlayerViewControllerAnimated:vc];
        });
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma clang diagnostic pop

@end
