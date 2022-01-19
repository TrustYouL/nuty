

#import "TOPDocTag.h"

@implementation TOPDocTag
//主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置属性默认值
+ (NSDictionary *)defaultPropertyValues{
    return @{@"tagType":@1, @"tagColor":@1};
}

//设置忽略属性,即不存到realm数据库中
+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"filePath"];
}

- (NSString *)filePath {
    NSString *filePaht = [[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString] stringByAppendingPathComponent:self.name];
    return filePaht;
}

@end
