
#ifndef RTCrashSignal_h
#define RTCrashSignal_h

#include <stdbool.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    bool rt_installSignalHandler(void);
    void rt_uninstallSignalHandler(void);
    
#ifdef __cplusplus
}
#endif

#endif
