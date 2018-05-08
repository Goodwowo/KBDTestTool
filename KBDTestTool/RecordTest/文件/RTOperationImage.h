
#import <UIKit/UIKit.h>

@interface RTOperationImage : NSObject

+ (NSString *)imagesFileSize;
+ (NSString *)imagesPlayBackFileSize;
+ (NSString *)imagesFileCount;
+ (NSString *)imagesPlayBackFileCount;
+ (NSString *)saveOperationImage:(UIImage *)image;
+ (NSString *)saveOperationPlayBackImage:(UIImage *)image;
+ (UIImage *)imageWithName:(NSString *)name;
+ (UIImage *)imageWithPlayBackName:(NSString *)name;
+ (NSString *)imagePathWithName:(NSString *)name;
+ (NSString *)imagePathWithPlayBackName:(NSString *)name;
+ (BOOL)isExsitName:(NSString *)name;
+ (void)deleteOverdueImage;
+ (void)deleteOverduePlayBackImage;


+ (NSString *)videoPath;
+ (NSString *)videoPlayBackPath;
+ (NSString *)videoFileSize;
+ (NSString *)videoPlayBackFileSize;
+ (NSString *)allSize;
+ (NSString *)homeDirectorySize;
+ (NSString *)videoFileCount;
+ (NSString *)videoPlayBackFileCount;
+ (BOOL)isExsitVideo:(NSString *)video;
+ (BOOL)isExsitPlayBackVideo:(NSString *)video;
+ (NSString *)saveVideo:(NSString *)video;
+ (NSString *)savePlayBackVideo:(NSString *)video;
+ (NSString *)videoPathWithName:(NSString *)name;
+ (NSString *)videoPlayBackPathWithName:(NSString *)name;
+ (BOOL)isExsitVideoName:(NSString *)name;
+ (BOOL)isExsitPlayBackVideoName:(NSString *)name;
+ (void)deleteOverdueVideo;
+ (void)deleteOverduePlayBackVideo;

+ (NSArray *)allFilePaths;
+ (void)addFileFromOtherDevice:(NSString *)filePath data:(NSData *)data;
+ (BOOL)isExsitFileFromOtherDevice:(NSString *)filePath;


+ (NSString *)crashFileSize;
+ (NSString *)lagFileSize;
+ (NSString *)crashFileCount;
+ (NSString *)lagFileCount;
+ (BOOL)isExsitCrash:(NSString *)crash;
+ (BOOL)isExsitLag:(NSString *)lag;
+ (NSString *)saveCrash:(UIImage *)image;
+ (NSString *)saveLag:(UIImage *)image;
+ (UIImage *)imageWithCrash:(NSString *)name;
+ (UIImage *)imageWithLag:(NSString *)name;
+ (NSString *)imagePathWithCrash:(NSString *)name;
+ (NSString *)imagePathWithLag:(NSString *)name;
+ (void)removeCrash:(NSString *)name;
+ (void)removeLag:(NSString *)name;
+ (void)deleteOverdueCrash;
+ (void)deleteOverdueLag;

@end
