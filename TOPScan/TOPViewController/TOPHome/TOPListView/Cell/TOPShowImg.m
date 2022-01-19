#import "TOPShowImg.h"

@implementation TOPShowImg
- (instancetype)init{
    if (self = [super init]) {
        self.layer.cornerRadius = 3;
        self.layer.borderColor = RGBA(180, 180, 180, 1.0).CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        _ocrImg = [UIImageView new];
        _ocrImg.image = [UIImage imageNamed:@"top_nextocr"];
        _ocrImg.hidden = YES;
        
        _gaussianImg = [UIImageView new];
        _gaussianImg.image = [UIImage imageNamed:@"top_gaussianblur"];
        _gaussianImg.hidden = YES;
        
        _noteImg = [UIImageView new];
        _noteImg.image = [UIImage imageNamed:@"top_nextnote"];
        _noteImg.hidden = YES;
        
        _coverLab = [UILabel new];
        _coverLab.backgroundColor = [UIColor top_viewControllerBackGroundColor:RGBA(0, 0, 0, 0.6) defaultColor:RGBA(0, 0, 0, 0.3)];
        _coverLab.textColor = [UIColor whiteColor];
        _coverLab.font = [UIFont boldSystemFontOfSize:17];
        _coverLab.textAlignment = NSTextAlignmentCenter;
        _coverLab.adjustsFontSizeToFitWidth = YES;
        _coverLab.hidden = YES;
        
        [self addSubview:_ocrImg];
        [self addSubview:_noteImg];
        [self addSubview:_gaussianImg];
        [self addSubview:_coverLab];
        [self top_setupFream];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    _coverLab.backgroundColor = [UIColor top_viewControllerBackGroundColor:RGBA(0, 0, 0, 0.8) defaultColor:RGBA(0, 0, 0, 0.3)];
    if (!_coverLab.hidden) {
        self.layer.cornerRadius = 3;
        self.layer.borderColor = [UIColor top_viewControllerBackGroundColor:RGBA(0, 0, 0, 0.8) defaultColor:RGBA(0, 0, 0, 0.4)].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
    }else{
        self.layer.cornerRadius = 3;
        self.layer.borderColor = RGBA(180, 180, 180, 1.0).CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
    }
}
- (void)setNextModel:(DocumentModel *)nextModel{
    if ([TOPWHCFileManager top_isExistsAtPath:nextModel.ocrPath]) {
        _ocrImg.hidden = NO;
    }else{
        _ocrImg.hidden = YES;
    }
    
    if ([TOPWHCFileManager top_isExistsAtPath:nextModel.notePath]) {
        _noteImg.hidden = NO;
    }else{
        _noteImg.hidden = YES;
    }
    [self top_remarkFream];
}
- (void)top_setupFream{
    [_ocrImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-5);
        make.top.equalTo(self).offset(5);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    [_noteImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10-15);
        make.top.equalTo(self).offset(5);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    [_gaussianImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    [_coverLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)top_remarkFream{
    if (_ocrImg.hidden) {
        [_noteImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-5);
            make.top.equalTo(self).offset(5);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
    }else{
        [_noteImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-10-15);
            make.top.equalTo(self).offset(5);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
    }
}

- (void)setShowNum:(NSInteger)showNum{
    if (showNum>0) {
        _coverLab.hidden = NO;
        self.layer.cornerRadius = 3;
        self.layer.borderColor = [UIColor top_viewControllerBackGroundColor:RGBA(0, 0, 0, 0.8) defaultColor:RGBA(0, 0, 0, 0.4)].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
    }else{
        _coverLab.hidden = YES;
        self.layer.cornerRadius = 3;
        self.layer.borderColor = RGBA(180, 180, 180, 1.0).CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
    }
    _coverLab.text = [NSString stringWithFormat:@"+%ld",showNum];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
