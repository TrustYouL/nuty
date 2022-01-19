#import "TOPCameraBatchModel.h"

@implementation TOPCameraBatchModel

- (NSMutableDictionary *)filterSaveDic{
    if (!_filterSaveDic) {
        _filterSaveDic = [NSMutableDictionary new];
    }
    return _filterSaveDic;
}

@end
