#import "FHGoogleLoginManager.h"

@interface FHGoogleLoginManager()<GIDSignInDelegate>

@property (nonatomic, assign) BOOL loginFromKeyChain;

@property (nonatomic, copy) void(^authHandler)(GIDGoogleUser *user,NSError *error);

@property (nonatomic, copy) void(^autoAuthHandler)(GIDGoogleUser *user,NSError *error);

@end

@implementation FHGoogleLoginManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static FHGoogleLoginManager *_manager;
    dispatch_once(&onceToken, ^{
        _manager = [[FHGoogleLoginManager alloc] init];
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init])
    {
        [GIDSignIn sharedInstance].delegate = self;
        [self config];
    }
    return self;
}

- (void)config
{
    
    GIDSignIn.sharedInstance.scopes = @[kGTLRAuthScopeDriveReadonly,kGTLRAuthScopeDriveFile];
}

#pragma mark - Public method

- (GIDGoogleUser *)currentUser {
    return [GIDSignIn sharedInstance].currentUser;
}

- (void)checkGoogleAccountStateWithCompletion:(void (^)(FHGoogleAccountState))handler
{
    if ([self currentUser]) {
        if (handler)
        {
            handler(FHGoogleAccountStateOnline);
        }
    }
    else if ([GIDSignIn sharedInstance].hasPreviousSignIn)
    {
        handler(FHGoogleAccountStateHasKeyChain);
    }
    else
    {
        handler(FHGoogleAccountStateOffline);
    }
}

- (void)autoLoginWithCompletion:(void (^)(GIDGoogleUser *, NSError *))handler {
    _autoAuthHandler = handler;
    self.loginFromKeyChain = YES;
    [[GIDSignIn sharedInstance] restorePreviousSignIn];
}

- (void)startGoogleLoginWithCompletion:(void (^)(GIDGoogleUser *, NSError *))handler {
    _authHandler = handler;
    self.loginFromKeyChain = NO;
//    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];

    GIDSignIn.sharedInstance.presentingViewController = [TOPDocumentHelper top_topViewController];
//    [GIDSignIn sharedInstance].clientID = @"1036750923254-uvlrr4f4jb3l5m26kae614tfis06i5lm.apps.googleusercontent.com";
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (self.loginFromKeyChain) {
        if (_autoAuthHandler) {
            _autoAuthHandler(user,error);
        }
    }
    else {
        if (_authHandler) {
            _authHandler(user,error);
        }
    }
}

//- (UIViewController *)top_appRootViewController
//{
//
//    UIViewController *RootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//
//    UIViewController *topVC = RootVC;
//
//    while (topVC.presentedViewController) {
//
//        topVC = topVC.presentedViewController;
//    }
//    return topVC;
//}
@end
