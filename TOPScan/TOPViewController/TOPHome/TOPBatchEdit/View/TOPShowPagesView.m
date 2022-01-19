#import "TOPShowPagesView.h"

@implementation TOPShowPagesView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _pageLab = [UILabel new];
        _pageLab.textColor = [UIColor whiteColor];
        _pageLab.backgroundColor = TOPAPPGreenColor;
        _pageLab.font = [UIFont systemFontOfSize:12];
        _pageLab.textAlignment = NSTextAlignmentCenter;
        _pageLab.layer.cornerRadius = 25/2;
        _pageLab.layer.masksToBounds = YES;
        
        _leftBtn = [UIButton new];
        _leftBtn.tag = 1000+0;
        if (isRTL()) {
            [_leftBtn setImage:[UIImage imageNamed:@"top_scamerbatch_rightrow"] forState:UIControlStateNormal];
        }else{
            [_leftBtn setImage:[UIImage imageNamed:@"top_scamerbatch_leftrow"] forState:UIControlStateNormal];
        }
        [_leftBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _rightBtn = [UIButton new];
        _rightBtn.tag = 1000+1;
        if (isRTL()) {
            [_rightBtn setImage:[UIImage imageNamed:@"top_scamerbatch_leftrow"] forState:UIControlStateNormal];
        }else{
            [_rightBtn setImage:[UIImage imageNamed:@"top_scamerbatch_rightrow"] forState:UIControlStateNormal];
        }
        [_rightBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pageLab];
        [self addSubview:_leftBtn];
        [self addSubview:_rightBtn];
    }
    return self;
}

- (void)top_setFream{
    NSString * showString = [NSString stringWithFormat:@"%ld/%ld",_currentIndex,_allCount];
    CGFloat sizeW = [TOPDocumentHelper top_getSizeWithStr:showString Height:25 Font:12].width+30;
    [_pageLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(sizeW, 25));
    }];
    [_leftBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_pageLab.mas_leading).offset(-13);
        make.centerY.equalTo(_pageLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    [_rightBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_pageLab.mas_trailing).offset(13);
        make.centerY.equalTo(_pageLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];

    _pageLab.text = showString;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    [self top_setFream];
    if (currentIndex == 1) {
        _leftBtn.hidden = YES;
    }else{
        _leftBtn.hidden = NO;
    }
    
    if (currentIndex == _allCount) {
        _rightBtn.hidden = YES;
    }else{
        _rightBtn.hidden = NO;
    }
}

- (void)setCameraIndex:(NSInteger)cameraIndex{
    if (cameraIndex == 0) {
        _leftBtn.hidden = YES;
    }else{
        _leftBtn.hidden = NO;
    }
    
    if (cameraIndex == _allCount) {
        _rightBtn.hidden = YES;
    }else{
        _rightBtn.hidden = NO;
    }
}

- (void)top_clickBtn:(UIButton *)sender{
    if (self.top_showPageAction) {
        self.top_showPageAction(sender.tag-1000);
    }
}


@end
