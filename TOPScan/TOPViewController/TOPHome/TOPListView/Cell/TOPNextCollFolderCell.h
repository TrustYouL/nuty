#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPNextCollFolderCell : UICollectionViewCell
@property (nonatomic, strong)UIView * circleView;
@property (nonatomic, strong)UIButton * circleBtn;
@property (nonatomic, strong)UIButton * choseBtn; 
@property (nonatomic, strong)DocumentModel *model;
@property (nonatomic, assign)BOOL isMerge;
@property (nonatomic, copy) void(^top_ChoseBtnBlock)(BOOL); 
@property (nonatomic, copy) void(^top_circleBtnBlock)(void); 
- (void)top_showSelectBtn;
- (void)top_hideCircleView;
- (void)top_showCircleView;
@end

NS_ASSUME_NONNULL_END
