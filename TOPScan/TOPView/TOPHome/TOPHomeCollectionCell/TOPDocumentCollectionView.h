#import <UIKit/UIKit.h>
#import "TOPDocumentHeadReusableView.h"
#import "TOPFunctionColletionModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface TOPDocumentCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, assign) TOPDocumentListShowType showType;
@property (nonatomic, copy) void(^top_DocumentHomeHandler)(NSInteger index,BOOL selected);
@property (nonatomic, copy) void(^top_tagShow)(BOOL isSelect);
@property (nonatomic, strong) NSMutableArray *_Nullable listArray;
@property (nonatomic, copy) NSString * showName;
@property (nonatomic, copy) void(^top_pushNextControllerHandler)(DocumentModel * model);
@property (nonatomic, copy) void(^top_showPhotoHandler)(NSMutableArray *pathArray, NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_movePhotoIndexPathHandler)(NSInteger from, NSInteger to, NSMutableArray *sourceArray);
@property (nonatomic, assign) BOOL isMoveState; //是不是在首页 首页时不能移动
@property (nonatomic, assign) BOOL isShowHeaderView; //是否展示头部视图
@property (nonatomic, copy) void(^top_longPressEditHandler)(NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_longPressCalculateSelectedHander)(void);
@property (nonatomic, copy) void(^top_longPressCheckItemHandler)(NSInteger index, BOOL selected);
@property (nonatomic, copy) void(^top_clickTxtNote)(NSMutableArray *pathArray, NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_clickTxtOCR)(NSMutableArray *pathArray, NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_clickToChangeName)(void);

@property (nonatomic, copy) void(^top_deceleratingAndShow)(CGFloat insetH);
@property (nonatomic, copy) void(^top_deceleratingEndAndHide)(void);
@property (nonatomic, copy) void(^top_scrollBegainAndHide)(CGFloat drageH);
@property (nonatomic, copy) void(^top_scrollAndSendContentOffset)(CGFloat contentOffsetY);
@property (nonatomic, copy) void(^top_scrollDidEndDecelerating)(void);
@property (nonatomic, copy) void(^top_upGradeVip)(void);//升级VIP
@property (nonatomic, assign) BOOL isTagSelect;
@property (nonatomic, assign) NSInteger columns;//控制一行显示几列

@property (nonatomic, copy) NSString * markCellId;//对cell做标记
@property (nonatomic, copy) void(^top_didScrollBlock)(void);
@property (nonatomic, copy) void(^top_endDraggingBlock)(void);
@property (nonatomic, copy) void(^top_didScrolInBottom)(BOOL isBottom);

@property (nonatomic, copy) NSString * documentDetailCell;//document文件夹里显示cell类型的判断条件
@property (nonatomic, strong) TOPTagsListModel * model;
@property (nonatomic, strong) TOPDocumentHeadReusableView * headerView;
@property (nonatomic, assign) BOOL isMerge;//区分是不是再pdf合成界面 yes表示是 no表示不是  默认是no  在pdf合成界面folder类文件夹的选中按钮不能显示 并且folder类文件夹只有点击跳转
@property (nonatomic, assign) BOOL isFromSecondFolderVC;//是否是来自二层folder
@property (nonatomic, strong) TOPFunctionColletionModel * selectBoxModel;//用于记录工具箱当前选择的功能块类型 也是判定入口是工具箱的依据
@property (nonatomic, assign) BOOL isShowVip;//yes是显示底部vip提示弹框 no表示不显示
- (void)addGestureRecognizer;
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;

@end

NS_ASSUME_NONNULL_END
