
#import "TOPAPPFolder.h"

@implementation TOPAPPFolder

//主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置属性默认值
+ (NSDictionary *)defaultPropertyValues{
    return @{@"isDelete":@0};
}

//设置忽略属性,即不存到realm数据库中
+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"filePath"];
}


@end
