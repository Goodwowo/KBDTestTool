
#import <UIKit/UIKit.h>
#import "RTRangeSliderDelegate.h"

IB_DESIGNABLE
@interface RTRangeSlider : UIControl <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<RTRangeSliderDelegate> delegate;
@property (nonatomic, assign) IBInspectable float minValue;
@property (nonatomic, assign) IBInspectable float maxValue;
@property (nonatomic, assign) IBInspectable float selectedMinimum;
@property (nonatomic, assign) IBInspectable float selectedMaximum;
@property (nonatomic, strong) NSNumberFormatter *numberFormatterOverride;
@property (nonatomic, strong) IBInspectable UIColor *minLabelColour;
@property (nonatomic, strong) IBInspectable UIColor *maxLabelColour;
@property (nonatomic, assign) IBInspectable BOOL disableRange;

@end
