#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDocumentHeadReusableView : UICollectionReusableView
@property (nonatomic, copy) void(^top_DocumentHeadClickHandler)(NSInteger index,BOOL selected);
@property (nonatomic, copy) void(^top_tagBtnClick)(BOOL selected);
@property (nonatomic, copy) void(^top_freeTrial)(void);
@property (nonatomic, strong)UIImageView * backgroundImg;
@property (nonatomic, strong)TOPImageTitleButton * tagBtn;
@property (nonatomic, strong)TOPTagsListModel * model;
@property (nonatomic, assign)BOOL isShow;
@property (nonatomic, assign)BOOL isShowVip;//yes是显示底部vip提示弹框 no表示不显示
- (void)top_refreshViewTypeBtn;
@end 

NS_ASSUME_NONNULL_END
