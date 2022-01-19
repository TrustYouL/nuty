#import "TOPSuggestionModel.h"

@implementation TOPSuggestionModel

- (NSMutableArray *)picArray{
    if (!_picArray) {
        _picArray = [NSMutableArray new];
    }
    return _picArray;
}
@end
