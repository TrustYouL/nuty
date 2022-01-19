#import "TOPBinFolder.h"

@implementation TOPBinFolder

//主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置忽略属性,即不存到realm数据库中
+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"filePath"];
}


@end
