#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPUserInfoManager : NSObject
@property (nonatomic, assign) BOOL isVip;
@property (nonatomic, assign) BOOL isOld;
//单例初始化
+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
