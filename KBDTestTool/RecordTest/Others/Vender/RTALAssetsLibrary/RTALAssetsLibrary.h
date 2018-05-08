//
//  RTALAssetsLibrary.h
//  CJOL
//
//  Created by mac on 2018/4/13.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTALAssetsLibrary : NSObject

+ (RTALAssetsLibrary *)shareInstance;

//导出视频到相册
- (void)saveVideoToPhotosAlbum:(NSString *)videoPath;

//导出照片到相册
- (void)savePhotoToPhotosAlbum:(NSString *)imagePath;

@end
