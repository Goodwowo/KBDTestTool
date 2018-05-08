
#import "RTDisPlayAllView.h"
#import "AutoTestHeader.h"
#import "UIView+RTLayerIndex.h"

@interface RTDisPlayAllView ()
@property (nonatomic,strong)NSMutableString *outstring;
@end

@implementation RTDisPlayAllView

- (void)addEventView:(ViewHolder *)holder atIndent:(NSInteger)indent {
    for (int i = 0; i < indent; i++)
        [self.outstring appendString:@"--"];
    
    [self.outstring appendFormat:@"[%2zd] %@ %@ %@\n", indent, [holder.view layerDirector],[holder.view textDescription],NSStringFromClass([holder.view getViewController].class)];
}

- (void)disPlayAllView{
    self.outstring = [NSMutableString string];
    for (int i = 0; i < [UIApplication sharedApplication].windows.count; i++) {
        UIWindow *window = [UIApplication sharedApplication].windows[i];
        if (window.subviews.count > 0) {
            [self dumpView:window layerIndex:0];
        }
    }
//    NSLog(@"%@",@"😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄😄");
//    NSLog(@"Log Window Director:\n%@",self.outstring);
}

- (void)dumpView:(UIView *)aView layerIndex:(NSInteger)layerIndex {
    
    ViewHolder *holder = [[ViewHolder alloc] init];
    holder.view = aView;
    
    [self addEventView:holder atIndent:layerIndex];
    
    for (int i = 0; i < aView.subviews.count; i++) {
        UIView *v = aView.subviews[i];
        [self dumpView:v layerIndex:layerIndex+1];
    }
}

@end
