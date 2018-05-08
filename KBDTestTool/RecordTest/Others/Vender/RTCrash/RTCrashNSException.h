
#ifndef RTCrashNSException_h
#define RTCrashNSException_h

#ifdef __cplusplus
extern "C" {
#endif
    
    void rt_installNSExceptionHandler(void);
    void rt_uninstallNSExceptionHandler(void);
    
#ifdef __cplusplus
}
#endif

#endif
