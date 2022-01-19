#import "TOPScameraBatchSave.h"

@implementation TOPScameraBatchSave
static TOPScameraBatchSave *instance = nil;

+ (instancetype)save{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TOPScameraBatchSave alloc] init]; 
    });
    return instance;
}
@end
