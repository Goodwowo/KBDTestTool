
#import <UIKit/UIKit.h>
typedef void (^VideoCompletionBlock)(NSString *videoPath);
@protocol ASScreenRecorderDelegate;

@interface RTScreenRecorder : NSObject
@property (nonatomic, readonly) BOOL isRecording;

@property (nonatomic, weak) id <ASScreenRecorderDelegate> delegate;

@property (nonatomic, getter = isPaused) BOOL paused;

@property (nonatomic) NSInteger fps;

+ (instancetype)sharedInstance;
- (BOOL)startRecording;
- (void)pauseRecording;
- (void)resumeRecording;
- (void)stopRecordingWithCompletion:(VideoCompletionBlock)completionBlock;

@end

@protocol ASScreenRecorderDelegate <NSObject>
- (void)writeBackgroundFrameInContext:(CGContextRef*)contextRef;
@end
