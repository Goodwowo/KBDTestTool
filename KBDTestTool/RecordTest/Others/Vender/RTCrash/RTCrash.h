
#ifndef RTCRASH_H
#define RTCRASH_H

#ifdef __cplusplus
extern "C" {
#endif

void rt_installExceptionHandler(void);
void rt_uninstallExceptionHandler(void);
    
#ifdef __cplusplus
}
#endif

#endif
