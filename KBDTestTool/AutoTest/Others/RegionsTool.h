
#import <UIKit/UIKit.h>

@interface RegionsTool : NSObject

/**
 过滤调那些被挡住的控件
 场景:找到那些控件在window边框范围内的控件,把它们(根据上下顺序,上面的会盖住下面的)所有的在window的frame值(frameInWindow而不是frame)收集起来,
 因为都可以接收事件,所以一旦某个控件被其它控件(可以接收事件)挡住,那么这个控件就应该被过滤调,因为不能去触发这个被挡住的事件(虽然不会崩溃),
 根据这个需求,我们可以将其转化为 n个矩形相交,当某个矩形与另外的矩形的相交,我们就把除了相交的交集(其实也是一个矩形)去除,然后剩下的就可分割成了两个矩形了,依次类推,(剩下的矩形)继续上游去寻找是否被遮挡,如果都被遮挡,那么就可以确定这个矩形被完全遮挡,否则这个矩形没有被完全遮挡
 */
+ (NSMutableArray *)filterEvents:(NSMutableArray *)events;
+ (NSMutableArray *)removesEvent:(NSMutableArray *)events;

@end
