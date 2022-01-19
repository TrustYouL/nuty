#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFunctionChildAdjustBottomView : UIView
@property (nonatomic ,copy)NSArray * disableArray;
@property (nonatomic ,copy)void(^top_clickSendBtnTag)(NSInteger tag);
- (instancetype)initWithFrame:(CGRect)frame sendPicArray:(NSArray *)array sendTitleArray:(NSArray *)titleArray;
- (void)top_changePressViewBtnState:(TOPItemsSelectedState)selectedState;
- (void)top_changeBottonBtnState:(NSArray *)picArray withEnable:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
