#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPHeadMenuModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *iconName;
@property (assign, nonatomic) TOPHomeMoreFunction functionItem;
@property (assign, nonatomic) BOOL showVip;

@end

NS_ASSUME_NONNULL_END
