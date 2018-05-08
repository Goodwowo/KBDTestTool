/*
 *
 * Copyright (c) 2015-2020  Bonree Company
 * 北京博睿宏远科技发展有限公司  版权所有 2015-2020
 *
 * PROPRIETARY RIGHTS of Bonree Company are involved in the
 * subject matter of this material.  All manufacturing, reproduction, use,
 * and sales rights pertaining to this subject matter are governed by the
 * license agreement.  The recipient of this software implicitly accepts
 * the terms of the license.
 * 本软件文档资料是博睿公司的资产,任何人士阅读和使用本资料必须获得
 * 相应的书面授权,承担保密责任和接受相应的法律约束.
 *
 */

#ifndef RTBASELIB_H
#define RTBASELIB_H

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
#import <netdb.h>
    
    /**cpu启动到现在的毫秒数*/
    uint32_t rt_cpu_time_ms(void);
    
    //ipv6相关
    enum rt_addr_version {
        rt_addr_NONE = 0,
        rt_addr_IPV4 = 1,
        rt_addr_IPV6 = 2,
    };
    
    struct rt_addr {
        unsigned char addr_veriosn;
        struct in6_addr in_addr;//若是ipv4则放在后4个字节
    };
    
    unsigned char rt_ipv6works(void);
    struct rt_addr rt_hostToIp(NSString *hostname);
    
#ifdef __cplusplus
}
#endif

#endif
