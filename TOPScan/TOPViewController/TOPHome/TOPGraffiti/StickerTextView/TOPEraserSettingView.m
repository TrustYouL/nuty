#import "TOPEraserSettingView.h"
@interface TOPEraserSettingView()
@property (nonatomic ,strong)UIView * bgView;
@end
@implementation TOPEraserSettingView
#define EraserSettingBGHeight 80
- (instancetype)initWithEarserValue:(CGFloat)value {
    self = [super init];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width, height = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, height, width, height - 80 - TOPBottomSafeHeight);
        self.backgroundColor = [UIColor clearColor];
        self.eraserWidth = value;
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,  CGRectGetHeight(self.bounds)- EraserSettingBGHeight, CGRectGetWidth(self.bounds), EraserSettingBGHeight)];
    bgView.backgroundColor = RGBA(38, 43, 48, 0.7);;
    [self addSubview:bgView];
    self.bgView = bgView;
    [self eraserSliderView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(EraserSettingBGHeight);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches  anyObject] locationInView:self];
    CGRect rect = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - EraserSettingBGHeight - 60);
    if (CGRectContainsPoint(rect, touchPoint)) {
        [self top_dismissSelf];
    }
}

- (void)top_dismissSelf {
    if (self.callSetCompleteBlock) {
        self.callSetCompleteBlock(self.eraserWidth);
    }
}

- (void)top_sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.eraserWidth = slider.value;
}

- (void)eraserSliderView {
    UIView *brushView = [[UIView alloc] initWithFrame:CGRectMake(0, (EraserSettingBGHeight - 30)/2, TOPScreenWidth, 30)];
    brushView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:brushView];
    
    UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 30)];
    noClassLab.textColor = kWhiteColor;
    noClassLab.textAlignment = NSTextAlignmentNatural;
    noClassLab.font = [UIFont systemFontOfSize:15];
    noClassLab.text = NSLocalizedString(@"topscan_graffitieraser", @"");
    [brushView addSubview:noClassLab];
    
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noClassLab.frame) + 20, 0, TOPScreenWidth - (CGRectGetMaxX(noClassLab.frame) + 20 + 20), 30)];
    _sizeSlider.thumbTintColor = kTopicBlueColor;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = RGBA(255, 255, 255, 0.9);
    _sizeSlider.minimumValue = 1;
    _sizeSlider.maximumValue = 20;
    _sizeSlider.value = self.eraserWidth;
    _sizeSlider.tag = 100;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [brushView addSubview:_sizeSlider];
    
    [brushView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.bgView);
        make.centerY.equalTo(self.bgView);
        make.height.mas_equalTo(30);
    }];
    
    [noClassLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(brushView).offset(20);
        make.top.equalTo(brushView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(80);
    }];
    
    [_sizeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(noClassLab.mas_trailing).offset(20);
        make.trailing.equalTo(brushView).offset(-20);
        make.top.equalTo(brushView);
        make.height.mas_equalTo(30);
    }];
}

@end
