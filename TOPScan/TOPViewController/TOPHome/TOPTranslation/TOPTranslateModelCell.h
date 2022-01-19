#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPTranslateModel;

@interface TOPTranslateModelCell : UITableViewCell
@property (nonatomic,copy) void(^top_clickDownloadBlock)(void);
@property (nonatomic,copy) void(^top_deleteLanguageModelBlock)(void);

- (void)top_configCellWithData:(TOPTranslateModel *)model;
@end

NS_ASSUME_NONNULL_END
