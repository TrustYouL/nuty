#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPGirdThreeFolderCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong)DocumentModel *model;
@property (nonatomic, strong)UIButton *choseBtn;
@property (nonatomic, assign)BOOL isMerge;
@property (nonatomic, copy)void(^top_ChoseBtnBlock)(BOOL isSelect); //选中按钮事件回调
- (void)top_showSelectBtn;
@end

NS_ASSUME_NONNULL_END
