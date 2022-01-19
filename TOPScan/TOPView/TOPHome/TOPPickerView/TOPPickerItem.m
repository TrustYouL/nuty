#import "TOPPickerItem.h"

@implementation TOPPickerItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTapGesture];
    }
    return self;
}

- (void)addTapGesture {
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
}

- (void)tap {
    if (self.PickerItemSelectBlock) {
        self.PickerItemSelectBlock(self.index);
    }
}

- (void)changeSizeOfItem {
    
}

- (void)backSizeOfItem {
    
}

@end
