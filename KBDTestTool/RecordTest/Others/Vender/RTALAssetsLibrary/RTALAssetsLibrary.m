//
//  RTALAssetsLibrary.m
//  CJOL
//
//  Created by mac on 2018/4/13.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import "RTALAssetsLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RecordTestHeader.h"

@implementation RTALAssetsLibrary

+ (RTALAssetsLibrary *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTALAssetsLibrary *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTALAssetsLibrary alloc] init];
    });
    return _sharedObject;
}

//导出视频到相册
- (void)saveVideoToPhotosAlbum:(NSString *)videoPath{
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL* assetURL, NSError* error) {
        if (error) {
            [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:[NSString stringWithFormat:@"保存失败:%@!",[error localizedDescription]]];
        } else {
            [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"已经保存到相册!"];
        }
    }];
}

//导出照片到相册
- (void)savePhotoToPhotosAlbum:(NSString *)imagePath{
    UIImageWriteToSavedPhotosAlbum([UIImage imageNamed:imagePath], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:[NSString stringWithFormat:@"保存失败:%@!",[error localizedDescription]]];
    } else {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"已经保存到相册!"];
    }
}

@end
