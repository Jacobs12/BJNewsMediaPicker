//
//  NSString+BJNewsMediaMD5.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "NSString+BJNewsMediaMD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (BJNewsMediaMD5)

- (nullable NSString *)md5{
    NSString * str = self;
    if (!str){
        return nil;
    }
    
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}

@end
