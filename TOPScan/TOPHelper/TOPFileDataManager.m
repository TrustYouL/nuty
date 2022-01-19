#import "TOPFileDataManager.h"

@implementation TOPFileDataManager

//单例初始化
+ (instancetype)shareInstance {
    static TOPFileDataManager *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPFileDataManager alloc] init];
    });
    return singleTon;
}

- (NSMutableArray *)folderPaths {
    if (!_folderPaths) {
        _folderPaths = @[].mutableCopy;
    }
    return _folderPaths;
}

- (NSMutableArray *)docPaths {
    if (!_docPaths) {
        _docPaths = @[].mutableCopy;
    }
    return _docPaths;
}

@end
