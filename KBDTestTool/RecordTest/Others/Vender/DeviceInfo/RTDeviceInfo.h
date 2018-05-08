
#import <Foundation/Foundation.h>

@interface RTDeviceInfo : NSObject

+ (RTDeviceInfo *)shareInstance;
- (void)showDeviceInfo;

@property (nonatomic) float systemAvailableMemory; //系统可用内存
@property (nonatomic) float appMemory;             //app占用内存
@property (nonatomic) float systemCpu;             //系统占用cpu
@property (nonatomic) float appCpu;                //app占用cpu

@property (nonatomic,strong)NSMutableArray *cupMonitor;
@property (nonatomic,strong)NSMutableArray *memoryMonitor;
@property (nonatomic,strong)NSMutableArray *netMonitor;
@property (nonatomic,strong)NSMutableArray *fpsMonitor;
@property (nonatomic,assign)NSInteger minTime;
@property (nonatomic,assign)NSInteger curTime;

@end
