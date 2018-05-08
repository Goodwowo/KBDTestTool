
#ifndef _NETINET_IF_ETHER_H_
#define _NETINET_IF_ETHER_H_
#include <sys/appleapiopts.h>

#include <netinet/in.h>
#include "if_arp.h"
#define ea_byte	ether_addr_octet

#define ETHER_MAP_IP_MULTICAST(ipaddr, enaddr) \
 \
 \
{ \
(enaddr)[0] = 0x01; \
(enaddr)[1] = 0x00; \
(enaddr)[2] = 0x5e; \
(enaddr)[3] = ((const u_char *)ipaddr)[1] & 0x7f; \
(enaddr)[4] = ((const u_char *)ipaddr)[2]; \
(enaddr)[5] = ((const u_char *)ipaddr)[3]; \
}

#define ETHER_MAP_IPV6_MULTICAST(ip6addr, enaddr)			\
					\
				\
{                                                                       \
(enaddr)[0] = 0x33;						\
(enaddr)[1] = 0x33;						\
(enaddr)[2] = ((const u_char *)ip6addr)[12];				\
(enaddr)[3] = ((const u_char *)ip6addr)[13];				\
(enaddr)[4] = ((const u_char *)ip6addr)[14];				\
(enaddr)[5] = ((const u_char *)ip6addr)[15];				\
}

struct	ether_arp {
    struct	arphdr ea_hdr;	
    u_char	arp_spa[4];	
    u_char	arp_tpa[4];	
};

#define	arp_hrd	ea_hdr.ar_hrd
#define	arp_pro	ea_hdr.ar_pro
#define	arp_hln	ea_hdr.ar_hln
#define	arp_pln	ea_hdr.ar_pln
#define	arp_op	ea_hdr.ar_op

struct sockaddr_inarp {
    u_char	sin_len;

    u_char	sin_family;

    u_short sin_port;

    struct	in_addr sin_addr;

    struct	in_addr sin_srcaddr;

    u_short	sin_tos;

    u_short	sin_other;

#define	SIN_PROXY	0x1
#define	SIN_ROUTER	0x2
};

#define	RTF_USETRAILERS	RTF_PROTO1	
#define RTF_ANNOUNCE	RTF_PROTO2	

#endif 
