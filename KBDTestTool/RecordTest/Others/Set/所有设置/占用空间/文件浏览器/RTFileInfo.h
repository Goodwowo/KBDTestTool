
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MLBFileType) {
    MLBFileTypeUnknown,
    MLBFileTypeDirectory,
    // Image
    MLBFileTypeJPG, MLBFileTypePNG, MLBFileTypeGIF, MLBFileTypeSVG, MLBFileTypeBMP, MLBFileTypeTIF,
    // Audio
    MLBFileTypeMP3, MLBFileTypeAAC, MLBFileTypeWAV, MLBFileTypeOGG,
    // Video
    MLBFileTypeMP4, MLBFileTypeAVI, MLBFileTypeFLV, MLBFileTypeMIDI, MLBFileTypeMOV, MLBFileTypeMPG, MLBFileTypeWMV,
    // Apple
    MLBFileTypeDMG, MLBFileTypeIPA, MLBFileTypeNumbers, MLBFileTypePages, MLBFileTypeKeynote,
    // Google
    MLBFileTypeAPK,
    // Microsoft
    MLBFileTypeWord, MLBFileTypeExcel, MLBFileTypePPT, MLBFileTypeEXE, MLBFileTypeDLL,
    // Document
    MLBFileTypeTXT, MLBFileTypeRTF, MLBFileTypePDF, MLBFileTypeZIP, MLBFileType7z, MLBFileTypeCVS, MLBFileTypeMD,
    // Programming
    MLBFileTypeSwift, MLBFileTypeJava, MLBFileTypeC, MLBFileTypeCPP, MLBFileTypePHP,
    MLBFileTypeJSON, MLBFileTypePList, MLBFileTypeXML, MLBFileTypeDatabase,
    MLBFileTypeJS, MLBFileTypeHTML, MLBFileTypeCSS,
    MLBFileTypeBIN, MLBFileTypeDat, MLBFileTypeSQL, MLBFileTypeJAR,
    // Adobe
    MLBFileTypeFlash, MLBFileTypePSD, MLBFileTypeEPS,
    // Other
    MLBFileTypeTTF, MLBFileTypeTorrent,
};

@interface RTFileInfo : NSObject

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSDictionary<NSString *, id> *attributes;

@property (nonatomic, assign) MLBFileType type;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign) NSUInteger filesCount;

@property (nonatomic, strong, readonly) NSString *typeImageName;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInQuickLook;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInWebView;

- (instancetype)initWithFileURL:(NSURL *)URL;

+ (NSDictionary<NSString *, id> *)attributesWithFileURL:(NSURL *)URL;
+ (NSMutableArray<RTFileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL;

@end
