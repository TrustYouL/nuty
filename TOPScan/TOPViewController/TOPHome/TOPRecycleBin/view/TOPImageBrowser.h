#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPImageBrowser : UIView
//数据源
@property (nonatomic, strong) NSMutableArray *dataArray;
//当前点击的图片下标
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) void(^top_refreshCurrentIndex)(NSInteger index);//当前的位置

- (void)top_updateCurrentItem;
- (void)top_hiddenPageLab;
@end

NS_ASSUME_NONNULL_END
