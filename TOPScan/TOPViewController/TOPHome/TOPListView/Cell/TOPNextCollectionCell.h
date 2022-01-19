#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPNextCollectionCell : UICollectionViewCell
@property (nonatomic, strong)UIView * circleView;
@property (nonatomic, strong)UIButton * circleBtn;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong)UIButton *choseBtn;
@property (nonatomic, strong)DocumentModel *model;
@property (nonatomic, copy) void(^top_ChoseBtnBlock)(BOOL isSelect);
@property (nonatomic, copy) void(^top_gesBlock)(void);
@property (nonatomic, copy) void(^top_circleBtnBlock)(void);
@property (nonatomic, assign)NSInteger item;
@property (nonatomic, strong) NSMutableArray * collectionData;
- (void)top_showSelectBtn;
- (void)top_hideCircleView;
- (void)top_showCircleView;
- (void)top_loadCollcttionData:(DocumentModel *)model;
@end

NS_ASSUME_NONNULL_END
