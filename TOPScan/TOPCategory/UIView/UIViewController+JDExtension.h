#import <UIKit/UIKit.h>

@interface UIViewController (JDExtension)
- (void)setTitleDict:(NSDictionary *)titleDict;
- (NSDictionary *)titleDict;
//判断是push还是modal进入当前页面
- (BOOL)isPushOrModal;
//部分页面不需要来回互相跳转,若栈中已经存在,则pop回去
- (UIViewController *)stackViewController:(id)controllerClass;
@end
