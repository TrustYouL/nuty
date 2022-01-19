#import "TOPUserInfoManager.h"

@implementation TOPUserInfoManager

//单例初始化
+ (instancetype)shareInstance {
    static TOPUserInfoManager *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPUserInfoManager alloc] init];
    });
    return singleTon;
}

- (BOOL)isVip {
    _isVip = [TOPSubscriptTools getSubscriptStates];
    return _isVip;
}

@end
