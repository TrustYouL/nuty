//
//  TOPAppSafeNotCenterClass.m
//  
//
//  Created by admin4 on 2021/1/19.
//  Copyright © 2021 Yangyang. All rights reserved.
//

#import "TOPAppSafeNotCenterClass.h"
#import "TOPAppSafeShowPasswordVC.h"
#import "TOPTouchUnlockViewController.h"

@implementation TOPAppSafeNotCenterClass
+ (instancetype)shareInstance {
    
    static TOPAppSafeNotCenterClass *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPAppSafeNotCenterClass alloc] init];
    });
    return singleTon;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_didBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
        [self top_didBecomeActive];
    }
    return self;
}
- (void)top_didBecomeActive
{
    BOOL isAppSafeStates = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    if (isAppSafeStates) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];

        NSInteger currentType = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
        switch (currentType) {
            case TOPAppSetSafeUnlockTypePwd:
            {
                TOPAppSafeShowPasswordVC *setpwdVC = [[TOPAppSafeShowPasswordVC alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
                setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateSafeInLocalInput;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
            }
                break;
            case TOPAppSetSafeUnlockTypeTouchID:
            {
                TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];

                setpwdVC.unlockType = TOPAppSetSafeUnlockTypeTouchID;
                setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateLocalInput;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];

            }
                break;
            case TOPAppSetSafeUnlockTypeFaceID:
            {
                TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];

                setpwdVC.unlockType = TOPAppSetSafeUnlockTypeFaceID;
                setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateLocalInput;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];

            }
                break;
            default:
                break;
        }
    }
}


@end
