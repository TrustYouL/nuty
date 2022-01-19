#import <UIKit/UIKit.h>

@class TOPShareFileModel;
NS_ASSUME_NONNULL_BEGIN

@interface TOPShareFileCell : UITableViewCell
@property (nonatomic, assign) NSInteger roundedType;//1:top 2:none 3:bottom 4:top&bottom

- (void)top_configCellWithData:(TOPShareFileModel *)cellModel;


@end

NS_ASSUME_NONNULL_END
