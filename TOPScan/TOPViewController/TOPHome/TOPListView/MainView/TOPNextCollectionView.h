#import <UIKit/UIKit.h>
#import "TOPDocumentHeadReusableView.h"
#import "TOPFunctionColletionModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPNextCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, assign) TOPDocumentListShowType showType; 
@property (nonatomic, copy) void(^top_DocumentHomeHandler)(NSInteger index,BOOL selected);
@property (nonatomic, copy) void(^top_tagShow)(BOOL isSelect);
@property (nonatomic, strong) NSMutableArray *_Nullable listArray;
@property (nonatomic, copy) NSString * showName;
@property (nonatomic, copy) void(^top_pushNextControllerHandler)(DocumentModel * model);
@property (nonatomic, copy) void(^top_showPhotoHandler)(NSMutableArray *pathArray, NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_movePhotoIndexPathHandler)(NSInteger from, NSInteger to, NSMutableArray *sourceArray);
@property (nonatomic, copy) void(^top_longPressEditHandler)(NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_longPressCalculateSelectedHander)(void);
@property (nonatomic, copy) void(^top_longPressCheckItemHandler)(DocumentModel * model, BOOL selected);
@property (nonatomic, copy) void(^top_clickTxtNote)(NSMutableArray *pathArray, NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_clickTxtOCR)(NSMutableArray *pathArray, NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_clickToChangeName)(void);
@property (nonatomic, copy) void(^top_deceleratingAndShow)(CGFloat insetH);
@property (nonatomic, copy) void(^top_deceleratingEndAndHide)(void);
@property (nonatomic, copy) void(^top_scrollBegainAndHide)(CGFloat drageH);
@property (nonatomic, copy) void(^top_scrollAndSendContentOffset)(CGFloat contentOffsetY);
@property (nonatomic, copy) void(^top_scrollDidEndDecelerating)(void);
@property (nonatomic, copy) void(^top_upGradeVip)(void);//升级VIP
@property (nonatomic, assign) BOOL isMainVC;//是不是在首页，次页 默认为YES

@property (nonatomic, copy) void(^top_didScrollBlock)(void);
@property (nonatomic, copy) void(^top_endDraggingBlock)(void);

@property (nonatomic, copy) void(^top_didScrolInBottom)(BOOL isBottom);
@property (nonatomic, copy) NSString * documentDetailCell;//document文件夹里显示cell类型的判断条件
@property (nonatomic, strong) TOPTagsListModel * model;
@property (nonatomic, assign) BOOL isMerge;//区分是不是再pdf合成界面 yes表示是 no表示不是  默认是no  在pdf合成界面folder类文件夹的选中按钮不能显示 并且folder类文件夹只有点击跳转
@property (nonatomic, assign) BOOL isFromSecondFolderVC;//是否是来自二层folder
- (void)addGestureRecognizer;
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;
@end

NS_ASSUME_NONNULL_END
