
#import "RTOperationImage.h"
#import "RecordTestHeader.h"
#import "ZHFileManager.h"

@implementation RTOperationImage

+ (void)load{
    [super load];
    NSString *imagesPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtImages"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *imagesPlayBackPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtPlayBackImagesPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPlayBackPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPlayBackPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *videoPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtVideoPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *videoPlayBackPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtVideoPlayBackPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPlayBackPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoPlayBackPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *crashPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtCrashPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:crashPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:crashPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *lagPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtLagPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:lagPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:lagPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString *)documentsPath{
    static NSString *documentsPath = nil;
    if (documentsPath && documentsPath.length > 0) {
        return documentsPath;
    }
    documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return documentsPath;
}

+ (NSString *)imagesPath{
    NSString *imagesPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtImages"];
    return imagesPath;
}
+ (NSString *)playBackImagesPath{
    NSString *imagesPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtPlayBackImagesPath"];
    return imagesPath;
}
+ (NSString *)videoPath{
    NSString *videoPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtVideoPath"];
    return videoPath;
}
+ (NSString *)videoPlayBackPath{
    NSString *videoPlaBackPath = [[self documentsPath] stringByAppendingPathComponent:@"/rtVideoPlayBackPath"];
    return videoPlaBackPath;
}
+ (NSString *)crashPath{
    NSString *path= [[self documentsPath] stringByAppendingPathComponent:@"/rtCrashPath"];
    return path;
}
+ (NSString *)lagPath{
    NSString *path = [[self documentsPath] stringByAppendingPathComponent:@"/rtLagPath"];
    return path;
}
+ (NSString *)imagesFileSize{
    return [ZHFileManager fileSizeString:[self imagesPath]];
}
+ (NSString *)imagesPlayBackFileSize{
    return [ZHFileManager fileSizeString:[self playBackImagesPath]];
}
+ (NSString *)videoFileSize{
    return [ZHFileManager fileSizeString:[self videoPath]];
}
+ (NSString *)videoPlayBackFileSize{
    return [ZHFileManager fileSizeString:[self videoPlayBackPath]];
}
+ (NSString *)crashFileSize{
    return [ZHFileManager fileSizeString:[self crashPath]];
}
+ (NSString *)lagFileSize{
    return [ZHFileManager fileSizeString:[self lagPath]];
}
+ (NSString *)allSize{
    CGFloat totol =
    [ZHFileManager getFileSize:[self imagesPath]] +
    [ZHFileManager getFileSize:[self playBackImagesPath]] +
    [ZHFileManager getFileSize:[self videoPath]] +
    [ZHFileManager getFileSize:[self videoPlayBackPath]] +
    [ZHFileManager getFileSize:[self crashPath]] +
    [ZHFileManager getFileSize:[self lagPath]];
    return [ZHFileManager sizeOfByte:totol];
}
+ (NSString *)homeDirectorySize{
    return [ZHFileManager sizeOfByte:[ZHFileManager getFileSize:NSHomeDirectory()]];
}
+ (NSString *)imagesFileCount{
    NSInteger count = [ZHFileManager subPathFileArrInDirector:[self imagesPath] hasPathExtension:@[@".png",@".jpg"]].count;
    return [NSString stringWithFormat:@"%zd",count];
}
+ (NSString *)imagesPlayBackFileCount{
    NSInteger count = [ZHFileManager subPathFileArrInDirector:[self playBackImagesPath] hasPathExtension:@[@".png",@".jpg"]].count;
    return [NSString stringWithFormat:@"%zd",count];
}
+ (NSString *)videoFileCount{
    NSInteger count = [ZHFileManager subPathFileArrInDirector:[self videoPath] hasPathExtension:@[@".mp4"]].count;
    return [NSString stringWithFormat:@"%zd",count];
}
+ (NSString *)videoPlayBackFileCount{
    NSInteger count = [ZHFileManager subPathFileArrInDirector:[self videoPlayBackPath] hasPathExtension:@[@".mp4"]].count;
    return [NSString stringWithFormat:@"%zd",count];
}
+ (NSString *)crashFileCount{
    NSInteger count = [ZHFileManager subPathFileArrInDirector:[self crashPath] hasPathExtension:@[@".png",@".jpg"]].count;
    return [NSString stringWithFormat:@"%zd",count];
}
+ (NSString *)lagFileCount{
    NSInteger count = [ZHFileManager subPathFileArrInDirector:[self lagPath] hasPathExtension:@[@".png",@".jpg"]].count;
    return [NSString stringWithFormat:@"%zd",count];
}
+ (BOOL)isExsitImageName:(NSString *)imageName{
    NSString *path = [[self imagesPath] stringByAppendingPathComponent:imageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitPlayBackImageName:(NSString *)imageName{
    NSString *path = [[self playBackImagesPath] stringByAppendingPathComponent:imageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitVideo:(NSString *)video{
    NSString *path = [[self videoPath] stringByAppendingPathComponent:video];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitPlayBackVideo:(NSString *)video{
    NSString *path = [[self videoPlayBackPath] stringByAppendingPathComponent:video];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitCrash:(NSString *)crash{
    NSString *path = [[self crashPath] stringByAppendingPathComponent:crash];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitLag:(NSString *)lag{
    NSString *path = [[self lagPath] stringByAppendingPathComponent:lag];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

+ (NSString *)getRandomImageName{
    NSString *imageName = [self getCharacterFileName];
    while ([self isExsitImageName:imageName]) {
        imageName = [self getCharacterFileName];
    }
    return imageName;
}
+ (NSString *)getRandomPlayBackImageName{
    NSString *imageName = [self getCharacterFileName];
    while ([self isExsitPlayBackImageName:imageName]) {
        imageName = [self getCharacterFileName];
    }
    return imageName;
}
+ (NSString *)getRandomVideoName{
    NSString *videoName = [self getCharacterFileName];
    while ([self isExsitVideo:videoName]) {
        videoName = [self getCharacterFileName];
    }
    return videoName;
}
+ (NSString *)getRandomVideoPlayBackName{
    NSString *videoName = [self getCharacterFileName];
    while ([self isExsitPlayBackVideo:videoName]) {
        videoName = [self getCharacterFileName];
    }
    return videoName;
}
+ (NSString *)getRandomCrashName{
    NSString *videoName = [self getCharacterFileName];
    while ([self isExsitCrash:videoName]) {
        videoName = [self getCharacterFileName];
    }
    return videoName;
}
+ (NSString *)getRandomLagName{
    NSString *videoName = [self getCharacterFileName];
    while ([self isExsitLag:videoName]) {
        videoName = [self getCharacterFileName];
    }
    return videoName;
}

+ (NSString *)getCharacterFileName{
    NSInteger len=25;
    unichar ch;
    NSMutableString *fileName=[NSMutableString string];
    for (NSInteger i=0; i<len; i++) {
        ch='A'+arc4random()%26;
        [fileName appendFormat:@"%C",ch];
    }
    return fileName;
}

+ (NSString *)saveOperationImage:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image,[RTConfigManager shareInstance].compressionQuality);
    NSString *imageName=[NSString stringWithFormat:@"%@.png",[self getRandomImageName]];
    NSString *savePath = [[self imagesPath] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:savePath atomically:YES];
//    NSLog(@"录制 - 图片大小:%@kb",@(imageData.length/1024.0));
    return imageName;
}

+ (NSString *)saveOperationPlayBackImage:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image,[RTConfigManager shareInstance].compressionQuality);
    NSString *imageName=[NSString stringWithFormat:@"%@.png",[self getRandomPlayBackImageName]];
    NSString *savePath = [[self playBackImagesPath] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:savePath atomically:YES];
//    NSLog(@"%@",savePath);
//    NSLog(@"回放 - 图片大小:%@kb",@(imageData.length/1024.0));
    return imageName;
}

+ (NSString *)saveVideo:(NSString *)video{
    NSString *videoName=[NSString stringWithFormat:@"%@.mp4",[self getRandomVideoName]];
    NSString *savePath = [[self videoPath] stringByAppendingPathComponent:videoName];
    [[NSFileManager defaultManager] copyItemAtPath:video toPath:savePath error:nil];
//    NSLog(@"录制视频路径:%@",savePath);
    return videoName;
}
+ (NSString *)savePlayBackVideo:(NSString *)video{
    NSString *videoName=[NSString stringWithFormat:@"%@.mp4",[self getRandomVideoPlayBackName]];
    NSString *savePath = [[self videoPlayBackPath] stringByAppendingPathComponent:videoName];
    [[NSFileManager defaultManager] copyItemAtPath:video toPath:savePath error:nil];
//    NSLog(@"运行回放视频路径:%@",savePath);
    return videoName;
}

+ (NSString *)saveCrash:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image,1);
    NSString *imageName=[NSString stringWithFormat:@"%@.png",[self getRandomCrashName]];
    NSString *savePath = [[self crashPath] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:savePath atomically:YES];
//    NSLog(@"崩溃 - 图片大小:%@kb",@(imageData.length/1024.0));
    return imageName;
}

+ (NSString *)saveLag:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image,1);
    NSString *imageName=[NSString stringWithFormat:@"%@.png",[self getRandomLagName]];
    NSString *savePath = [[self lagPath] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:savePath atomically:YES];
//    NSLog(@"卡顿 - 图片大小:%@kb",@(imageData.length/1024.0));
    return imageName;
}

+ (UIImage *)imageWithName:(NSString *)name{
    NSString *path = [[self imagesPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [UIImage imageWithContentsOfFile:path];
    }
    return [UIImage new];
}

+ (UIImage *)imageWithPlayBackName:(NSString *)name{
    NSString *path = [[self playBackImagesPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [UIImage imageWithContentsOfFile:path];
    }
    return [UIImage new];
}

+ (UIImage *)imageWithCrash:(NSString *)name{
    NSString *path = [[self crashPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [UIImage imageWithContentsOfFile:path];
    }
    return [UIImage new];
}

+ (UIImage *)imageWithLag:(NSString *)name{
    NSString *path = [[self lagPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [UIImage imageWithContentsOfFile:path];
    }
    return [UIImage new];
}

+ (NSString *)imagePathWithName:(NSString *)name{
    return [[self imagesPath] stringByAppendingPathComponent:name];
}

+ (NSString *)imagePathWithPlayBackName:(NSString *)name{
    return [[self playBackImagesPath] stringByAppendingPathComponent:name];
}

+ (NSString *)imagePathWithCrash:(NSString *)name{
    return [[self crashPath] stringByAppendingPathComponent:name];
}
+ (NSString *)imagePathWithLag:(NSString *)name{
    return [[self lagPath] stringByAppendingPathComponent:name];
}

+ (NSString *)videoPathWithName:(NSString *)name{
    NSString *path = [[self videoPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    return @"";
}
+ (NSString *)videoPlayBackPathWithName:(NSString *)name{
    NSString *path = [[self videoPlayBackPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    return @"";
}
+ (BOOL)isExsitName:(NSString *)name{
    NSString *path = [[self imagesPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitPlayBackName:(NSString *)name{
    NSString *path = [[self playBackImagesPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitVideoName:(NSString *)name{
    NSString *path = [[self videoPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isExsitPlayBackVideoName:(NSString *)name{
    NSString *path = [[self videoPlayBackPath] stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

+ (void)deleteOverdueImage{
    NSString *director = [self imagesPath];
    NSArray *subPathFilesArrInDirector = [self subPathFileArrInDirector:director];
    NSMutableArray *allImages = [NSMutableArray array];
    NSArray *operationQueueModels = [RTOperationQueue alloperationQueueModels];
    for (RTOperationQueueModel *model in operationQueueModels) {
        if (model.imagePath.length>0) {
            [allImages addObject:model.imagePath];
        }
    }
    for (NSString *filename in subPathFilesArrInDirector) {
        if (![allImages containsObject:filename]) {
            NSString *deletePath = [director stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil];
        }
    }
}

+ (void)deleteOverduePlayBackImage{
    NSString *director = [self playBackImagesPath];
    NSArray *subPathFilesArrInDirector = [self subPathFileArrInDirector:director];
    NSMutableArray *allImages = [NSMutableArray array];
    NSArray *allPlayBackModels = [RTPlayBack allPlayBackModels];
    for (RTOperationQueueModel *model in allPlayBackModels) {
        if (model.imagePath.length>0) {
            [allImages addObject:model.imagePath];
        }
    }
    for (NSString *filename in subPathFilesArrInDirector) {
        if (![allImages containsObject:filename]) {
            NSString *deletePath = [director stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil];
        }
    }
}

+ (void)deleteOverdueVideo{
    NSString *director = [self videoPath];
    NSArray *subPathFilesArrInDirector = [self subPathFileArrInDirector:director];
    NSArray *allVideos = [[[RTRecordVideo shareInstance] videos] allValues];
    for (NSString *filename in subPathFilesArrInDirector) {
        if (![allVideos containsObject:filename]) {
            NSString *deletePath = [director stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil];
        }
    }
}

+ (void)deleteOverduePlayBackVideo{
    NSString *director = [self videoPlayBackPath];
    NSArray *subPathFilesArrInDirector = [self subPathFileArrInDirector:director];
    NSArray *allVideos = [[[RTRecordVideo shareInstance] videosPlayBacks] allValues];
    for (NSString *filename in subPathFilesArrInDirector) {
        if (![allVideos containsObject:filename]) {
            NSString *deletePath = [director stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil];
        }
    }
}

+ (void)deleteOverdueCrash{
    NSString *director = [self crashPath];
    NSArray *subPathFilesArrInDirector = [self subPathFileArrInDirector:director];
    NSMutableArray *allImages = [NSMutableArray array];
    NSArray *crashs = [[[RTCrashLag shareInstance] crashs] allValues];
    for (RTCrashModel *model in crashs) {
        if (model.imagePath.length>0) {
            [allImages addObject:model.imagePath];
        }
    }
    for (NSString *filename in subPathFilesArrInDirector) {
        if (![allImages containsObject:filename]) {
            NSString *deletePath = [director stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil];
        }
    }
}

+ (void)deleteOverdueLag{
    NSString *director = [self lagPath];
    NSArray *subPathFilesArrInDirector = [self subPathFileArrInDirector:director];
    NSMutableArray *allImages = [NSMutableArray array];
    NSArray *lags = [[[RTCrashLag shareInstance] lags] allValues];
    for (RTLagModel *model in lags) {
        if (model.imagePath.length>0) {
            [allImages addObject:model.imagePath];
        }
    }
    for (NSString *filename in subPathFilesArrInDirector) {
        if (![allImages containsObject:filename]) {
            NSString *deletePath = [director stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil];
        }
    }
}

+ (NSArray *)subPathFileArrInDirector:(NSString *)DirectorPath{
    if (![[NSFileManager defaultManager]fileExistsAtPath:DirectorPath]) {
        return nil;
    }
    NSArray *arrTemp=[[NSFileManager defaultManager]subpathsAtPath:DirectorPath];
    NSMutableArray *pathFileArr=[NSMutableArray array];
    for (NSString *str in arrTemp) {
        if (str.length>0) {
            [pathFileArr addObject:str];
        }
    }
    if (pathFileArr.count>0) {
        return pathFileArr;
    }
    return nil;
}

+ (NSArray *)allFilePaths{
    NSMutableArray *allFilePaths = [NSMutableArray array];
    [allFilePaths addObject:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/ZHJSONData.rdb"]];
    if ([RTConfigManager shareInstance].isMigrationImage) {
        [allFilePaths addObjectsFromArray:[ZHFileManager subPathFileArrInDirector:[self imagesPath] hasPathExtension:@[@".png",@".jpg"]]];
        [allFilePaths addObjectsFromArray:[ZHFileManager subPathFileArrInDirector:[self playBackImagesPath] hasPathExtension:@[@".png",@".jpg"]]];
    }
    if ([RTConfigManager shareInstance].isMigrationVideo) {
        [allFilePaths addObjectsFromArray:[ZHFileManager subPathFileArrInDirector:[self videoPath] hasPathExtension:@[@".mp4"]]];
        [allFilePaths addObjectsFromArray:[ZHFileManager subPathFileArrInDirector:[self videoPlayBackPath] hasPathExtension:@[@".mp4"]]];
    }
    return allFilePaths;
}

+ (void)addFileFromOtherDevice:(NSString *)filePath data:(NSData *)data{
    if ([filePath rangeOfString:@"Documents/"].location!=NSNotFound) {
        filePath = [filePath substringFromIndex:[filePath rangeOfString:@"Documents/"].location+@"Documents/".length];
        filePath = [[self documentsPath] stringByAppendingPathComponent:filePath];
        if ([filePath hasSuffix:@".rdb"]) {//数据库文件里面的数据一直增加
            NSString *newFilePath = [ZHFileManager changeFileOldPath:filePath newFileName:@"tempDataBase"];
            [data writeToFile:newFilePath atomically:YES];
            [RTRecordVideo addVideosFromOtherDataBase:newFilePath];
            [RTRecordVideo addVideosPlayBacksFromOtherDataBase:newFilePath];
            [RTOperationQueue addOperationQueuesFromOtherDataBase:newFilePath];
            [RTPlayBack addPlayBacksFromOtherDataBase:newFilePath];
            [RTOpenDataBase closeDataBasePath:newFilePath];
            [[NSFileManager defaultManager]removeItemAtPath:newFilePath error:nil];
        }else{
            [data writeToFile:filePath atomically:YES];
        }
    }
}

+ (BOOL)isExsitFileFromOtherDevice:(NSString *)filePath{
    if ([filePath hasSuffix:@".rdb"]) {//数据库文件里面的数据一直增加
        return NO;
    }
    if ([filePath rangeOfString:@"Documents/"].location!=NSNotFound) {
        filePath = [filePath substringFromIndex:[filePath rangeOfString:@"Documents/"].location+@"Documents/".length];
        filePath = [[self documentsPath] stringByAppendingPathComponent:filePath];
        if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
            return YES;
        }
    }
    return NO;
}

+ (void)removeCrash:(NSString *)name{
    if (name && name.length>0 &&[self isExsitCrash:name]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self imagePathWithCrash:name] error:nil];
    }
}
+ (void)removeLag:(NSString *)name{
    if (name && name.length>0 &&[self isExsitLag:name]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self imagePathWithLag:name] error:nil];
    }
}

@end
