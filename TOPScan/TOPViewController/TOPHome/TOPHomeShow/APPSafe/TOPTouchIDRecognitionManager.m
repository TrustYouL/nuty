#import "TOPTouchIDRecognitionManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation TOPTouchIDRecognitionManager

- (void)checkTouchIDPrint
{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
    {
        NSDictionary *dic = @{
                              @"code" : @(TouchIDState_SUCCESSSUPPORT),
                              @"message" : @"支持指纹识别"
                              };
        [self runTouchIDStateBlockWith:dic];
    }else{
        NSDictionary * dic = [self CheckTouchIDStateBlockWith:authError message:@"" success:NO];
        [self runTouchIDStateBlockWith:dic];
    }
}

- (void)loadAuthentication:(TOPAppSetSafeUnlockType)unlockType
{
    __weak typeof(self) weakSelf = self;
    LAContext *myContext = [[LAContext alloc] init];
    myContext.localizedFallbackTitle = @"输入密码";
    NSError *authError = nil;
    NSString *myLocalizedReasonString = NSLocalizedString(@"topscan_touchtitle", @"");
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError])
    {
        [myContext evaluatePolicy: LAPolicyDeviceOwnerAuthentication localizedReason:myLocalizedReasonString reply:^(BOOL success, NSError * _Nullable error) {
            NSDictionary *dic = [self CheckTouchIDStateBlockWith:error message:@"" success:success];
            [weakSelf runTouchIDStateBlockWith:dic];
        }];
    }
    else
    {
        NSDictionary *dic = @{
                              @"code" : @(TouchIDState_DEVICENOTSUPPORTED),
                              @"message" : @"设备不支持指纹"
                              };
        [weakSelf runTouchIDStateBlockWith:dic];
    }
}

- (NSDictionary *)CheckTouchIDStateBlockWith:(NSError *)error message:(NSString *)message success:(BOOL)success
{
    TouchIDRecognitionState touchIdState = TouchIDState_DEVICENOTSUPPORTED;
    if(success)
    {
        touchIdState = TouchIDState_FINGETSUCCESS;
        message = @"指纹识别成功";
    }
    else
    {
        switch (error.code)
        {
            case LAErrorAuthenticationFailed:
            {
                touchIdState = TouchIDState_ERROR;
                message = @"授权失败";
            }
                break;
            case LAErrorUserCancel:
            {
                touchIdState = TouchIDState_ERROR;
                message = @"用户取消验证";
            }
                break;
            case LAErrorUserFallback:
            {
                touchIdState = TouchIDState_ChoosePassWord;
                message = @"用户选择输入密码";
            }
                break;
            case LAErrorSystemCancel:
            {
                touchIdState = TouchIDState_ERROR;
                message = @"取消授权";
            }
                break;
            case LAErrorPasscodeNotSet:

            {
                touchIdState = TouchIDState_DEVICENOTSAFEGUARD;
                message = @"设备未处于安全保护中";
            }
                break;
            case LAErrorTouchIDNotAvailable:
            {
                touchIdState = TouchIDState_DEVICENOTREGUIDFIN;
                message = @"设备没有注册过指纹";
            }
                break;
            case LAErrorTouchIDNotEnrolled:
            {
                touchIdState = TouchIDState_DEVICENOTREGUIDFIN;
                message = @"设备没有注册过指纹";
            }
                break;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
            case LAErrorTouchIDLockout:
            {
                touchIdState = TouchIDState_ERROR;
                message = @"Touch ID被锁，需要用户输入密码解锁";
            }
                break;
            case LAErrorAppCancel:
            {
                touchIdState = TouchIDState_ERROR;
                message = @"用户不能控制情况下APP被挂起";
            }
                break;
            case LAErrorInvalidContext:
            {
                touchIdState = TouchIDState_ERROR;
                message = @"指纹识别失败";
            }
                break;
#else
#endif
            default:
            {
                touchIdState = TouchIDState_ERROR;
                message = @"指纹识别失败";
                break;
            }
        }
    }
    NSDictionary *dic = @{
                          @"code" : @(touchIdState),
                          @"message" : message,
                          };
    return dic;
}
- (void)runTouchIDStateBlockWith:(NSDictionary *)dic
{
    if (self.top_touchIDBlock) {
        self.top_touchIDBlock(dic);
    }
}
@end
