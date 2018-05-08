 

#import "RTSimplePing.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>

#pragma mark * ICMP On-The-Wire Format

static uint16_t in_cksum(const void *buffer, size_t bufferLen)
{
	size_t              bytesLeft;
    int32_t             sum;
	const uint16_t *    cursor;
	union {
		uint16_t        us;
		uint8_t         uc[2];
	} last;
	uint16_t            answer;

	bytesLeft = bufferLen;
	sum = 0;
	cursor = buffer;

	
	while (bytesLeft > 1) {
		sum += *cursor;
        cursor += 1;
		bytesLeft -= 2;
	}

	
	if (bytesLeft == 1) {
		last.uc[0] = * (const uint8_t *) cursor;
		last.uc[1] = 0;
		sum += last.us;
	}

	
	sum = (sum >> 16) + (sum & 0xffff);	
	sum += (sum >> 16);			
	answer = (uint16_t) ~sum;   

	return answer;
}

#pragma mark * RTSimplePing

@interface RTSimplePing ()

@property (nonatomic, copy,   readwrite) NSData *           hostAddress;
@property (nonatomic, assign, readwrite) uint16_t           nextSequenceNumber;

- (void)stopHostResolution;
- (void)stopDataTransfer;

@end

@implementation RTSimplePing
{
    CFHostRef               _host;
    CFSocketRef             _socket;
}

@synthesize hostName           = _hostName;
@synthesize hostAddress        = _hostAddress;

@synthesize delegate           = _delegate;
@synthesize identifier         = _identifier;
@synthesize nextSequenceNumber = _nextSequenceNumber;

- (id)initWithHostName:(NSString *)hostName address:(NSData *)hostAddress
{
    assert( (hostName != nil) == (hostAddress == nil) );
    self = [super init];
    if (self != nil) {
        self->_hostName    = [hostName copy];
        self->_hostAddress = [hostAddress copy];
        self->_identifier  = (uint16_t) arc4random();
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    assert(self->_host == NULL);
    assert(self->_socket == NULL);
}

+ (RTSimplePing *)simplePingWithHostName:(NSString *)hostName
{
    return [[RTSimplePing alloc] initWithHostName:hostName address:nil];
}

+ (RTSimplePing *)simplePingWithHostAddress:(NSData *)hostAddress
{
    return [[RTSimplePing alloc] initWithHostName:NULL address:hostAddress];
}

- (void)noop
{
}

- (void)didFailWithError:(NSError *)error
{
    assert(error != nil);
    
    
    [self performSelector:@selector(noop) withObject:nil afterDelay:0.0];
    
    [self stop];
    if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(simplePing:didFailWithError:)] ) {
        [self.delegate simplePing:self didFailWithError:error];
    }
}

- (void)didFailWithHostStreamError:(CFStreamError)streamError
{
    NSDictionary *  userInfo;
    NSError *       error;

    if (streamError.domain == kCFStreamErrorDomainNetDB) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:streamError.error], kCFGetAddrInfoFailureKey,
            nil
        ];
    } else {
        userInfo = nil;
    }
    error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorUnknown userInfo:userInfo];
    assert(error != nil);

    [self didFailWithError:error];
}

- (void)sendPingWithData:(NSData *)data
{
    int             err;
    NSData *        payload;
    NSMutableData * packet;
    RTICMPHeader *    icmpPtr;
    ssize_t         bytesSent;
    
    
    payload = data;
    if (payload == nil) {
        payload = [[NSString stringWithFormat:@"%28zd bottles of beer on the wall", (ssize_t) 99 - (size_t) (self.nextSequenceNumber % 100) ] dataUsingEncoding:NSASCIIStringEncoding];
        assert(payload != nil);
        
        assert([payload length] == 56);
    }
    
    packet = [NSMutableData dataWithLength:sizeof(*icmpPtr) + [payload length]];
    assert(packet != nil);

    icmpPtr = [packet mutableBytes];
    icmpPtr->type = kICMPTypeEchoRequest;
    icmpPtr->code = 0;
    icmpPtr->checksum = 0;
    icmpPtr->identifier     = OSSwapHostToBigInt16(self.identifier);
    icmpPtr->sequenceNumber = OSSwapHostToBigInt16(self.nextSequenceNumber);
    memcpy(&icmpPtr[1], [payload bytes], [payload length]);
    
    
    icmpPtr->checksum = in_cksum([packet bytes], [packet length]);
    
    CFSocketNativeHandle sock = CFSocketGetNative(self->_socket);
    struct timeval tv;
    tv.tv_sec  = 0;
    tv.tv_usec = 10000; 
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (void *)&tv, sizeof(tv));
    
    
    if (self->_socket == NULL) {
        bytesSent = -1;
        err = EBADF;
    } else {
        bytesSent = sendto(
            CFSocketGetNative(self->_socket),
            [packet bytes],
            [packet length], 
            0, 
            (struct sockaddr *) [self.hostAddress bytes], 
            (socklen_t) [self.hostAddress length]
        );
        err = 0;
        if (bytesSent < 0) {
            err = errno;
        }
    }

    
    if ( (bytesSent > 0) && (((NSUInteger) bytesSent) == [packet length]) ) {


        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(simplePing:didSendPacket:)] ) {
            [self.delegate simplePing:self didSendPacket:packet];
        }
    } else {
        NSError *   error;
        
        
        if (err == 0) {
            err = ENOBUFS;          
        }
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil];
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(simplePing:didFailToSendPacket:error:)] ) {
            [self.delegate simplePing:self didFailToSendPacket:packet error:error];
        }
    }
    
    self.nextSequenceNumber += 1;
}

+ (NSUInteger)RTICMPHeaderOffsetInPacket:(NSData *)packet
{
    NSUInteger              result;
    const struct RTIPHeader * ipPtr;
    size_t                  RTIPHeaderLength;
    
    result = NSNotFound;
    if ([packet length] >= (sizeof(RTIPHeader) + sizeof(RTICMPHeader))) {
        ipPtr = (const RTIPHeader *) [packet bytes];
        assert((ipPtr->versionAndHeaderLength & 0xF0) == 0x40);     
        assert(ipPtr->protocol == 1);                               
        RTIPHeaderLength = (ipPtr->versionAndHeaderLength & 0x0F) * sizeof(uint32_t);
        if ([packet length] >= (RTIPHeaderLength + sizeof(RTICMPHeader))) {
            result = RTIPHeaderLength;
        }
    }
    return result;
}

+ (const struct RTICMPHeader *)icmpInPacket:(NSData *)packet
{
    const struct RTICMPHeader *   result;
    NSUInteger                  RTICMPHeaderOffset;
    
    result = nil;
    RTICMPHeaderOffset = [self RTICMPHeaderOffsetInPacket:packet];
    if (RTICMPHeaderOffset != NSNotFound) {
        result = (const struct RTICMPHeader *) (((const uint8_t *)[packet bytes]) + RTICMPHeaderOffset);
    }
    return result;
}

- (BOOL)isValidPingResponsePacket:(NSMutableData *)packet
{
    BOOL                result;
    NSUInteger          RTICMPHeaderOffset;
    RTICMPHeader *        icmpPtr;
    uint16_t            receivedChecksum;
    uint16_t            calculatedChecksum;
    
    result = NO;
    
    RTICMPHeaderOffset = [[self class] RTICMPHeaderOffsetInPacket:packet];
    if (RTICMPHeaderOffset != NSNotFound) {
        icmpPtr = (struct RTICMPHeader *) (((uint8_t *)[packet mutableBytes]) + RTICMPHeaderOffset);

        receivedChecksum   = icmpPtr->checksum;
        icmpPtr->checksum  = 0;
        calculatedChecksum = in_cksum(icmpPtr, [packet length] - RTICMPHeaderOffset);
        icmpPtr->checksum  = receivedChecksum;
        
        if (receivedChecksum == calculatedChecksum) {
            if ( (icmpPtr->type == kICMPTypeEchoReply) && (icmpPtr->code == 0) ) {
                if ( OSSwapBigToHostInt16(icmpPtr->identifier) == self.identifier ) {
                    if ( OSSwapBigToHostInt16(icmpPtr->sequenceNumber) < self.nextSequenceNumber ) {
                        result = YES;
                    }
                }
            }
        }
    }

    return result;
}

- (void)readData
{
    int                     err;
    struct sockaddr_storage addr;
    socklen_t               addrLen;
    ssize_t                 bytesRead;
    void *                  buffer;
    enum { kBufferSize = 65535 };

    
    buffer = malloc(kBufferSize);
    assert(buffer != NULL);
    
    
    addrLen = sizeof(addr);
    bytesRead = recvfrom(CFSocketGetNative(self->_socket), buffer, kBufferSize, 0, (struct sockaddr *) &addr, &addrLen);
    err = 0;
    if (bytesRead < 0) {
        err = errno;
    }
    
    
    if (bytesRead > 0) {
        NSMutableData *     packet;

        packet = [NSMutableData dataWithBytes:buffer length:(NSUInteger) bytesRead];
        assert(packet != nil);


        if ( [self isValidPingResponsePacket:packet] ) {
            if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(simplePing:didReceivePingResponsePacket:)] ) {
                [self.delegate simplePing:self didReceivePingResponsePacket:packet];
            }
        } else {
            if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(simplePing:didReceiveUnexpectedPacket:)] ) {
                [self.delegate simplePing:self didReceiveUnexpectedPacket:packet];
            }
        }
    } else {
    
        
        if (err == 0) {
            err = EPIPE;
        }
        [self didFailWithError:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
    }
    
    free(buffer);
    
}

static void SocketReadCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    RTSimplePing *    obj;
    
    obj = (__bridge RTSimplePing *) info;
    assert([obj isKindOfClass:[RTSimplePing class]]);
    
    #pragma unused(s)
    assert(s == obj->_socket);
    #pragma unused(type)
    assert(type == kCFSocketReadCallBack);
    #pragma unused(address)
    assert(address == nil);
    #pragma unused(data)
    assert(data == nil);
    
    [obj readData];
}

- (void)startWithHostAddress
{
    int                     err;
    int                     fd;
    const struct sockaddr * addrPtr;

    assert(self.hostAddress != nil);

    
    addrPtr = (const struct sockaddr *) [self.hostAddress bytes];

    fd = -1;
    err = 0;
    switch (addrPtr->sa_family) {
        case AF_INET: {
            fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
            if (fd < 0) {
                err = errno;
            }
        } break;
        case AF_INET6:
            assert(NO);
        default: {
            err = EPROTONOSUPPORT;
        } break;
    }
    
    if (err != 0) {
        [self didFailWithError:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
    } else {
        CFSocketContext     context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        CFRunLoopSourceRef  rls;
        
        
        self->_socket = CFSocketCreateWithNative(NULL, fd, kCFSocketReadCallBack, SocketReadCallback, &context);
        assert(self->_socket != NULL);
        
        
        assert( CFSocketGetSocketFlags(self->_socket) & kCFSocketCloseOnInvalidate );
        fd = -1;
        
        rls = CFSocketCreateRunLoopSource(NULL, self->_socket, 0);
        assert(rls != NULL);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
        
        CFRelease(rls);

        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(simplePing:didStartWithAddress:)] ) {
            [self.delegate simplePing:self didStartWithAddress:self.hostAddress];
        }
    }
    assert(fd == -1);
}

- (void)hostResolutionDone
{
    Boolean     resolved;
    NSArray *   addresses;
    
    
    addresses = (__bridge NSArray *) CFHostGetAddressing(self->_host, &resolved);
    if ( resolved && (addresses != nil) ) {
        resolved = false;
        for (NSData * address in addresses) {
            const struct sockaddr * addrPtr;
            
            addrPtr = (const struct sockaddr *) [address bytes];
            if ( [address length] >= sizeof(struct sockaddr) && addrPtr->sa_family == AF_INET) {
                self.hostAddress = address;
                resolved = true;
                break;
            }
        }
    }

    
    [self stopHostResolution];
    
    
    if (resolved) {
        [self startWithHostAddress];
    } else {
        [self didFailWithError:[NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorHostNotFound userInfo:nil]];
    }
}

static void HostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
{
    RTSimplePing *    obj;

    
    obj = (__bridge RTSimplePing *) info;
    assert([obj isKindOfClass:[RTSimplePing class]]);
    
    #pragma unused(theHost)
    assert(theHost == obj->_host);
    #pragma unused(typeInfo)
    assert(typeInfo == kCFHostAddresses);
    
    if ( (error != NULL) && (error->domain != 0) ) {
        [obj didFailWithHostStreamError:*error];
    } else {
        [obj hostResolutionDone];
    }
}

- (void)start
{
    
    if (self->_hostAddress != nil) {
        [self startWithHostAddress];
    } else {
        Boolean             success;
        CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        CFStreamError       streamError;

        assert(self->_host == NULL);

        self->_host = CFHostCreateWithName(NULL, (__bridge CFStringRef) self.hostName);
        assert(self->_host != NULL);
        
        CFHostSetClient(self->_host, HostResolveCallback, &context);
        
        CFHostScheduleWithRunLoop(self->_host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        success = CFHostStartInfoResolution(self->_host, kCFHostAddresses, &streamError);
        if ( ! success ) {
            [self didFailWithHostStreamError:streamError];
        }
    }
}

- (void)stopHostResolution
{
    if (self->_host != NULL) {
        CFHostSetClient(self->_host, NULL, NULL);
        CFHostUnscheduleFromRunLoop(self->_host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(self->_host);
        self->_host = NULL;
    }
}

- (void)stopDataTransfer   
{
    if (self->_socket != NULL) {
        CFSocketInvalidate(self->_socket);
        CFRelease(self->_socket);
        self->_socket = NULL;
    }
}

- (void)stop
{
    [self stopHostResolution];
    [self stopDataTransfer];
    
    if (self.hostName != nil) {
        self.hostAddress = NULL;
    }
}

@end
