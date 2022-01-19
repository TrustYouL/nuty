#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL allowRotation;
@property (nonatomic ,strong) NSMutableArray *homeDataArr;
@property (assign, nonatomic) BOOL loadSuccess;

+ (AppDelegate *)top_getAppDelegate;
@end

