#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingFooterView : UIView
@property (nonatomic,strong)UIView * backView;
@property (nonatomic,strong)UIImageView * iconImg;
@property (nonatomic,strong)UILabel * titleLab;
@property (nonatomic,strong)UIButton * faxBtn;
@property (nonatomic,strong)UILabel * faxLab;
@property (nonatomic,strong)UIButton * faxReceiveBtn;
@property (nonatomic,strong)UILabel * faxReceiveLab;
@property (nonatomic,strong)UILabel * versionLab;
@property (nonatomic,copy)void(^top_clickBtnBlock)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
