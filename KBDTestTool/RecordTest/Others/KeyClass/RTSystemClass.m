
#import "RTSystemClass.h"
#import <objc/runtime.h>

@interface RTSystemClass ()
@property (nonatomic,strong)NSMutableArray *defineClass;
@property (nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation RTSystemClass

+ (RTSystemClass*)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTSystemClass* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTSystemClass alloc] init];
        _sharedObject.defineClass = [NSMutableArray array];
    });
    return _sharedObject;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        NSString *filePath=[[NSBundle mainBundle]pathForResource:@"systemClass.plist" ofType:nil];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            _dataArr=[NSMutableArray arrayWithContentsOfFile:filePath];
        }else{
//            NSLog(@"%@",@"没有找到系统所有类的plist文件");
            _dataArr=[NSMutableArray array];
        }
    }
    return _dataArr;
}

////判断某类（cls）是否为指定类（acls）的子类
static BOOL rtsc_isKindOfClass(Class cls, Class acls) {
    Class scls = class_getSuperclass(cls);
    if (scls==acls) {
        return true;
    } else if (scls==nil) {
        return false;
    }
    return rtsc_isKindOfClass(scls, acls);
}

- (NSArray *)getNoSystemClass{
    if (self.defineClass.count>0) {
        return self.defineClass;
    }
//    NSLog(@"%@",@"开始");
    //获取所有的已注册的类
    int count=objc_getClassList(NULL, 0);
    if (!count) return nil;
    [self.defineClass removeAllObjects];
    
    //分配存储内存
    Class objc=nil;
    Class *classes=(Class*)malloc(sizeof(Class)*count);
    
    //将已注册的类定义复制到classes的内存中
    objc_getClassList(classes, count);
    for (int i=0; i<count; i++) {
        objc=classes[i];
        if (objc == NULL) {
            continue;
        }
        if(![self Search:NSStringFromClass(objc)]){
            if (![self isSystemClass:objc]) {
                if (rtsc_isKindOfClass(objc, [UIViewController class]) || rtsc_isKindOfClass(objc, [UIView class])) {
                    [self.defineClass addObject:NSStringFromClass(objc)];
                }
            }
        }
    }
    //筛选自定义类
    free(classes);
//    NSLog(@"%@",@"检查工程里面的所有自定义类--完成");
    
    return self.defineClass;
}

- (BOOL)isSystemClass:(Class)cls{
    return [NSBundle bundleForClass:cls] != [NSBundle mainBundle];
}

- (void)saveSystemClass{
    
    //获取所有的已注册的类
    int count=objc_getClassList(NULL, 0);
    if (!count) {
        return;
    }
    
    //分配存储内存
    Class objc=nil;
    Class *classes=(Class*)malloc(sizeof(Class)*count);
    
    //将已注册的类定义复制到classes的内存中
    objc_getClassList(classes, count);
    for (int i=0; i<count; i++) {
        objc=classes[i];
        if (objc == NULL) {
            continue;
        }
        NSString *className=NSStringFromClass(objc);
        [self binaryInsert_New:className];
    }
    
    NSString *filePath=@"/Users/mac/Desktop/systemClass.plist";
    
    [self.dataArr writeToFile:filePath atomically:YES];
    
    //筛选自定义类
    free(classes);
//    NSLog(@"%@",@"保存系统工的所有类--完成");
}
- (void)saveSystemClassArr:(NSArray *)systemClassArr{
    
    for (NSString *systemClass in systemClassArr) {
        if (systemClass.length>0) {
            [self binaryInsert_New:systemClass];
        }
    }
    
    NSString *filePath=@"/Users/mac/Desktop/systemClass.plist";
    
    [self.dataArr writeToFile:filePath atomically:YES];
    
//    NSLog(@"%@",@"保存自定义类系统的类--完成");
}

/**二分查找(判断是不是白名单)*/
- (BOOL)Search:(NSString *)target{
    
    NSInteger low=0;
    NSInteger high=self.dataArr.count-1;
    
    while(low<=high){
        
        NSInteger middle=(high+low)/2;
        NSInteger outcome=[self compare:self.dataArr[middle] target:target];
        if(outcome==0){
            return YES;
        }else if(outcome==-1){
            high=middle-1;
        }else if(outcome==1){
            low=middle+1;
        }else if(outcome==-2){
            return NO;
        }
    }
    
    return NO;
}

//二分插入
- (NSInteger)compare:(NSString *)url target:(NSString *)target{
    NSComparisonResult result=[url compare:target];
    if (result==NSOrderedAscending) {
        return 1;
    }
    if (result==NSOrderedSame) {
        return 0;
    }
    if (result==NSOrderedDescending) {
        return -1;
    }
    return 0;
}

- (BOOL)binaryInsert_New:(NSString *)target{
    
    if (self.dataArr.count==0) {
        [self.dataArr addObject:target];
        return YES;
    }
    
    NSInteger low=0;
    
    NSInteger high=self.dataArr.count-1;
    
    NSInteger insertIndex=0;
    NSInteger lastCompare=0;
    
    NSInteger middle=0;
    
    while(low<=high){
        
        middle=(high+low)/2;
        NSInteger outcome=[self compare:self.dataArr[middle] target:target];
        if(outcome==0){
            return NO;
        }else if(outcome==-1){
            high=middle-1;
            lastCompare=-1;
            insertIndex=high;
        }else{
            low=middle+1;
            insertIndex=low;
            lastCompare=1;
        }
    }
    
    if(lastCompare==-1)insertIndex++;
    [self.dataArr insertObject:target atIndex:insertIndex];
    
    return YES;
}

@end
