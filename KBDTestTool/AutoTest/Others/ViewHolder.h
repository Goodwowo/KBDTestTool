
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewHolderType) {
    ViewHolderTypeEvent = 1 << 0,
    ViewHolderTypeScroll = 1 << 1,
    ViewHolderTypeScrollVer = 1 << 2,
    ViewHolderTypeScrollHor = 1 << 3,
};

@interface ViewHolder : NSObject

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) NSInteger layerIndex;
@property (nonatomic, assign) uint64_t superView;

@property (nonatomic, assign) ViewHolderType type;

- (instancetype)copyNew;

@end
