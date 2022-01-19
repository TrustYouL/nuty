#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShowPagesView : UIView
@property (nonatomic,strong)UILabel * pageLab;
@property (nonatomic,strong)UIButton * leftBtn;
@property (nonatomic,strong)UIButton * rightBtn;
@property (nonatomic,assign)NSInteger currentIndex;
@property (nonatomic,assign)NSInteger allCount;//数组元素个数
@property (nonatomic,assign)NSInteger cameraIndex;
@property (nonatomic,copy)void(^top_showPageAction)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
