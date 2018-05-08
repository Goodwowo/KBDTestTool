
#ifndef _NET_ROUTE_H_
#define	_NET_ROUTE_H_
#include <sys/appleapiopts.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/socket.h>

#if TARGET_IPHONE_SIMULATOR
#else
struct rt_metrics {
	u_int32_t	rmx_locks;	
	u_int32_t	rmx_mtu;	
	u_int32_t	rmx_hopcount;	
	int32_t		rmx_expire;	
	u_int32_t	rmx_recvpipe;	
	u_int32_t	rmx_sendpipe;	
	u_int32_t	rmx_ssthresh;	
	u_int32_t	rmx_rtt;	
	u_int32_t	rmx_rttvar;	
	u_int32_t	rmx_pksent;	
	u_int32_t	rmx_filler[4];	
};

#endif

#define	RTM_RTTUNIT	1000000	

#define	RTF_UP		0x1		
#define	RTF_GATEWAY	0x2		
#define	RTF_HOST	0x4		
#define	RTF_REJECT	0x8		
#define	RTF_DYNAMIC	0x10		
#define	RTF_MODIFIED	0x20		
#define	RTF_DONE	0x40		
#define	RTF_DELCLONE	0x80		
#define	RTF_CLONING	0x100		
#define	RTF_XRESOLVE	0x200		
#define	RTF_LLINFO	0x400		
#define	RTF_STATIC	0x800		
#define	RTF_BLACKHOLE	0x1000		
#define	RTF_NOIFREF	0x2000		
#define	RTF_PROTO2	0x4000		
#define	RTF_PROTO1	0x8000		

#define	RTF_PRCLONING	0x10000		
#define	RTF_WASCLONED	0x20000		
#define	RTF_PROTO3	0x40000		
					
#define	RTF_PINNED	0x100000	
#define	RTF_LOCAL	0x200000	
#define	RTF_BROADCAST	0x400000	
#define	RTF_MULTICAST	0x800000	
#define	RTF_IFSCOPE	0x1000000	
#define	RTF_CONDEMNED	0x2000000	
#define	RTF_IFREF	0x4000000	
#define	RTF_PROXY	0x8000000	
#define	RTF_ROUTER	0x10000000	

#define	RTF_BITS \
	"\020\1UP\2GATEWAY\3HOST\4REJECT\5DYNAMIC\6MODIFIED\7DONE" \
	"\10DELCLONE\11CLONING\12XRESOLVE\13LLINFO\14STATIC\15BLACKHOLE" \
	"\16NOIFREF\17PROTO2\20PROTO1\21PRCLONING\22WASCLONED\23PROTO3" \
	"\25PINNED\26LOCAL\27BROADCAST\30MULTICAST\31IFSCOPE\32CONDEMNED" \
	"\33IFREF\34PROXY\35ROUTER"

#if TARGET_IPHONE_SIMULATOR
#else
struct	rtstat {
	short	rts_badredirect;	
	short	rts_dynamic;		
	short	rts_newgateway;		
	short	rts_unreach;		
	short	rts_wildcard;		
};

#endif

#if TARGET_IPHONE_SIMULATOR
#else
struct rt_msghdr {
	u_short	rtm_msglen;	
	u_char	rtm_version;	
	u_char	rtm_type;	
	u_short	rtm_index;	
	int	rtm_flags;	
	int	rtm_addrs;	
	pid_t	rtm_pid;	
	int	rtm_seq;	
	int	rtm_errno;	
	int	rtm_use;	
	u_int32_t rtm_inits;	
	struct rt_metrics rtm_rmx; 
};

#endif

#if TARGET_IPHONE_SIMULATOR
#else
struct rt_msghdr2 {
	u_short	rtm_msglen;	
	u_char	rtm_version;	
	u_char	rtm_type;	
	u_short	rtm_index;	
	int	rtm_flags;	
	int	rtm_addrs;	
	int32_t	rtm_refcnt;	
	int	rtm_parentflags; 
	int	rtm_reserved;	
	int	rtm_use;	
	u_int32_t rtm_inits;	
	struct rt_metrics rtm_rmx; 
};

#endif

#define	RTM_VERSION	5	

#define	RTM_ADD		0x1	
#define	RTM_DELETE	0x2	
#define	RTM_CHANGE	0x3	
#define	RTM_GET		0x4	
#define	RTM_LOSING	0x5	
#define	RTM_REDIRECT	0x6	
#define	RTM_MISS	0x7	
#define	RTM_LOCK	0x8	
#define	RTM_OLDADD	0x9	
#define	RTM_OLDDEL	0xa	
#define	RTM_RESOLVE	0xb	
#define	RTM_NEWADDR	0xc	
#define	RTM_DELADDR	0xd	
#define	RTM_IFINFO	0xe	
#define	RTM_NEWMADDR	0xf	
#define	RTM_DELMADDR	0x10	
#define	RTM_IFINFO2	0x12	
#define	RTM_NEWMADDR2	0x13	
#define	RTM_GET2	0x14	

#define	RTV_MTU		0x1	
#define	RTV_HOPCOUNT	0x2	
#define	RTV_EXPIRE	0x4	
#define	RTV_RPIPE	0x8	
#define	RTV_SPIPE	0x10	
#define	RTV_SSTHRESH	0x20	
#define	RTV_RTT		0x40	
#define	RTV_RTTVAR	0x80	

#define	RTA_DST		0x1	
#define	RTA_GATEWAY	0x2	
#define	RTA_NETMASK	0x4	
#define	RTA_GENMASK	0x8	
#define	RTA_IFP		0x10	
#define	RTA_IFA		0x20	
#define	RTA_AUTHOR	0x40	
#define	RTA_BRD		0x80	

#define	RTAX_DST	0	
#define	RTAX_GATEWAY	1	
#define	RTAX_NETMASK	2	
#define	RTAX_GENMASK	3	
#define	RTAX_IFP	4	
#define	RTAX_IFA	5	
#define	RTAX_AUTHOR	6	
#define	RTAX_BRD	7	
#define	RTAX_MAX	8	

#if TARGET_IPHONE_SIMULATOR
#else
struct rt_addrinfo {
	int	rti_addrs;
	struct	sockaddr *rti_info[RTAX_MAX];
};

#endif

#endif 
