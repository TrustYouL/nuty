#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPFileTargetModel;
@interface TOPListTableViewTagsCell : UITableViewCell
@property (nonatomic, strong)UIView       *lineView;
@property (nonatomic, strong)DocumentModel *model;
@property (nonatomic, strong)UIButton     *choseBtn;
@property (nonatomic,copy) void(^top_ChoseBtnBlock)(BOOL isSelect);

- (UIImageView *)currentImageView;
- (void)top_showSelectBtn;
- (void)top_configCellWithData:(TOPFileTargetModel *)fileTargetModel;
@end

NS_ASSUME_NONNULL_END
