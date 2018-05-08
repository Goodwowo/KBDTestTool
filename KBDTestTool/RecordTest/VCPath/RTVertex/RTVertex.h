
#import <Foundation/Foundation.h>
#import "ZHRepearDictionary.h"

@interface RTVertex : NSObject

+ (RTVertex *)shareInstance;
@property (nonatomic,strong)ZHRepearDictionary *repearDictionary;

+ (void)dijkstraPath:(NSArray *)paths from:(NSString *)from;
+ (NSArray *)shortestPath:(NSArray *)paths from:(NSString *)from to:(NSString *)to;
+ (NSArray *)allShortestPath:(NSArray *)paths from:(NSString *)from;

@end
