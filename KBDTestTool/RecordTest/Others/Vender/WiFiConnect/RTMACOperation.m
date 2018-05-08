
#import "RTMACOperation.h"
#import "RTLANProperties.h"
#import "RTMacFinder.h"
#import "RTDeviceModel.h"

@interface RTMACOperation ()
@property (nonatomic,strong) NSString *ipStr;
@property (nonatomic, copy) void (^result)(NSError  * _Nullable error, NSString  * _Nonnull ip,RTDeviceModel * _Nonnull device);
@property(nonatomic,strong)RTDeviceModel *device;
@property(nonatomic,weak)NSDictionary *brandDictionary;
@end

@interface RTMACOperation()
- (void)finish;
@end

@implementation RTMACOperation {

    NSError *errorMessage;
}

-(instancetype)initWithIPToRetrieveMAC:(NSString*)ip andBrandDictionary:(NSDictionary*)brandDictionary andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip,RTDeviceModel * _Nonnull device))result;{

    self = [super init];
    
    if (self) {
        
        self.device = [[RTDeviceModel alloc]init];
        self.name = ip;
        self.ipStr= ip;
        self.result = result;
        self.brandDictionary=brandDictionary;
        _isExecuting = NO;
        _isFinished = NO;

    }
    
    return self;
}

-(void)start {

    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    [self getMACDetails];
}
-(void)finishMAC {
   
    if (self.isCancelled) {
        [self finish];
        return;
    }
    
    if (self.result) {
        self.result(errorMessage,self.name,self.device);
    }

    [self finish];
}

-(void)finish {
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

#pragma mark - Ping Result callback
-(void)getMACDetails{
    
    self.device.ipAddress=self.ipStr;
    self.device.macAddress =[[RTMacFinder ip2mac:self.device.ipAddress] uppercaseString];
    self.device.hostname = [RTLANProperties getHostFromIPAddress:self.ipStr];
    
    if (!self.device.macAddress) {
 
        errorMessage = [NSError errorWithDomain:@"MAC Address Not Exist" code:10 userInfo:nil];
    }
    else {
        self.device.brand = [self.brandDictionary objectForKey:[[self.device.macAddress substringWithRange:NSMakeRange(0, 8)] stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
    }

    [self finishMAC];
}

@end
