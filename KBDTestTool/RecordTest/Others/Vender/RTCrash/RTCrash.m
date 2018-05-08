
#import "RTCrash.h"
#include <execinfo.h>
#import "RTCrashSignal.h"
#import "RTCrashNSException.h"
#import "RTCrashMachException.h"

void rt_installExceptionHandler() {
    rt_installNSExceptionHandler();
    [RTCrashMachException installMachExceptionHandler];
    rt_installSignalHandler();
}

void rt_uninstallExceptionHandler() {
    rt_uninstallNSExceptionHandler();
    [RTCrashMachException unInstallMachExceptionHandler];
    rt_uninstallSignalHandler();
}
