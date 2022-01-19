#import "TOPCoverView.h"

@implementation TOPCoverView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.top_touchToHide) {
        self.top_touchToHide();
    }
}

@end
