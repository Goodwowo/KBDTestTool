
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, AspectOptions) {
    AspectPositionAfter   = 0,            /// Called after the original implementation (default)
    AspectPositionInstead = 1,            /// Will replace the original implementation.
    AspectPositionBefore  = 2,            /// Called before the original implementation.
    AspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

typedef void (^AspectBeforeBlock)(id target, SEL sel, NSArray *args, int deep);
typedef void (^AspectAfterBlock)(id target, SEL sel, NSArray *args, NSTimeInterval interval, int deep, id retValue);

@protocol AspectToken <NSObject>

- (BOOL)remove;

@end

@protocol AspectInfo <NSObject>

- (id)instance;

- (NSInvocation *)originalInvocation;

- (NSArray *)arguments;

@end

@interface NSObject (Aspects)

+ (id<AspectToken>)aspect_hookSelector:(SEL)selector
                           withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

- (id<AspectToken>)aspect_hookSelector:(SEL)selector
                           withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                before:(AspectBeforeBlock) before
                                 after:(AspectAfterBlock) after
                                 error:(NSError **)error;

@end


typedef NS_ENUM(NSUInteger, AspectErrorCode) {
    AspectErrorSelectorBlacklisted,
    AspectErrorDoesNotRespondToSelector,
    AspectErrorSelectorDeallocPosition,
    AspectErrorSelectorAlreadyHookedInClassHierarchy,
    AspectErrorFailedToAllocateClassPair,
    AspectErrorMissingBlockSignature,
    AspectErrorIncompatibleBlockSignature,

    AspectErrorRemoveObjectAlreadyDeallocated = 100
};

extern NSString *const AspectErrorDomain;
