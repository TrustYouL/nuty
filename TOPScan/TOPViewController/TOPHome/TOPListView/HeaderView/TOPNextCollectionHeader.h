#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPNextCollectionHeader : UICollectionReusableView
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIButton * showBtn;
@property (nonatomic ,copy)void(^top_refreshFolder)(BOOL isSelect);
@end

NS_ASSUME_NONNULL_END
