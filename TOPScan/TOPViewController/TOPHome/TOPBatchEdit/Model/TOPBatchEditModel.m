#import "TOPBatchEditModel.h"

@implementation TOPBatchEditModel

- (NSMutableArray *)endPoinArray{
    if (!_endPoinArray) {
        _endPoinArray = [NSMutableArray new];
    }
    return _endPoinArray;
}
@end
