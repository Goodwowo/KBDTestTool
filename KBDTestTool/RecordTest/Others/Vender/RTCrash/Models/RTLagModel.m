
#import "RTLagModel.h"

@implementation RTLagModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.lagStack forKey:@"lagStack"];
    [aCoder encodeObject:self.imagePath forKey:@"imagePath"];
    [aCoder encodeObject:self.vcStack forKey:@"vcStack"];
    [aCoder encodeObject:self.operationStack forKey:@"operationStack"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.lagStack = [aDecoder decodeObjectForKey:@"lagStack"];
        self.imagePath = [aDecoder decodeObjectForKey:@"imagePath"];
        self.vcStack = [aDecoder decodeObjectForKey:@"vcStack"];
        self.operationStack = [aDecoder decodeObjectForKey:@"operationStack"];
    }
    return self;
}

@end
