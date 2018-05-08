
#import <Foundation/Foundation.h>
@class RTRangeSlider;

@protocol RTRangeSliderDelegate <NSObject>

-(void)rangeSlider:(RTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum;

@end
