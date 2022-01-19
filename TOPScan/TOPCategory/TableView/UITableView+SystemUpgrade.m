#import "UITableView+SystemUpgrade.h"
#import <objc/runtime.h>
@implementation UITableView (SystemUpgrade)
+ (void)load {
    //只执行一次这个方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(initWithFrame:style:);
        SEL swizzledSelector = @selector(top_SSTableInitWithFrame:style:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark -- 在这些方法中设置系统升级适配
- (instancetype)top_SSTableInitWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    id __self = [self top_SSTableInitWithFrame:frame style:style];
    if (@available(iOS 15.0, *)) {
        self.sectionHeaderTopPadding = 0;
    }
    return __self;
}

@end
