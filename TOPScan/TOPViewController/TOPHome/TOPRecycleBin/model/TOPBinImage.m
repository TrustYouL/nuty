#import "TOPBinImage.h"

@implementation TOPBinImage

//主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置忽略属性,即不存到realm数据库中
+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"filePath", @"name"];
}

- (NSString *)picIndex {
    NSString *picIndex = [TOPDocumentHelper top_picSortNO:self.fileName];
    return picIndex;
}

@end
