
#import "RTCrashModel.h"

@implementation RTCrashModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.crashStack forKey:@"crashStack"];
    [aCoder encodeObject:self.imagePath forKey:@"imagePath"];
    [aCoder encodeObject:self.vcStack forKey:@"vcStack"];
    [aCoder encodeObject:self.operationStack forKey:@"operationStack"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.crashStack = [aDecoder decodeObjectForKey:@"crashStack"];
        self.imagePath = [aDecoder decodeObjectForKey:@"imagePath"];
        self.vcStack = [aDecoder decodeObjectForKey:@"vcStack"];
        self.operationStack = [aDecoder decodeObjectForKey:@"operationStack"];
    }
    return self;
}

@end
