
#import "ViewHolder.h"

@implementation ViewHolder

- (instancetype)copyNew{
    ViewHolder *copy = [ViewHolder new];
    copy.rect = self.rect;
    copy.view = self.view;
    copy.layerIndex = self.layerIndex;
    copy.superView = self.superView;
    copy.type = self.type;
    return copy;
}

@end
