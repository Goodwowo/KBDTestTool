
#import "RTPickerManager.h"

@implementation RTPickerManager

+ (RTPickerManager *)shareManger {
    static RTPickerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return  manager;
}

- (RTPickerView *)pickView {
    if (!_pickView) {
        _pickView = [RTPickerView new];
    }
    return _pickView;
}

// ================================pickerView===================================//

- (void)showPickerViewWithDataArray:(NSArray *)array curTitle:(NSString *)curTitle title:(NSString *)title cancelTitle:(NSString *)cancelTitle commitTitle:(NSString *)commitTitle commitBlock:(PickerViewCommitBlock)commitBlock cancelBlock:(PickerViewCancelBlock)cancelBlock {
    
    self.pickView.curTitle = curTitle;
    self.pickView.toolBar.titleBarTitle = title;
    self.pickView.toolBar.cancelBarTitle = cancelTitle;
    self.pickView.toolBar.commitBarTitle = commitTitle;
    [self.pickView showRTPickerViewWithDataArray:array commitBlock:^(NSString *string) {
        if (commitBlock) {
            commitBlock(string);
        }
    } cancelBlock:^{
        if (cancelBlock) {
            cancelBlock();
        }
    }];
    
}

@end
