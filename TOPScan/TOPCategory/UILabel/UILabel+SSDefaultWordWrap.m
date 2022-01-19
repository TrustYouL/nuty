#import "UILabel+SSDefaultWordWrap.h"
#import <objc/runtime.h>

@implementation UILabel (SSDefaultWordWrap)
+(void)load{
    
    //只执行一次这个方法
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        
        // Class class = object_getClass((id)self);
        
        //替换三个方法
        
        SEL originalSelector = @selector(init);
        
        SEL originalSelector2 = @selector(initWithFrame:);
        
        SEL originalSelector3 = @selector(awakeFromNib);
        
        SEL swizzledSelector = @selector(QMBaseInit);
        
        SEL swizzledSelector2 = @selector(QMBaseInitWithFrame:);
        
        SEL swizzledSelector3 = @selector(QMBaseAwakeFromNib);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        
        Method originalMethod3 = class_getInstanceMethod(class, originalSelector3);
        
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        Method swizzledMethod3 = class_getInstanceMethod(class, swizzledSelector3);
        
        BOOL didAddMethod =
        
        class_addMethod(class,
                        
                        originalSelector,
                        
                        method_getImplementation(swizzledMethod),
                        
                        method_getTypeEncoding(swizzledMethod));
        
        BOOL didAddMethod2 =
        
        class_addMethod(class,
                        
                        originalSelector2,
                        
                        method_getImplementation(swizzledMethod2),
                        
                        method_getTypeEncoding(swizzledMethod2));
        
        BOOL didAddMethod3 =
        
        class_addMethod(class,
                        
                        originalSelector3,
                        
                        method_getImplementation(swizzledMethod3),
                        
                        method_getTypeEncoding(swizzledMethod3));
        
        if (didAddMethod) {
            
            class_replaceMethod(class,
                                
                                swizzledSelector,
                                
                                method_getImplementation(originalMethod),
                                
                                method_getTypeEncoding(originalMethod));
            
        } else {
            
            method_exchangeImplementations(originalMethod, swizzledMethod);
            
        }
        
        if (didAddMethod2) {
            
            class_replaceMethod(class,
                                
                                swizzledSelector2,
                                
                                method_getImplementation(originalMethod2),
                                
                                method_getTypeEncoding(originalMethod2));
            
        }else {
            
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
            
        }
        
        if (didAddMethod3) {
            
            class_replaceMethod(class,
                                
                                swizzledSelector3,
                                
                                method_getImplementation(originalMethod3),
                                
                                method_getTypeEncoding(originalMethod3));
            
        }else {
            
            method_exchangeImplementations(originalMethod3, swizzledMethod3);
            
        }
        
    });
    
}

- (instancetype)QMBaseInit

{
    
    id __self = [self QMBaseInit];
    
    self.numberOfLines = 2;
    
    return __self;
    
}

- (instancetype)QMBaseInitWithFrame:(CGRect)rect {
    
    id __self = [self QMBaseInitWithFrame:rect];
    
    self.numberOfLines = 2;
    
    return __self;
    
}

- (void)QMBaseAwakeFromNib {
    
    [self QMBaseAwakeFromNib];
    
    self.numberOfLines = 2;
    
}

@end
