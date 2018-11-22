//
//  BJNewsMediaLogItem.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "BJNewsMediaLogItem.h"

@implementation BJNewsMediaLogItem

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)updateSize:(NSInteger)size exportPath:(NSString *)exportPath subsectionPath:(NSString *)subsectionPath subsectionCount:(NSInteger)subsectionCount progress:(NSInteger)progress{
    self.size = @(size);
    self.exportPath = exportPath;
    self.subsectionPath = subsectionPath;
    self.subsectionCount = @(subsectionCount);
    self.progress = @(progress);
}

- (NSDictionary *)dictionary{
    NSDictionary * dict = @{
                            @"videoID":self.videoID,
                            @"size":self.size,
                            @"exportPath":self.exportPath,
                            @"subsectionPath":self.subsectionPath,
                            @"subsectionCount":self.subsectionCount,
                            @"progress":self.progress
                            };
    return dict;
}

@end
