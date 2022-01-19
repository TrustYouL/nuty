#import <UIKit/UIKit.h>
#import "TOPTextView.h"
#import "TOPGuideModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPGuideIpadCell : UICollectionViewCell
@property (nonatomic,strong)UIImageView * imgView;
@property (nonatomic,strong)UIButton * enterBtn;
@property (nonatomic,strong)UILabel * titleLab;
@property (nonatomic,strong)UIView * lineView;
@property (nonatomic,strong)TOPTextView * showText;
@property (nonatomic,strong)TOPGuideModel * model;
@property (nonatomic,copy)void(^top_lastPageEnterAction)(void);
@end

NS_ASSUME_NONNULL_END
