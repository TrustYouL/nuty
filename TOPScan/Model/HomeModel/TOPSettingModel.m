#import "TOPSettingModel.h"

@implementation TOPSettingModel

- (CGFloat)cellHeight {
    _cellHeight = 60;
    if (self.myContent.length > 0) {
        CGSize labSize = [TOPDocumentHelper top_getSizeWithStr:self.myContent Width:TOPScreenWidth-100 Font:14];
        _cellHeight = labSize.height + 60+8;
    }
    return _cellHeight;
}

@end
