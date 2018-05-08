
#import "RTScreenRecorder.h"
#import "ZHFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "RecordTestHeader.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface RTScreenRecorder ()
@property (strong, nonatomic) AVAssetWriter* videoWriter;
@property (strong, nonatomic) AVAssetWriterInput* videoWriterInput;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor* avAdaptor;
@property (strong, nonatomic) CADisplayLink* displayLink;
@property (strong, nonatomic) NSDictionary* outputBufferPoolAuxAttributes;
@property (nonatomic) CFTimeInterval firstTimeStamp;
@property (nonatomic) BOOL isRecording;
@property (nonatomic,assign)BOOL shouldReInit;

@property (strong, nonatomic) NSMutableArray* pauseResumeTimeRanges;

@end

@implementation RTScreenRecorder {
    dispatch_queue_t _render_queue;
    dispatch_queue_t _append_pixelBuffer_queue;
    dispatch_semaphore_t _frameRenderingSemaphore;
    dispatch_semaphore_t _pixelAppendSemaphore;
    CGSize _viewSize;
    CGFloat _scale;
    CGColorSpaceRef _rgbColorSpace;
    CVPixelBufferPoolRef _outputBufferPool;
}

#pragma mark - initializers

+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static RTScreenRecorder* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.shouldReInit = YES;
        // app从后台进入前台都会调用这个方法
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
        // 添加检测app进入后台的观察者
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    });
    return sharedInstance;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationBecomeActive{
    if (self.isPaused) {
        [self resumeRecording];
//        NSLog(@"%@",@"app从后台进入前台");
    }
}

- (void)applicationEnterBackground{
    if (self.isRecording) {
        [self pauseRecording];
        self.shouldReInit = YES;
//        NSLog(@"%@",@"app进入后台");
    }
}

- (void)initData{
    if (!self.shouldReInit) {
        self.shouldReInit = YES;
        return;
    }
    _viewSize = [UIApplication sharedApplication].delegate.window.bounds.size;
    _scale = [UIScreen mainScreen].scale;
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && _scale > 1) {
        _scale = 1.0;
    }
    _isRecording = NO;
    
    _append_pixelBuffer_queue = dispatch_queue_create("RTScreenRecorder.append_queue", DISPATCH_QUEUE_SERIAL);
    _render_queue = dispatch_queue_create("RTScreenRecorder.render_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_render_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    _frameRenderingSemaphore = dispatch_semaphore_create(1);
    _pixelAppendSemaphore = dispatch_semaphore_create(1);
    
    NSInteger compression = 0;
    if ([RTOperationQueue shareInstance].isRecord) {
        compression = [RTConfigManager shareInstance].compressionQualityRecoderVideo + 1;
    }else if([RTCommandList shareInstance].isRunOperationQueue){
        compression = [RTConfigManager shareInstance].compressionQualityRecoderVideoPlayBack + 1;
    }
    if(compression <= 1)compression = 1;
    if(compression > 4)compression = 4;
    
    _fps = 20 + compression*10;
}

- (BOOL)startRecording{
    if (!_isRecording) {
//        NSLog(@"%@",@"视频录制开始");
        [self initData];
        [self setUpWriter];
        _isRecording = (_videoWriter.status == AVAssetWriterStatusWriting);
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(writeVideoFrame)];
        _displayLink.frameInterval = 60 / self.fps;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _isRecording;
}

- (void)pauseRecording{
    if (_displayLink.paused) return;
    if (!self.pauseResumeTimeRanges) self.pauseResumeTimeRanges = [NSMutableArray new];
    [self.pauseResumeTimeRanges addObject:@(_displayLink.timestamp + 0.001)]; //adding a small delay
    _displayLink.paused = YES;
}

- (void)resumeRecording{
    if (_displayLink && _displayLink.isPaused) _displayLink.paused = NO;
}

- (void)stopRecordingWithCompletion:(VideoCompletionBlock)completionBlock;{
    if (_isRecording) {
        _isRecording = NO;
//        NSLog(@"%@",@"视频录制结束");
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self completeRecordingSession:completionBlock];
        self.pauseResumeTimeRanges = nil;
    }
}

- (BOOL)isPaused{
    return _displayLink.paused;
}

- (void)setPaused:(BOOL)paused{
    [self pauseRecording];
}

#pragma mark - private

- (void)setUpWriter{
    _rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    NSDictionary* bufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
        (id)kCVPixelBufferWidthKey : @(_viewSize.width * _scale),
        (id)kCVPixelBufferHeightKey : @(_viewSize.height * _scale),
        (id)kCVPixelBufferBytesPerRowAlignmentKey : @(_viewSize.width * _scale * 4)
    };
    _outputBufferPool = NULL;
    CVPixelBufferPoolCreate(NULL, NULL, (__bridge CFDictionaryRef)(bufferAttributes), &_outputBufferPool);

    NSError* error = nil;
    _videoWriter = [[AVAssetWriter alloc] initWithURL: [self tempFileURL] fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(_videoWriter);

    NSInteger pixelNumber = _viewSize.width * _viewSize.height * _scale;
    
    NSInteger compression = 0;
    if ([RTOperationQueue shareInstance].isRecord) {
        compression = [RTConfigManager shareInstance].compressionQualityRecoderVideo * 3;
    }else if([RTCommandList shareInstance].isRunOperationQueue){
        compression = [RTConfigManager shareInstance].compressionQualityRecoderVideoPlayBack * 3;
    }
    if(compression<=1)compression = 1;
    NSDictionary* videoCompression = @{ AVVideoAverageBitRateKey : @(pixelNumber * compression) };

    NSDictionary* videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
        AVVideoWidthKey : [NSNumber numberWithInt:_viewSize.width * _scale],
        AVVideoHeightKey : [NSNumber numberWithInt:_viewSize.height * _scale],
        AVVideoCompressionPropertiesKey : videoCompression };

    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSParameterAssert(_videoWriterInput);

    _videoWriterInput.expectsMediaDataInRealTime = YES;
    _videoWriterInput.transform = [self videoTransformForDeviceOrientation];

    _avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:nil];

    [_videoWriter addInput:_videoWriterInput];

    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
}

- (CGAffineTransform)videoTransformForDeviceOrientation{
    CGAffineTransform videoTransform;
    switch ([UIDevice currentDevice].orientation) {
    case UIDeviceOrientationLandscapeLeft:
        videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
        break;
    case UIDeviceOrientationLandscapeRight:
        videoTransform = CGAffineTransformMakeRotation(M_PI_2);
        break;
    case UIDeviceOrientationPortraitUpsideDown:
        videoTransform = CGAffineTransformMakeRotation(M_PI);
        break;
    default:
        videoTransform = CGAffineTransformIdentity;
    }
    return videoTransform;
}

- (NSURL*)tempFileURL{
    NSString* outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/screenCapture.mp4"];
    [self removeTempFilePath:outputPath];
    return [NSURL fileURLWithPath:outputPath];
}

- (void)removeTempFilePath:(NSString*)filePath{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
//        NSLog(@"大小:%@", [ZHFileManager fileSizeString:filePath]);
        NSError* error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
//            NSLog(@"Could not delete old recording:%@", [error localizedDescription]);
        }
    }
}

- (void)completeRecordingSession:(VideoCompletionBlock)completionBlock{
    dispatch_async(_render_queue, ^{
        dispatch_sync(_append_pixelBuffer_queue, ^{
            [_videoWriterInput markAsFinished];
            [_videoWriter finishWritingWithCompletionHandler:^{
                NSString *videoPath = _videoWriter.outputURL.path;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(videoPath);
                });
                [self cleanup];
                
//                [self removeTempFilePath:_videoWriter.outputURL.path];
            }];
        });
    });
}

- (void)cleanup{
    self.avAdaptor = nil;
    self.videoWriterInput = nil;
    self.videoWriter = nil;
    self.firstTimeStamp = 0;
    self.outputBufferPoolAuxAttributes = nil;
    CGColorSpaceRelease(_rgbColorSpace);
    CVPixelBufferPoolRelease(_outputBufferPool);
}

- (void)writeVideoFrame{
    if (dispatch_semaphore_wait(_frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0) {
        return;
    }
    dispatch_async(_render_queue, ^{
        if (![_videoWriterInput isReadyForMoreMediaData])
            return;

        if (self.pauseResumeTimeRanges.count % 2 != 0) {
            [self.pauseResumeTimeRanges addObject:@(_displayLink.timestamp)];
        }

        if (!self.firstTimeStamp) {
            self.firstTimeStamp = _displayLink.timestamp;
        }
        CFTimeInterval elapsed = (_displayLink.timestamp - self.firstTimeStamp);
        if (self.pauseResumeTimeRanges.count) {
            for (int i = 0; i < self.pauseResumeTimeRanges.count; i += 2) {
                double pausedTime = [self.pauseResumeTimeRanges[i] doubleValue];
                double resumeTime = [self.pauseResumeTimeRanges[i + 1] doubleValue];
                elapsed -= resumeTime - pausedTime;
            }
        }
        CMTime time = CMTimeMakeWithSeconds(elapsed, 1000);

        CVPixelBufferRef pixelBuffer = NULL;
        CGContextRef bitmapContext = [self createPixelBufferAndBitmapContext:&pixelBuffer];

        if (self.delegate) {
            [self.delegate writeBackgroundFrameInContext:&bitmapContext];
        }

        CGFloat width = _viewSize.width;
        CGFloat height = _viewSize.height;
        
        __block NSInteger statusBarOrientation = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        });
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8") && UIInterfaceOrientationIsLandscape(statusBarOrientation)) {
            width = MAX(_viewSize.width, _viewSize.height);
            height = MIN(_viewSize.width, _viewSize.height);
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            UIGraphicsPushContext(bitmapContext);
            {
                for (UIWindow* window in [[UIApplication sharedApplication] windows]) {
                    [window drawViewHierarchyInRect:CGRectMake(0, 0, width, height) afterScreenUpdates:NO];
                }
            }
            UIGraphicsPopContext();
        });

        if (dispatch_semaphore_wait(_pixelAppendSemaphore, DISPATCH_TIME_NOW) == 0) {
            dispatch_async(_append_pixelBuffer_queue, ^{
                BOOL success = [_avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
                if (!success) {
//                    NSLog(@"Warning: Unable to write buffer to video");
                }
                CGContextRelease(bitmapContext);
                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                CVPixelBufferRelease(pixelBuffer);

                dispatch_semaphore_signal(_pixelAppendSemaphore);
            });
        } else {
            CGContextRelease(bitmapContext);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            CVPixelBufferRelease(pixelBuffer);
        }

        dispatch_semaphore_signal(_frameRenderingSemaphore);
    });
}

- (CGContextRef)createPixelBufferAndBitmapContext:(CVPixelBufferRef*)pixelBuffer{
    CVPixelBufferPoolCreatePixelBuffer(NULL, _outputBufferPool, pixelBuffer);
    CVPixelBufferLockBaseAddress(*pixelBuffer, 0);

    CGContextRef bitmapContext = NULL;
    bitmapContext = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(*pixelBuffer),
        CVPixelBufferGetWidth(*pixelBuffer),
        CVPixelBufferGetHeight(*pixelBuffer),
        8, CVPixelBufferGetBytesPerRow(*pixelBuffer), _rgbColorSpace,
        kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextScaleCTM(bitmapContext, _scale, _scale);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, _viewSize.height);
    CGContextConcatCTM(bitmapContext, flipVertical);
    
    __block NSInteger statusBarOrientation = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    });
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8") && UIInterfaceOrientationIsLandscape(statusBarOrientation)) {
        CGContextRotateCTM(bitmapContext, M_PI_2);
        CGContextTranslateCTM(bitmapContext, 0, -_viewSize.width);
    }
    if (SYSTEM_VERSION_LESS_THAN(@"8") && statusBarOrientation  == UIInterfaceOrientationLandscapeLeft) {
        CGContextRotateCTM(bitmapContext, M_PI);
    }

    return bitmapContext;
}

@end
