//
//  BJNewsExportSession.h
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/29.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface BJNewsExportSession : NSObject

@property (nonatomic,strong) void (^exportProgress) (float progress);
@property (nonatomic,strong) AVAssetExportSession * exportSession;

@end
