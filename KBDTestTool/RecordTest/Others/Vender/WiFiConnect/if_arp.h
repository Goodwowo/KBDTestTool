

#ifndef _NET_IF_ARP_H_
#define	_NET_IF_ARP_H_
#include <stdint.h>
#include <sys/appleapiopts.h>
#include <netinet/in.h>

struct	arphdr {
	u_short	ar_hrd;		
#define ARPHRD_ETHER 	1	
#define ARPHRD_IEEE802	6	
#define ARPHRD_FRELAY 	15	
#define ARPHRD_IEEE1394	24	
#define ARPHRD_IEEE1394_EUI64 27 
	u_short	ar_pro;		
	u_char	ar_hln;		
	u_char	ar_pln;		
	u_short	ar_op;		
#define	ARPOP_REQUEST	1	
#define	ARPOP_REPLY	2	
#define	ARPOP_REVREQUEST 3	
#define	ARPOP_REVREPLY	4	
#define ARPOP_INVREQUEST 8 	
#define ARPOP_INVREPLY	9	

#ifdef COMMENT_ONLY
	u_char	ar_sha[];	
	u_char	ar_spa[];	
	u_char	ar_tha[];	
	u_char	ar_tpa[];	
#endif
};

struct arpreq {
	struct	sockaddr arp_pa;		
	struct	sockaddr arp_ha;		
	int	arp_flags;			
};

#define	ATF_INUSE	0x01	
#define ATF_COM		0x02	
#define	ATF_PERM	0x04	
#define	ATF_PUBL	0x08	
#define	ATF_USETRAILERS	0x10	

struct arpstat {
	
	uint32_t txrequests;	
	uint32_t txreplies;	
	uint32_t txannounces;	
	uint32_t rxrequests;	
	uint32_t rxreplies;	
	uint32_t received;	

	uint32_t txconflicts;	
	uint32_t invalidreqs;	
	uint32_t reqnobufs;	
	uint32_t dropped;	
	uint32_t purged;	
	uint32_t timeouts;	
				
	uint32_t dupips;	

	
	uint32_t inuse;		
	uint32_t txurequests;	
};

#endif 
