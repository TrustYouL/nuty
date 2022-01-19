#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger,FHGoogleAccountState) {
    FHGoogleAccountStateOnline = 0,
    FHGoogleAccountStateHasKeyChain,
    FHGoogleAccountStateOffline
};

@interface FHGoogleLoginManager : NSObject

@property (nonatomic, strong) GIDGoogleUser *currentUser;

+ (instancetype)sharedInstance;

- (void)checkGoogleAccountStateWithCompletion:(void (^)(FHGoogleAccountState state))handler;

- (void)autoLoginWithCompletion:(void (^)(GIDGoogleUser *user,NSError *error))handler;

- (void)startGoogleLoginWithCompletion:(void (^)(GIDGoogleUser *user,NSError *error))handler;

@end
