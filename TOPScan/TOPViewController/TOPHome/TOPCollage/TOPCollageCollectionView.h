#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCollageCollectionView : UICollectionView
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL showWaterMark;
@property (nonatomic, assign) BOOL idCardModel;
@property (nonatomic,copy) void(^top_didScrollBlock)(NSInteger page);
@property (nonatomic,copy) void(^top_changeEditingPicBlock)(NSInteger tag);
@property (nonatomic,copy) void(^top_selectPicEditBlock)(NSInteger tag);

- (void)top_hiddenCtrlTap;
@end

NS_ASSUME_NONNULL_END
