#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTransferNativeAdView : UIView
@property(nonatomic, strong) GADMediaView *medieaView;
@property(nonatomic, strong) GADNativeAdView *nativeAdView;
@property(nonatomic, strong) UILabel * bodyLab;
@property(nonatomic, strong) UIButton * showBtn;
@property(nonatomic, strong) GADNativeAd * nativeAd;
@end

NS_ASSUME_NONNULL_END
