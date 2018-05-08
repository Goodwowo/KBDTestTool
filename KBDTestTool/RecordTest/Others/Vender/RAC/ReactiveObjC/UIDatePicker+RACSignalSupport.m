
#import "UIDatePicker+RACSignalSupport.h"
#import "RACEXTKeyPathCoding.h"
#import "UIControl+RACSignalSupportPrivate.h"

@implementation UIDatePicker (RACSignalSupport)

- (RACChannelTerminal *)rac_newDateChannelWithNilValue:(NSDate *)nilValue {
	return [self rac_channelForControlEvents:UIControlEventValueChanged key:@keypath(self.date) nilValue:nilValue];
}

@end
