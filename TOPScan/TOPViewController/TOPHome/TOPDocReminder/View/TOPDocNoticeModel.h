#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDocNoticeModel : NSObject
@property (nonatomic ,copy)NSString * noticeID;//通知id
@property (nonatomic ,copy)NSString * noticeTitle;//通知标题
@property (nonatomic ,copy)NSString * noticeBody;//通知内容
@property (nonatomic ,copy)NSString * noticeShowTime;//视图展示的时间
@property (nonatomic ,copy)NSDate * noticeDate;//通知显示的时间
@property (nonatomic ,assign)BOOL noticeState;//通知按钮开关的状态
@end

NS_ASSUME_NONNULL_END
