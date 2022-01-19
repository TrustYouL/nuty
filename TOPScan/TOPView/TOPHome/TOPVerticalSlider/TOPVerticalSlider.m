#import "TOPVerticalSlider.h"
#import "Masonry.h"

@interface TOPVerticalSlider ()
@property (strong, nonatomic) UIButton *thumBtn;
@property (strong, nonatomic) UILabel *backLabel;
@property (strong, nonatomic) UILabel *progressLabel;
@property (assign, nonatomic) CGFloat btnWidth;//按钮宽
@property (assign, nonatomic) CGFloat btnHeight;//按钮高
@end

@implementation TOPVerticalSlider

 
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title progressColor:(UIColor *)progressColor thumImage:(NSString *)thumImage {
    if (self = [super initWithFrame:frame]) {
        // 滑动按钮
        self.thumBtn = [[UIButton alloc] init];
        UIImage *btnImage = [UIImage imageNamed:thumImage];
    
        self.btnWidth = btnImage.size.width;
        self.btnHeight = btnImage.size.height;
        [self.thumBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.thumBtn.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(top_thumbPanAction:)];
 
        [self.thumBtn addGestureRecognizer:panGestureRecognizer];
        [self addSubview:self.thumBtn];
 
        // 进度条
        self.backLabel = [[UILabel alloc] init];
 
        self.backLabel.backgroundColor = [progressColor colorWithAlphaComponent:0.8];
        self.backLabel.translatesAutoresizingMaskIntoConstraints = NO;
 
        [self addSubview:self.backLabel];
 
        self.progressLabel = [[UILabel alloc] init];
 
        self.progressLabel.backgroundColor = progressColor;
        self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
 
        [self addSubview:self.progressLabel];
        self.progressLabel.hidden = YES;
 
 
        // 顶部值
        self.valueLabel = [[UILabel alloc] init];
 
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.textColor = [UIColor whiteColor];
        self.valueLabel.backgroundColor = [UIColor blackColor];
        self.valueLabel.layer.cornerRadius = 5;
        self.valueLabel.layer.masksToBounds = YES;
        self.valueLabel.adjustsFontSizeToFitWidth = YES;
 
        [self addSubview:self.valueLabel];
 
        [self bringSubviewToFront:self.thumBtn];
 
        [self top_setConstraints];
        
        // 初始化数据
        self.value = 0.0;
    }
    
    return self;
}
 
#pragma mark --- 按钮拖动方法
- (void)top_thumbPanAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    self.valueLabel.hidden = NO;
    // 转换坐标
    CGPoint point = [panGestureRecognizer translationInView:self];
    
    CGFloat yOriginPoint = panGestureRecognizer.view.center.y + point.y;
    if (yOriginPoint >=self.backLabel.frame.origin.y && yOriginPoint <= (self.backLabel.frame.origin.y + self.backLabel.frame.size.height)) {
        panGestureRecognizer.view.frame = CGRectMake(panGestureRecognizer.view.frame.origin.x, panGestureRecognizer.view.frame.origin.y + point.y, self.btnWidth, self.btnHeight);
        
        CGFloat disVal = yOriginPoint - self.backLabel.frame.origin.y;
        if (fabs(disVal) < 1) {//方便滑到起始点和终点--末尾小数点的误差值导致不能到起点和终点
            disVal = 0;
        } else if (fabs(disVal - self.backLabel.frame.size.height) < 1) {
            disVal = self.backLabel.frame.size.height;
        }
        
        self.value = disVal / self.backLabel.frame.size.height;
        if (self.passValue) {
            self.passValue(self.value);
        }
    }
    
    // 转换成原来坐标系的坐标
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.passEndValue) {
            // 转为字符串，又转为float，是为了去的两位小数的浮点数
            self.passEndValue(self.value);
        }
    }
}
 
- (void)setValue:(float)value {
    _value = value;
    
    self.thumBtn.frame = CGRectMake(self.thumBtn.frame.origin.x, self.backLabel.frame.size.height * value + self.backLabel.frame.origin.y - self.btnHeight/2, self.btnWidth,  self.btnHeight);
    [self top_updateValueLabFrame];
    NSInteger index = value * self.itemCount;
    self.hidden = value > 0.0 ? NO : YES;
    if (index == 0) {
        index = 1;
    } else {
        if (index == self.itemCount - 1) {
            index = self.itemCount;
        }
    }
    self.valueLabel.text = [NSString stringWithFormat:@"%@", @(index)];
}
 
- (void)top_setConstraints {
    [self.backLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(10);
        make.top.equalTo(self).offset(self.btnHeight/2);
        make.bottom.equalTo(self).offset(-10);
        make.width.mas_equalTo(3);
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-self.btnHeight/2);
        make.width.mas_equalTo(3);
        make.height.mas_equalTo(0);
    }];
    
    [self.thumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.backLabel.mas_trailing).offset(2);
        make.centerY.equalTo(self.backLabel.mas_top);
        make.size.mas_equalTo(CGSizeMake(self.btnWidth, self.btnHeight));
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.thumBtn.mas_centerY).offset(0);
        make.trailing.equalTo(self.thumBtn.mas_leading).offset(-20);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    
}
 
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)top_updateValueLabFrame {
    CGRect labFrame= self.valueLabel.frame;
    labFrame.origin.y = self.thumBtn.frame.origin.y - (30 - self.btnHeight)/2;
    self.valueLabel.frame = labFrame;
}
 
@end
