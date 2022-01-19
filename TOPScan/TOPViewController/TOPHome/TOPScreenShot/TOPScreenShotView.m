#import "TOPScreenShotView.h"
#import "TOPPhotoEditScrollView.h"
@interface TOPScreenShotView()
@property (nonatomic ,strong)UIImageView * fuzzyImg;
@property (nonatomic ,strong)UIButton * cancelBtn;
@property (nonatomic ,strong)TOPPhotoEditScrollView * showImgView;
@property (nonatomic ,strong)TOPImageTitleButton * saveBtn;
@property (nonatomic ,strong)TOPImageTitleButton * ocrBtn;
@property (nonatomic ,strong)TOPImageTitleButton * questionBtn;
@property (nonatomic ,strong)TOPImageTitleButton * shareBtn;
@property (nonatomic ,strong)TOPImageTitleButton * setBtn;
@property (nonatomic ,strong)UIView * butCoverView;
@end

@implementation TOPScreenShotView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap)];
        [self addGestureRecognizer:tap];
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    _fuzzyImg = [UIImageView new];
    
    _showImgView = [[TOPPhotoEditScrollView alloc]init];
    _showImgView.layer.masksToBounds = YES;
    _showImgView.layer.cornerRadius = 5;
    
    _backView = [UIView new];
    _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:RGBA(50, 50, 50, 1.0) defaultColor:RGBA(105, 105, 105, 1.0)];
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 10;
    
    _butCoverView = [UIView new];
    _butCoverView.backgroundColor = [UIColor clearColor];

    _saveBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
    _saveBtn.padding = CGSizeMake(5, 5);
    _saveBtn.tag = 1000+1;
    _saveBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _saveBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_saveBtn setTitle:NSLocalizedString(@"topscan_shotsavedoc", @"") forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn setImage:[UIImage imageNamed:@"top_shotsavedoc"] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _ocrBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
    _ocrBtn.padding = CGSizeMake(5, 5);
    _ocrBtn.tag = 1000+2;
    _ocrBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _ocrBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _ocrBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_ocrBtn setTitle:NSLocalizedString(@"topscan_graffititextrecognition", @"") forState:UIControlStateNormal];
    [_ocrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_ocrBtn setImage:[UIImage imageNamed:@"top_shotocr"] forState:UIControlStateNormal];
    [_ocrBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];

    _questionBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
    _questionBtn.padding = CGSizeMake(5, 5);
    _questionBtn.tag = 1000+3;
    _questionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _questionBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _questionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_questionBtn setTitle:NSLocalizedString(@"topscan_shotfeedback", @"") forState:UIControlStateNormal];
    [_questionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_questionBtn setImage:[UIImage imageNamed:@"top_shotqusetion"] forState:UIControlStateNormal];
    [_questionBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _shareBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
    _shareBtn.padding = CGSizeMake(5, 5);
    _shareBtn.tag = 1000+4;
    _shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _shareBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_shareBtn setTitle:NSLocalizedString(@"topscan_share", @"") forState:UIControlStateNormal];
    [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shareBtn setImage:[UIImage imageNamed:@"top_shotshare"] forState:UIControlStateNormal];
    [_shareBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];

    _cancelBtn = [UIButton new];
    _cancelBtn.tag = 1000+5;
    _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    _cancelBtn.backgroundColor = [UIColor clearColor];
    [_cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
   
    [self addSubview:_fuzzyImg];
    [self addSubview:_showImgView];
    [self addSubview:_backView];
    [_backView addSubview:_butCoverView];
    [_backView addSubview:_cancelBtn];
    [_butCoverView addSubview:_saveBtn];
    [_butCoverView addSubview:_questionBtn];
    [_butCoverView addSubview:_shareBtn];
    [_butCoverView addSubview:_ocrBtn];
    [self top_setupFream];
}

- (void)top_setupFream{
    [_fuzzyImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    CGFloat bottomH = 0;
    if (TOPBottomSafeHeight == 0) {
        bottomH = 20;
    }else{
        bottomH = TOPBottomSafeHeight;
    }
    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        make.bottom.equalTo(self).offset(-bottomH);
        make.height.mas_equalTo(190);
    }];
    [_showImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(65);
        make.trailing.equalTo(self).offset(-65);
        make.top.equalTo(self).offset(10+TOPStatusBarHeight);
        make.bottom.equalTo(_backView.mas_top).offset(-25);
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_backView);
        make.bottom.equalTo(_backView).offset(-10);
        make.height.mas_equalTo(40);
    }];
    [_butCoverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_backView);
        make.trailing.equalTo(_backView);
        make.top.equalTo(_backView);
        make.bottom.equalTo(_cancelBtn.mas_top);
    }];
    [_questionBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_butCoverView).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 66));
    }];
    [_saveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_butCoverView).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 66));
    }];
    [_shareBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_butCoverView).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 66));
    }];
    [_ocrBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_butCoverView).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 66));
    }];
    [_butCoverView top_distributeSpacingHorizontallyWith:@[_saveBtn,_ocrBtn,_questionBtn,_shareBtn]];
}
- (void)top_clickBtn:(UIButton *)sender{
    if (sender.tag == 1000+4) {
        _backView.hidden = YES;
    }
    if (self.top_functionBlock) {
        self.top_functionBlock(sender.tag-1001);
    }
}
- (void)setShowImage:(UIImage *)showImage{
    _showImage = showImage;
    
    _fuzzyImg.image = showImage;
    [self top_creatFXblurView];
    _showImgView.mainImage = showImage;
}
- (void)top_clickTap{
    if (self.top_functionBlock) {
        self.top_functionBlock(4);
    }
}
- (void)top_creatFXblurView{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    blurView.frame = self.bounds;
    [_fuzzyImg addSubview: blurView];
}

@end
