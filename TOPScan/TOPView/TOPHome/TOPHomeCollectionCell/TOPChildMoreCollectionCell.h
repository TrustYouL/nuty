#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPChildMoreCollectionCell : UICollectionViewCell
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UIImageView *vipLogoView;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * noticeLab;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,copy)NSString * titlestring;
@property (nonatomic ,copy)NSString * showTime;
@property (nonatomic ,assign) BOOL showVip;//未开通vip的用户会显示viplog
@end

NS_ASSUME_NONNULL_END
