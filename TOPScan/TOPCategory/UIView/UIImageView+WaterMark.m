#import "UIImageView+WaterMark.h"
#import "TOPWaterMark.h"

@implementation UIImageView (WaterMark)

- (instancetype)initWithFrame:(CGRect)frame withText:(NSString *)text withBgImage:(UIImage *)bgImg {
    if (self = [super initWithFrame:frame]) {
        self.alpha = TOP_TRSSWatermarkOpacity;
        if (!bgImg) {
            bgImg = [UIImage imageNamed:@""];
        }
        self.image = [TOPWaterMark view:self WaterImageWithImage:bgImg text:text];
    }
    return self;
}

@end
