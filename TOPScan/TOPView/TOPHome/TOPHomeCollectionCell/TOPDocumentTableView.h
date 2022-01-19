#import <UIKit/UIKit.h>
#import "TOPDocumentHeadReusableView.h"

NS_ASSUME_NONNULL_BEGIN
@interface TOPDocumentTableView : UITableView
@property (nonatomic, copy) void(^top_DocumentHomeHandler)(NSInteger index,BOOL selected);
@property (nonatomic, copy) void(^top_tagShow)(BOOL isSelect);
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, copy) NSString * showName;
@property (nonatomic, copy) void(^top_pushNextControllerHandler)(DocumentModel * model);
@property (nonatomic, copy) void(^top_showPhotoHandler)(NSMutableArray *pathArray, NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_movePhotoIndexPathHandler)(NSInteger from, NSInteger to, NSMutableArray *sourceArray);
@property (nonatomic, copy) void(^top_deceleratingAndShow)(CGFloat insetH);
@property (nonatomic, copy) void(^top_deceleratingEndAndHide)(void);
@property (nonatomic, copy) void(^top_scrollBegainAndHide)(CGFloat drageH);
@property (nonatomic, copy) void(^top_scrollAndSendContentOffset)(CGFloat contentOffsetY);
@property (nonatomic, copy) void(^top_scrollDidEndDecelerating)(void);

@property (nonatomic, copy) void(^top_clickToChangeName)(void);
@property (nonatomic, assign) BOOL isShowHeaderView; //是否展示头部视图
@property (nonatomic, copy) void(^top_upGradeVip)(void);//升级VIP
@property (nonatomic, assign) BOOL isTagSelect;

@property (nonatomic, copy) void(^top_longPressEditHandler)(NSIndexPath *idxPath);
@property (nonatomic, copy) void(^top_longPressCheckItemHandler)(NSInteger index, BOOL selected);
@property (nonatomic, copy) void(^top_longPressCalculateSelectedHander)(void);
@property (nonatomic, copy) void(^top_clickSideToShare)(void);
@property (nonatomic, copy) void(^top_clickSideToEmail)(void);
@property (nonatomic, copy) void(^top_clickSideToRename)(void);
@property (nonatomic, copy) void(^top_clickSideToDelete)(void);
@property (nonatomic, copy) void(^top_didScrolInBottom)(BOOL isBottom);//滑动时文件大小lab显示与隐藏
@property (nonatomic, strong)TOPTagsListModel * model;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isMerge;//区分是不是再pdf合成界面 yes表示是 no表示不是  默认是no
@property (nonatomic, assign) BOOL isCan;//能否编辑
@property (nonatomic, assign) BOOL isFromSecondFolderVC;//是否是来自二层folder
@property (nonatomic, strong) TOPDocumentHeadReusableView * tipHeaderView;
@property (nonatomic, assign) BOOL isShowVip;//yes是显示底部vip提示弹框 no表示不显示

- (void)addGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
