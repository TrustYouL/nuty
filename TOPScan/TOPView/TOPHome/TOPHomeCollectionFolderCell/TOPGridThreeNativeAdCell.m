#import "TOPGridThreeNativeAdCell.h"

@implementation TOPGridThreeNativeAdCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        _nativeAdView = [GADNativeAdView new];
        
        _medieaView = [[GADMediaView alloc]init];
        _medieaView.backgroundColor = [UIColor whiteColor];
        
        _bodyLab = [[UILabel alloc]init];
        _bodyLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _bodyLab.textAlignment = NSTextAlignmentNatural;
        _bodyLab.numberOfLines = 0;
        _bodyLab.font = [UIFont systemFontOfSize:12];
        
        _showBtn = [[UIButton alloc]init];
        _showBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        _showBtn.backgroundColor = [UIColor whiteColor];
        [_showBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        _showBtn.layer.cornerRadius = 2;
        _showBtn.layer.borderWidth = 1;
        _showBtn.layer.borderColor = TOPAPPGreenColor.CGColor;
        [self.contentView addSubview:_nativeAdView];
        [_nativeAdView addSubview:_medieaView];
        [_nativeAdView addSubview:_bodyLab];
        [_nativeAdView addSubview:_showBtn];
        [self top_setViewFream];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _bodyLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}
- (void)top_setViewFream{
    [_nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [_medieaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(_nativeAdView);
        make.height.mas_equalTo(_nativeAdView.mas_width);
    }];
    [_bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_nativeAdView).offset(5);
        make.trailing.equalTo(_nativeAdView).offset(-5);
        make.top.equalTo(_medieaView.mas_bottom).offset(5);
        make.height.mas_equalTo(22);
    }];
    [_showBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_nativeAdView);
        make.bottom.equalTo(_nativeAdView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(67, 23));
    }];
}
- (void)setNativeAd:(DocumentModel *)nativeAd{
    _nativeAd = nativeAd;
    GADNativeAd * currentAd = nativeAd.adModel;
    GADNativeAdView *nativeAdView = _nativeAdView;
    nativeAdView.mediaView = _medieaView;
    
    ((UILabel *)nativeAdView.headlineView).text = currentAd.headline;
    nativeAdView.mediaView.mediaContent = currentAd.mediaContent;
    
    NSLog(@"nativeAd.body==%@",currentAd.body);
    nativeAdView.bodyView = _bodyLab;
    ((UILabel *)nativeAdView.bodyView).text = currentAd.body;
    nativeAdView.bodyView.hidden = currentAd.body ? NO : YES;
    
    nativeAdView.callToActionView = _showBtn;
    [((UIButton *)nativeAdView.callToActionView) setTitle:currentAd.callToAction
                                                 forState:UIControlStateNormal];
    nativeAdView.callToActionView.hidden = currentAd.callToAction ? NO : YES;
    
    ((UIImageView *)nativeAdView.iconView).image = currentAd.icon.image;
    nativeAdView.iconView.hidden = currentAd.icon ? NO : YES;
    
    ((UILabel *)nativeAdView.storeView).text = currentAd.store;
    nativeAdView.storeView.hidden = currentAd.store ? NO : YES;
    
    ((UILabel *)nativeAdView.priceView).text = currentAd.price;
    nativeAdView.priceView.hidden = currentAd.price ? NO : YES;
    
    ((UILabel *)nativeAdView.advertiserView).text = currentAd.advertiser;
    nativeAdView.advertiserView.hidden = currentAd.advertiser ? NO : YES;
    
    nativeAdView.callToActionView.userInteractionEnabled = NO;
    nativeAdView.nativeAd = currentAd;
}
@end
