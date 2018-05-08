
#import "UITextView+KVO.h"
#import "RecordTestHeader.h"

@implementation UITextView (KVO)

- (void)kvo{
    if (self.isKVO) {
        return;
    }
    if (KVO_TextView) {
        [[self.rac_textSignal distinctUntilChanged] subscribeNext:^(id x) {
//            NSLog(@"👌TextView 文字改变了%@",x);
            [RTOperationQueue addOperation:self type:(RTOperationQueueTypeTextChange) parameters:@[x] repeat:NO];
        }];
    }
    if(KVO_Super) [super kvo];
    self.isKVO = YES;
}

- (BOOL)runOperation:(RTOperationQueueModel *)model{
    BOOL result = NO;
    if (model) {
        if (model.viewId.length == self.layerDirector.length) {
            if ([model.viewId isEqualToString:self.layerDirector]) {
                if (model.type == RTOperationQueueTypeTextChange) {
                    NSString *text = model.parameters[0];
                    if (self.delegate) {
                        if([self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
                            [self.delegate textViewShouldBeginEditing:self];
                        if([self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
                            [self.delegate textViewDidBeginEditing:self];
                    }
                    
                    self.text = text;
                    
                    if (self.delegate) {
                        if([self.delegate respondsToSelector:@selector(textViewShouldEndEditing:)])
                            [self.delegate textViewShouldEndEditing:self];
                        if([self.delegate respondsToSelector:@selector(textViewDidEndEditing:)])
                            [self.delegate textViewDidEndEditing:self];
                        if([self.delegate respondsToSelector:@selector(textViewDidChange:)])
                            [self.delegate textViewDidChange:self];
                        if([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
                            [self.delegate textView:self shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:text];
                    }
                    
                    result = YES;
                }
            }
        }
    }
    if ([super runOperation:model]) {
        result = YES;
    }
    return result;
}

@end
