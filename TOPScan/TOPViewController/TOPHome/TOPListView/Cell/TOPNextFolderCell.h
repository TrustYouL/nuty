#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DocumentModel;
@interface TOPNextFolderCell : UITableViewCell
@property (nonatomic, strong)UIButton * choseBtn;
@property (nonatomic, strong)DocumentModel *model;
@property (nonatomic, assign)BOOL isMerge;
@property (nonatomic,copy) void(^top_ChoseBtnBlock)(BOOL);
- (void)top_showSelectBtn;

@end

NS_ASSUME_NONNULL_END
