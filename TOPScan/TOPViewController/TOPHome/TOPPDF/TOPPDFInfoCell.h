#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPDFInfoCell : UITableViewCell

@property (copy, nonatomic) NSString *cellContent;
@property (nonatomic,copy) void(^top_didEditedBlock)(NSString *content);

@end

NS_ASSUME_NONNULL_END
