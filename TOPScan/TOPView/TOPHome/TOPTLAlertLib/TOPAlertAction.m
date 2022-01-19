#import "TOPAlertAction.h"

@interface TOPAlertAction ()
@property(nonatomic, assign, readwrite) TOPAlertActionStyle style;
@property(nonatomic, assign, readwrite) NSString *title;
@property (nullable, nonatomic, readwrite) UIView *customView;
@property(nonatomic, copy) void (^handler)(TOPAlertAction *action);
@end

@implementation TOPAlertAction

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(TOPAlertActionStyle)style handler:(void (^ __nullable)(TOPAlertAction *action))handler {
    TOPAlertAction *alertAction = [[TOPAlertAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

+ (instancetype)actionWithCustomView:(UIView *)customView style:(TOPAlertActionStyle)style handler:(void (^ __nullable)(TOPAlertAction *action))handler {
    TOPAlertAction *alertAction = [[TOPAlertAction alloc] init];
    alertAction.customView = customView;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}
@end
