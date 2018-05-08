
#import <UIKit/UIKit.h>

/**
 这个类的主要作用是:
 1.简洁的添加Action触发事件,使用了Block块,不不是传统的Selector
 2.可以添加多个Action触发事件,系统的不能
 3.不需要绑定执行触发事件的target,把UIGestureRecognizer(自己)作为target,这样还不用担心内存释放的问题,并且当我们在运行时为某个控件添加一个UIGestureRecognizer时,就不用担心找不到target了(因为找到的target还需要为其注入传统的Selector)
 */

@interface UIGestureRecognizer (YYKitAdd)

- (instancetype)initWithActionBlock:(void (^)(id sender))block;

- (void)addActionBlock:(void (^)(id sender))block;

- (void)removeAllActionBlocks;

@property (nonatomic,assign)BOOL isYYKit;

@end

