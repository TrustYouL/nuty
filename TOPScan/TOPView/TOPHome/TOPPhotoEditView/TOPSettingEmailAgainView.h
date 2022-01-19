#import <UIKit/UIKit.h>
#import "TOPSettingEmailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingEmailAgainView : UIView
@property (nonatomic ,copy)void(^top_returnEdit)(void);
@property (nonatomic ,assign)NSInteger contentType;//用来判断输入内容保存之后是myselfEmail 还是toEmail
@property (nonatomic ,copy)void(^top_sendBackEmail)(NSString * email);//返回新添加的email

@end

NS_ASSUME_NONNULL_END
