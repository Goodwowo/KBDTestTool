
#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR

#else
#include "route.h"
#endif

#include "if_ether.h"
#include <arpa/inet.h>

@interface RTMacFinder : NSObject

+ (NSString*)ip2mac:(NSString*)strIP;

@end
