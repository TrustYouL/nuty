#import "TOPSVPOCRShowView.h"
#import <FLAnimatedImageView.h>
#import <FLAnimatedImage.h>
@interface TOPSVPOCRShowView()
@property (nonatomic ,strong)UIImageView * coverImg;
@property (nonatomic ,strong)FLAnimatedImageView * flImg;
@property (nonatomic ,strong)UILabel * titlelab;
@property (nonatomic ,strong)UIButton * clickBtn;

@end

@implementation TOPSVPOCRShowView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBA(51, 51, 51, 0.3);
        _coverImg = [UIImageView new];
        _coverImg.backgroundColor = [UIColor clearColor];
        _coverImg.layer.masksToBounds = YES;
        _coverImg.layer.cornerRadius = 10;
        _coverImg.image = [UIImage imageNamed:@"top_SVPCover"];
        
        _flImg = [FLAnimatedImageView new];
        
        _titlelab = [UILabel new];
        _titlelab.font = [UIFont systemFontOfSize:14];
        _titlelab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titlelab.textAlignment = NSTextAlignmentCenter;
        _titlelab.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _clickBtn = [UIButton new];
        [_clickBtn setImage:[UIImage imageNamed:@"top_ocrback"] forState:UIControlStateNormal];
        [_clickBtn addTarget:self action:@selector(top_clickCurrentBtn) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_coverImg];
        [self addSubview:_flImg];
        [self addSubview:_clickBtn];
        [_coverImg addSubview:_titlelab];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    [_coverImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_centerY).offset(-20);
        make.width.mas_equalTo(265);
        make.height.mas_equalTo(190);
    }];
    
    [_clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_coverImg.mas_bottom).offset(30);
        make.height.width.mas_equalTo(60);
    }];
    
    [_titlelab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(_coverImg);
        make.height.mas_equalTo(45);
    }];

    [_flImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_centerY).offset(-30);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(110);
    }];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"gifImg" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    FLAnimatedImage * image = [FLAnimatedImage animatedImageWithGIFData:data];
    _flImg.animatedImage = image;
}
- (void)setTitleString:(NSString *)titleString{
    _titlelab.text = titleString;
}

- (void)top_clickCurrentBtn{
    if (self.top_clickAction) {
        self.top_clickAction();
    }
}

@end
