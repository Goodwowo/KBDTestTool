

#import <Foundation/Foundation.h>

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <CFNetwork/CFNetwork.h>
#else
#import <CoreServices/CoreServices.h>
#endif

#include <AssertMacros.h>

#pragma mark* RTSimplePing

@protocol SimplePingDelegate;

@interface RTSimplePing : NSObject

+ (RTSimplePing*)simplePingWithHostName:(NSString*)hostName;
+ (RTSimplePing*)simplePingWithHostAddress:(NSData*)hostAddress;

@property (nonatomic, weak, readwrite) id<SimplePingDelegate> delegate;

@property (nonatomic, copy, readonly) NSString* hostName;

@property (nonatomic, copy, readonly) NSData* hostAddress;

@property (nonatomic, assign, readonly) uint16_t identifier;

@property (nonatomic, assign, readonly) uint16_t nextSequenceNumber;

- (void)start;

- (void)sendPingWithData:(NSData*)data;

- (void)stop;

+ (const struct RTICMPHeader*)icmpInPacket:(NSData*)packet;

@end

@protocol SimplePingDelegate <NSObject>

@optional

- (void)simplePing:(RTSimplePing*)pinger didStartWithAddress:(NSData*)address;

- (void)simplePing:(RTSimplePing*)pinger didFailWithError:(NSError*)error;

- (void)simplePing:(RTSimplePing*)pinger didSendPacket:(NSData*)packet;

- (void)simplePing:(RTSimplePing*)pinger didFailToSendPacket:(NSData*)packet error:(NSError*)error;

- (void)simplePing:(RTSimplePing*)pinger didReceivePingResponsePacket:(NSData*)packet;

- (void)simplePing:(RTSimplePing*)pinger didReceiveUnexpectedPacket:(NSData*)packet;

@end

#pragma mark* IP and ICMP On-The-Wire Format

struct RTIPHeader {
    uint8_t versionAndHeaderLength;

    uint8_t differentiatedServices;

    uint16_t totalLength;

    uint16_t identification;

    uint16_t flagsAndFragmentOffset;

    uint8_t timeToLive;

    uint8_t protocol;

    uint16_t headerChecksum;

    uint8_t sourceAddress[4];

    uint8_t destinationAddress[4];
};

typedef struct RTIPHeader RTIPHeader;

enum {
    kICMPTypeEchoReply = 0,
    kICMPTypeEchoRequest = 8
};

struct RTICMPHeader {
    uint8_t type;

    uint8_t code;

    uint16_t checksum;

    uint16_t identifier;

    uint16_t sequenceNumber;
};

typedef struct RTICMPHeader RTICMPHeader;
