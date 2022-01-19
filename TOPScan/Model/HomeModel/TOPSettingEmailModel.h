#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingEmailModel : NSObject<NSCoding>
@property (nonatomic ,copy)NSString * myselfEmail;
@property (nonatomic ,copy)NSString * toEmail;
@property (nonatomic ,copy)NSString * subject;
@property (nonatomic ,copy)NSString * body;

@end

NS_ASSUME_NONNULL_END
