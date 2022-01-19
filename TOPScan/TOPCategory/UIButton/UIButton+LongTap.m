#import "UIButton+LongTap.h"

@implementation UIButton (LongTap)

- (void)addLongTapWithTarget:(id)target action:(SEL)selector  {
    UILongPressGestureRecognizer *deletePress = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:selector];
    deletePress.minimumPressDuration = 0.8;//定义按的时间
    [self addGestureRecognizer:deletePress];
}

@end
