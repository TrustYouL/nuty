#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TOPCropEditModel;
@interface TOPBatchBottomView : UIView
@property (nonatomic,strong)TOPImageTitleButton * allBtn;
@property (nonatomic,strong)UIButton * finishBtn;
@property (nonatomic,copy)void(^top_sendBtnTag)(NSInteger tag ,BOOL isSelect);
@property (nonatomic,copy)void(^top_cropBtnClick)(NSInteger state);
@property (nonatomic ,strong) TOPCropEditModel *cropModel;//自动裁剪后的数据
- (void)top_restoreAllBtnState:(BOOL)isAutomatic;
- (void)top_updateAllBtn:(TOPCropEditModel *)model;

@end

NS_ASSUME_NONNULL_END
