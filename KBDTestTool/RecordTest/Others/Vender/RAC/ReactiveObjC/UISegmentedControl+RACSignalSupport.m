
#import "UISegmentedControl+RACSignalSupport.h"
#import "RACEXTKeyPathCoding.h"
#import "UIControl+RACSignalSupportPrivate.h"

@implementation UISegmentedControl (RACSignalSupport)

- (RACChannelTerminal *)rac_newSelectedSegmentIndexChannelWithNilValue:(NSNumber *)nilValue {
	return [self rac_channelForControlEvents:UIControlEventValueChanged key:@keypath(self.selectedSegmentIndex) nilValue:nilValue];
}

@end
