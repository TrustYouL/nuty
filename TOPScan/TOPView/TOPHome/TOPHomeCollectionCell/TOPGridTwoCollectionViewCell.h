#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPGridTwoCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong)DocumentModel *model;
@property (nonatomic, strong)UIButton *choseBtn;
@property (nonatomic, copy)void(^top_ChoseBtnBlock)(BOOL isSelect);
- (UIImageView *)currentImageView;
- (void)top_showSelectBtn;
@end

NS_ASSUME_NONNULL_END

