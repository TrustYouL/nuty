#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TouchIDState_DEVICENOTSUPPORTED = 1011,
    TouchIDState_DEVICENOTSAFEGUARD = 1012,
    TouchIDState_DEVICENOTREGUIDFIN = 1013,
    TouchIDState_SUCCESSSUPPORT = 1000,
    TouchIDState_FINGETSUCCESS = 1002,
    TouchIDState_ERROR = 1001,
    TouchIDState_ChoosePassWord = 999,
} TouchIDRecognitionState;

NS_ASSUME_NONNULL_BEGIN

@interface TOPTouchIDRecognitionManager : NSObject

typedef void(^TOPTouchIDRecognitionManagerBlock)(NSDictionary *callBackDic);
@property (nonatomic, copy) TOPTouchIDRecognitionManagerBlock top_touchIDBlock;
- (void)loadAuthentication:(TOPAppSetSafeUnlockType)unlockType;
- (void)checkTouchIDPrint;

@end

NS_ASSUME_NONNULL_END
