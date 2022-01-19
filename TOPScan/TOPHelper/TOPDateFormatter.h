#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDateFormatter : NSDateFormatter
//单例初始化
+ (instancetype)shareInstance;
- (void)top_removeSingleTon;
@end

NS_ASSUME_NONNULL_END
