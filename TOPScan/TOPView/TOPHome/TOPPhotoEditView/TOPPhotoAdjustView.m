#import "TOPPhotoAdjustView.h"
#import "TOPSlider.h"
@interface TOPPhotoAdjustView()
@property (nonatomic ,strong)UISlider *BrightnessSlider;
@property (nonatomic ,strong)UISlider *StaturationSlider;
@property (nonatomic ,strong)UISlider *ContrastSlider;

@end
@implementation TOPPhotoAdjustView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
        TOPSlider * BrightnessSlider = [[TOPSlider alloc]initWithFrame:CGRectMake((TOPScreenWidth-200)/2, (self.frame.size.height/3-1.5)/2, 200, 1.5)];
        BrightnessSlider.minimumValue = -1;
        BrightnessSlider.maximumValue = 1;
        BrightnessSlider.value = 0;
        BrightnessSlider.backgroundColor = [UIColor clearColor];
        [BrightnessSlider setThumbImage:[UIImage imageNamed:@"top_exoprtbtnselect"] forState:UIControlStateNormal];
        [BrightnessSlider setMinimumTrackTintColor:RGBA(48, 108, 205, 1)];
        [BrightnessSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [BrightnessSlider addTarget:self action:@selector(top_changeBrightness:) forControlEvents:UIControlEventValueChanged];
        self.BrightnessSlider = BrightnessSlider;
        
        UIImageView * BrightnessIcon = [[UIImageView alloc]initWithFrame:CGRectMake((TOPScreenWidth-200)/2-20-10, (self.frame.size.height/3-20)/2, 20, 20)];
        BrightnessIcon.image = [UIImage imageNamed:@"top_adjustLight"];
        
        TOPSlider * StaturationSlider = [[TOPSlider alloc]initWithFrame:CGRectMake((TOPScreenWidth-200)/2, (self.frame.size.height/3-1.5)/2+self.frame.size.height/3, 200, 1.5)];
        StaturationSlider.minimumValue = 0;
        StaturationSlider.maximumValue = 2;
        StaturationSlider.value = 1;
        StaturationSlider.backgroundColor = [UIColor clearColor];
        [StaturationSlider setThumbImage:[UIImage imageNamed:@"top_exoprtbtnselect"] forState:UIControlStateNormal];
        [StaturationSlider setMinimumTrackTintColor:RGBA(48, 108, 205, 1)];
        [StaturationSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [StaturationSlider addTarget:self action:@selector(top_changeStaturation:) forControlEvents:UIControlEventValueChanged];
        self.StaturationSlider = StaturationSlider;
        
        UIImageView * StaturationIcon = [[UIImageView alloc]initWithFrame:CGRectMake((TOPScreenWidth-200)/2-20-10, (self.frame.size.height/3-20)/2+self.frame.size.height/3, 20, 20)];
        StaturationIcon.image = [UIImage imageNamed:@"top_adjustStaturation"];

        TOPSlider * ContrastSlider = [[TOPSlider alloc]initWithFrame:CGRectMake((TOPScreenWidth-200)/2, (self.frame.size.height/3-1.5)/2+self.frame.size.height/3*2, 200, 1.5)];
        ContrastSlider.minimumValue = 0;
        ContrastSlider.maximumValue = 2;
        ContrastSlider.value = 1;
        ContrastSlider.backgroundColor = [UIColor clearColor];
        [ContrastSlider setThumbImage:[UIImage imageNamed:@"top_exoprtbtnselect"] forState:UIControlStateNormal];
        [ContrastSlider setMinimumTrackTintColor:RGBA(48, 108, 205, 1)];
        [ContrastSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [ContrastSlider addTarget:self action:@selector(top_changeContrast:) forControlEvents:UIControlEventValueChanged];
        self.ContrastSlider = ContrastSlider;
        
        UIImageView * ContrastIcon = [[UIImageView alloc]initWithFrame:CGRectMake((TOPScreenWidth-200)/2-20-10, (self.frame.size.height/3-20)/2+self.frame.size.height/3*2, 20, 20)];
        ContrastIcon.image = [UIImage imageNamed:@"top_blackPattern"];
        
        [self addSubview:BrightnessIcon];
        [self addSubview:BrightnessSlider];
        [self addSubview:StaturationIcon];
        [self addSubview:StaturationSlider];
        [self addSubview:ContrastIcon];
        [self addSubview:ContrastSlider];
        
        [BrightnessIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(50);
            make.top.equalTo(self).offset((self.frame.size.height/3-20)/2);
            make.width.height.mas_equalTo(20);
        }];
        [BrightnessSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(BrightnessIcon.mas_trailing).offset(10);
            make.trailing.equalTo(self).offset(-70);
            make.top.equalTo(self).offset((self.frame.size.height/3-1.5)/2);
            make.height.mas_equalTo(1.5);
        }];
        [StaturationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(50);
            make.top.equalTo(self).offset((self.frame.size.height/3-20)/2+self.frame.size.height/3);
            make.width.height.mas_equalTo(20);
        }];
        [StaturationSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(BrightnessIcon.mas_trailing).offset(10);
            make.trailing.equalTo(self).offset(-70);
            make.top.equalTo(self).offset((self.frame.size.height/3-1.5)/2+self.frame.size.height/3);
            make.height.mas_equalTo(1.5);
        }];
        [ContrastIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(50);
            make.top.equalTo(self).offset((self.frame.size.height/3-20)/2+self.frame.size.height/3*2);
            make.width.height.mas_equalTo(20);
        }];
        [ContrastSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(BrightnessIcon.mas_trailing).offset(10);
            make.trailing.equalTo(self).offset(-70);
            make.top.equalTo(self).offset((self.frame.size.height/3-1.5)/2+self.frame.size.height/3*2);
            make.height.mas_equalTo(1.5);
        }];
    }
    return self;
}

- (void)top_changeBrightness:(TOPSlider *)slider{
    if (self.changePictureState) {
        self.changePictureState([NSNumber numberWithFloat:slider.value], TOPPhotoReEditFilterBrightness);
    }
}

- (void)top_changeStaturation:(TOPSlider *)slider{
    if (self.changePictureState) {
        self.changePictureState([NSNumber numberWithFloat:slider.value], TOPPhotoReEditFilterStaturation);
    }
}

- (void)top_changeContrast:(TOPSlider *)slider{
    if (self.changePictureState) {
        self.changePictureState([NSNumber numberWithFloat:slider.value], TOPPhotoReEditFilterContrast);
    }
}

- (void)top_reloadAdjustViewUIWithModel:(TOPCameraBatchModel *)model{
    self.BrightnessSlider.value = model.brightnessValue;
    self.StaturationSlider.value = model.staturationValue;
    self.ContrastSlider.value = model.contrastValue;
}

- (void)top_reloadAdjustViewUI{
    self.BrightnessSlider.value = 0;
    self.StaturationSlider.value = 1;
    self.ContrastSlider.value = 1;
}


@end
