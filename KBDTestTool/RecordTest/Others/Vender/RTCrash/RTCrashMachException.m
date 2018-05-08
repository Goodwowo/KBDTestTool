#import "RTCrashMachException.h"
#import "RTCrashReporter.h"
#import <sys/sysctl.h>
#import <mach/mach_init.h>

static bool g_isHandlingCrash = false;

static struct{
    exception_mask_t        masks[EXC_TYPES_COUNT];
    exception_handler_t     ports[EXC_TYPES_COUNT];
    exception_behavior_t    behaviors[EXC_TYPES_COUNT];
    thread_state_flavor_t   flavors[EXC_TYPES_COUNT];
    mach_msg_type_number_t  count;
} rt_g_previousExceptionPorts;

static mach_port_t g_exceptionPort = MACH_PORT_NULL;
static bool g_installHandler = false;

@implementation RTCrashMachException

thread_t rt_thread_self() {
    thread_t thread_self = mach_thread_self();
    mach_port_deallocate(mach_task_self(), thread_self);
    return thread_self;
}

void rt_suspendEnvironment(){
    kern_return_t kr;
    const task_t thisTask = mach_task_self();
    const thread_t thisThread = (thread_t)rt_thread_self();
    thread_act_array_t threads;
    mach_msg_type_number_t numThreads;
    
    if((kr = task_threads(thisTask, &threads, &numThreads)) != KERN_SUCCESS){
        return;
    }
    
    for(mach_msg_type_number_t i = 0; i < numThreads; i++){
        thread_t thread = threads[i];
        if(thread != thisThread){
            if((kr = thread_suspend(thread)) != KERN_SUCCESS){
                mach_error_string(kr);
            }
        }
    }
    
    for(mach_msg_type_number_t i = 0; i < numThreads; i++){
        mach_port_deallocate(thisTask, threads[i]);
    }
    
    vm_deallocate(thisTask, (vm_address_t)threads, sizeof(thread_t) * numThreads);
}

void rt_resumeEnvironment(){
    kern_return_t kr;
    const task_t thisTask = mach_task_self();
    const thread_t thisThread = (thread_t)rt_thread_self();
    thread_act_array_t threads;
    mach_msg_type_number_t numThreads;
    
    if((kr = task_threads(thisTask, &threads, &numThreads)) != KERN_SUCCESS){
        return;
    }
    
    for(mach_msg_type_number_t i = 0; i < numThreads; i++){
        thread_t thread = threads[i];
        if(thread != thisThread){
            if((kr = thread_resume(thread)) != KERN_SUCCESS){
                
            }
        }
    }
    
    for(mach_msg_type_number_t i = 0; i < numThreads; i++){
        mach_port_deallocate(thisTask, threads[i]);
    }
    vm_deallocate(thisTask, (vm_address_t)threads, sizeof(thread_t) * numThreads);
}

static void rt_restoreExceptionPorts(void){
    if(rt_g_previousExceptionPorts.count == 0){
        return;
    }
    const task_t thisTask = mach_task_self();
    kern_return_t kr;
    
    for(mach_msg_type_number_t i = 0; i < rt_g_previousExceptionPorts.count; i++){
        kr = task_set_exception_ports(thisTask,
                                      rt_g_previousExceptionPorts.masks[i],
                                      rt_g_previousExceptionPorts.ports[i],
                                      rt_g_previousExceptionPorts.behaviors[i],
                                      rt_g_previousExceptionPorts.flavors[i]);
    }
    rt_g_previousExceptionPorts.count = 0;
}

static void* rt_handleMachExceptions(){
    RTMachExceptionMessage exceptionMessage = {{0}};
    RTMachReplyMessage replyMessage = {{0}};

    for(;;){
        kern_return_t kr = mach_msg(&exceptionMessage.header,
                                    MACH_RCV_MSG,
                                    0,
                                    sizeof(exceptionMessage),
                                    g_exceptionPort,
                                    MACH_MSG_TIMEOUT_NONE,
                                    MACH_PORT_NULL);
        if(kr == KERN_SUCCESS) break;
    }
    
    rt_suspendEnvironment();
    g_isHandlingCrash = true;
    
    rt_restoreExceptionPorts();
    [RTCrashReporter shareObject].crashThread = exceptionMessage.thread.name;
    //获取堆栈信息
    [RTCrashReporter rt_backtraceOfAllThread];

    g_isHandlingCrash = false;
    rt_resumeEnvironment();
    
    replyMessage.header = exceptionMessage.header;
    replyMessage.NDR = exceptionMessage.NDR;
    replyMessage.returnCode = KERN_FAILURE;
    
    mach_msg(&replyMessage.header,
             MACH_SEND_MSG,
             sizeof(replyMessage),
             0,
             MACH_PORT_NULL,
             MACH_MSG_TIMEOUT_NONE,
             MACH_PORT_NULL);
    
    return NULL;
}

static void uninstallMachExceptionHandler(){
    if (g_installHandler == false) return;
    g_installHandler = false;
    rt_restoreExceptionPorts();
    g_exceptionPort = MACH_PORT_NULL;
}

//参考plcrash:判断是否处于debug模式,如果处于debug模式,则不收集signal类型的崩溃;因为实现逻辑与xcode的debuger相冲突,导致app启动的时候就会崩溃
static bool rt_debugger_should_exit (void) {
#if !TARGET_OS_IPHONE
    return false;
#endif
    
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[4];
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1)  return false;
    if ((info.kp_proc.p_flag & P_TRACED) != 0) return true;
    return false;
}

+ (bool)installMachExceptionHandler{
    if (rt_debugger_should_exit()) {
        goto failed;
    }
    
    if (g_installHandler) return true;
    
    kern_return_t kr;
    
    const task_t thisTask = mach_task_self();
    exception_mask_t mask = EXC_MASK_BAD_ACCESS |
    EXC_MASK_BAD_INSTRUCTION |
    EXC_MASK_ARITHMETIC |
    EXC_MASK_SOFTWARE |
    EXC_MASK_BREAKPOINT;
    
    kr = task_get_exception_ports(thisTask,
                                  mask,
                                  rt_g_previousExceptionPorts.masks,
                                  &rt_g_previousExceptionPorts.count,
                                  rt_g_previousExceptionPorts.ports,
                                  rt_g_previousExceptionPorts.behaviors,
                                  rt_g_previousExceptionPorts.flavors);
    if(kr != KERN_SUCCESS) goto failed;
    if(g_exceptionPort == MACH_PORT_NULL) {
        kr = mach_port_allocate(thisTask, MACH_PORT_RIGHT_RECEIVE, &g_exceptionPort);
        if(kr != KERN_SUCCESS)  goto failed;
        kr = mach_port_insert_right(thisTask, g_exceptionPort, g_exceptionPort, MACH_MSG_TYPE_MAKE_SEND);
        if(kr != KERN_SUCCESS)  goto failed;
    }
    
    kr = task_set_exception_ports(thisTask, mask, g_exceptionPort, EXCEPTION_DEFAULT, THREAD_STATE_NONE);
    if(kr != KERN_SUCCESS)  goto failed;
    
    //使用gcd线程池开启一个线程,监听mach异常
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        rt_handleMachExceptions();
    });
    
    g_installHandler = true;
    return true;
    
failed:
    uninstallMachExceptionHandler();
    return false;
}

+ (void)unInstallMachExceptionHandler {
    uninstallMachExceptionHandler();
}

@end
