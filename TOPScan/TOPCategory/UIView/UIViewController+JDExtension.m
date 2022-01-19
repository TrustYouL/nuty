#import "UIViewController+JDExtension.h"
#import <objc/runtime.h> 

static NSDictionary *_titleDict;

@implementation UIViewController (JDExtension)

- (void)setTitleDict:(NSDictionary *)titleDict {
    objc_setAssociatedObject(self, &_titleDict, titleDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)titleDict {
    return objc_getAssociatedObject(self, &_titleDict);
}

//判断是push还是modal进入当前页面
- (BOOL)isPushOrModal
{
    UIViewController *vc = (UIViewController *)self;
    NSArray *viewControllers = vc.navigationController.viewControllers;
    if (viewControllers.count>1) {
        if ([viewControllers objectAtIndex:viewControllers.count-1] == vc) {
            //is push
            return YES;
        }
    }else{
        // is present
        return NO;
    }
    return nil;
}


- (UIViewController *)stackViewController:(id)controllerClass
{
    UIViewController *selfVC = (UIViewController *)self;
    NSArray *viewControllers = selfVC.navigationController.viewControllers;
    
    UIViewController *stackVC = nil;
    for (UIViewController * vc in viewControllers) {
        if ([vc isKindOfClass:controllerClass]) {
            stackVC = vc;
            break;
        }
    }
    return stackVC;
}

- (void)removeStackViewController:(id)controllerClass
{
    UIViewController *currentViewController = [self stackViewController:controllerClass];
    NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:currentViewController.navigationController.viewControllers];
    for (int i = 0; i < viewControllersArray.count; i ++)
    {
        UIViewController *tempViewController = viewControllersArray[i];
        if ([tempViewController isEqual:currentViewController]) {
            [viewControllersArray removeObject:currentViewController];
            currentViewController.navigationController.viewControllers = viewControllersArray;
            break;
        }
    }
}

@end
