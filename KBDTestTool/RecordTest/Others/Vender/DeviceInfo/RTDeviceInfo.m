
#import "RTDeviceInfo.h"
#import "RecordTestHeader.h"
#include <mach/mach.h>
#import <sys/sysctl.h>
#include <malloc/malloc.h>
#import "RTTcping.h"

@implementation RTDeviceInfo
{
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    NSTimeInterval _llll;
}

- (float)rt_systemAvailableMemoryInfo{
    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0){
        fprintf (stderr, "getting page size");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS){
        fprintf (stderr, "Failed to get VM statistics.");
    }
    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
    
    float unit = 1024 * 1024;
    float total = (vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize / unit;
    float free = vmstat.free_count * pagesize / unit + [self rt_sysTotalMemory] - total;
    return free;
}

- (float)rt_sysTotalMemory {
    static int64_t total = 0;
    if (total <= 0) {
        total = [[NSProcessInfo processInfo] physicalMemory];
        if (total < -1) total = -1;
        float unit = 1024 * 1024;
        double tempTotal = total / unit;
        total = tempTotal;
    }
    return (float) total;
}

- (float)rt_appMemoryInfo {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),TASK_BASIC_INFO,(task_info_t)&taskInfo,&infoCount);
    if (kernReturn != KERN_SUCCESS) return NSNotFound;
    float memory = (taskInfo.resident_size) / 1024.0 / 1024.0;
    float per = 1.9*(200-memory)/200;
    if(per<0)per = 0;
    per += 1.5;
    if(memory>200)per = 1.0;
    return  memory/per;
}

- (float)rt_systemCpuInfo {
    static processor_info_array_t cpuinfo, prevCPUInfo = nil;
    static mach_msg_type_number_t numCPUInfo, numPrevCPUInfo = 0;
    static unsigned numCPUs;
    static NSLock *cpuUsageLock = nil;
    
    float tot_cpu = 0;
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status) numCPUs = 1;
    if (cpuUsageLock == nil) cpuUsageLock = [[NSLock alloc] init];
    
    [cpuUsageLock lock];
    
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuinfo, &numCPUInfo);
    if(err == KERN_SUCCESS) {
        
        for(unsigned i = 0U; i < numCPUs; ++i) {
            Float32 inUse, total;
            if(prevCPUInfo) {
                inUse = (
                         (cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                total = inUse + (cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuinfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            if (total == 0) tot_cpu = 0;
            else tot_cpu = tot_cpu + inUse / total * 100.f;
        }
        
        if(prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCPUInfo, prevCpuInfoSize);
        }
        prevCPUInfo = cpuinfo;
        numPrevCPUInfo = numCPUInfo;
        
        cpuinfo = nil;
        numCPUInfo = 0U;
    } else {
        tot_cpu = 0;
    }
    
    [cpuUsageLock unlock];
    
    if (tot_cpu > 100) tot_cpu = 100;
    return tot_cpu;
}

- (float)rt_appCpuInfo {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) return -1;
    
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) return -1;
    
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    } // for each thread
    
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    if (tot_cpu > 100.0) tot_cpu = 100.0;
    return tot_cpu;
}

- (BOOL)update {
    //500毫秒以内不重复取值
    static uint32_t ppi_time = 0;
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    uint32_t now = mach_absolute_time() * timebase.numer / timebase.denom /1e6;
    if (ppi_time == 0 || (now - ppi_time) >= 1000) {
        _systemAvailableMemory = [self rt_systemAvailableMemoryInfo];
        _appMemory = [self rt_appMemoryInfo];
        _systemCpu = [self rt_systemCpuInfo];
        _appCpu    = [self rt_appCpuInfo];
        if (_appCpu > _systemCpu) {
            _appCpu = _systemCpu;
        }
        ppi_time = now;
        return YES;
    }
    return NO;
}


+ (RTDeviceInfo *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTDeviceInfo *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTDeviceInfo alloc] init];
        _sharedObject.cupMonitor = [NSMutableArray array];
        _sharedObject.memoryMonitor = [NSMutableArray array];
        _sharedObject.netMonitor = [NSMutableArray array];
        _sharedObject.fpsMonitor = [NSMutableArray array];
        _sharedObject.minTime = 0;
        _sharedObject.curTime = 0;
    });
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SuspendBall shareInstance] setBadge:[NSString stringWithFormat:@"%dfps",(int)round(fps)] index:3];
        [self.fpsMonitor addObject:[NSString stringWithFormat:@"%d",(int)round(fps)]];
    });
}

- (void)dealloc {
    [_link invalidate];
}

- (void)showDeviceInfo{
    if ([self update]) {
        self.curTime ++;
        [self showCpu];
        [self showMemory];
        [self showNetDelay];
        if (![RTConfigManager shareInstance].isShowFPS){
            [_link setPaused:YES];
            [self.fpsMonitor addObject:[NSString stringWithFormat:@"%d",0]];
        }else [_link setPaused:NO];
        while (self.cupMonitor.count > 3600) {
            [self.cupMonitor removeFirstObject];
            self.minTime ++;
        }
        while (self.memoryMonitor.count > 3600) [self.memoryMonitor removeFirstObject];
        while (self.netMonitor.count > 3600) [self.netMonitor removeFirstObject];
        while (self.fpsMonitor.count > 3600) [self.fpsMonitor removeFirstObject];
    }
}

/**显示CPU使用率*/
- (void)showCpu{
    if ([RTConfigManager shareInstance].isShowCpu) {
        float cup = [self rt_appCpuInfo];
        [[SuspendBall shareInstance] setBadge:[NSString stringWithFormat:@"%0.1f%%",cup] index:0];
        [self.cupMonitor addObject:[NSString stringWithFormat:@"%0.1f",cup]];
    }else{
        [self.cupMonitor addObject:[NSString stringWithFormat:@"%0.1f",0.0]];
    }
}

/**显示内存使用*/
- (void)showMemory{
    if ([RTConfigManager shareInstance].isShowMemory) {
        float memory = [self appMemory];
        [[SuspendBall shareInstance] setBadge:[NSString stringWithFormat:@"%0.1fM",memory] index:1];
        [self.memoryMonitor addObject:[NSString stringWithFormat:@"%0.1f",memory]];
    }else{
        [self.memoryMonitor addObject:[NSString stringWithFormat:@"%0.1f",0.0]];
    }
}

/**显示网络延迟*/
- (void)showNetDelay{
    if ([RTConfigManager shareInstance].isShowNetDelay) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 处理耗时操作的代码块...
            int delay = [[RTTcping sharedObj] tcpingDefaultHost];
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SuspendBall shareInstance] setBadge:[NSString stringWithFormat:@"%dms",delay] index:2];
                [self.netMonitor addObject:[NSString stringWithFormat:@"%d",delay]];
            });
        });
    }else{
        [self.netMonitor addObject:[NSString stringWithFormat:@"%d",0]];
    }
}

@end
