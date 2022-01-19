#import "TOPEditPDFModel.h"

@implementation SSPDFSignaturePic
- (instancetype)initWithImage:(UIImage *)img imgRect:(CGRect)imgRect {
    self = [super init];
    if (self) {
        self.img = img;
        self.picRect = imgRect;
        self.enabledInteraction = YES;
    }
    return self;
}

@end

@implementation TOPEditPDFModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.picArr = @[].mutableCopy;
    }
    return self;
}

@end
