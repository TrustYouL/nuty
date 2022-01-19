#define TitleW 130

#import "TOPPhotoEditView.h"
@interface TOPPhotoEditView()
@property (nonatomic ,strong) UIButton * currentSelectedBtn;
@property (nonatomic ,assign) NSInteger type;
@end
@implementation TOPPhotoEditView

- (instancetype)initWithFrame:(CGRect)frame withType:(int)type{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake((TOPScreenWidth-TitleW)/2, 0, TitleW, self.height)];
        titleLab.textColor = RGBA(51, 51, 51, 1.0);
        titleLab.font = [UIFont systemFontOfSize:18];
        titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab = titleLab;
        [self addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.bottom.equalTo(self);
            make.width.mas_equalTo(TitleW);
        }];
    }
    return self;
}
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}
- (NSMutableArray *)downBtnArray{
    if (!_downBtnArray) {
        _downBtnArray = [NSMutableArray new];
    }
    return _downBtnArray;
}
- (void)setEnterType:(TOPPhotoShowViewShowType)enterType{
    _enterType = enterType;
    if (enterType == TOPPhotoShowViewTextOCR) {
        self.titleLab.hidden = YES;
    }
}
- (void)top_creatView{
    if (self.type == 0) {
        for (UIButton * btn in self.btnArray) {
            [btn removeFromSuperview];
        }
        [self.btnArray removeAllObjects];
        if (self.enterType == TOPPhotoShowViewTextOCR && [self top_isShowOcrNumberButStates]) {
            [self top_setOcrNumberView];//有识别点数时
        }else{
            [self top_setChildView];
        }
    }
    
    if (self.type == 1) {
        for (UIButton * btn in self.downBtnArray) {
            [btn removeFromSuperview];
        }
        NSMutableArray * btnArray = [NSMutableArray new];
        for (int i = 0; i < self.downTitleArray.count; i ++) {
            CGFloat btnwidth = TOPScreenWidth / self.downTitleArray.count;
            CGFloat btnHeight = self.frame.size.height;
            CGFloat btnX = i * btnwidth;
            CGFloat btnY = 0;
            TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
            btn.frame = CGRectMake(btnX, btnY, btnwidth, btnHeight);
            [btn setImage:[UIImage imageNamed:self.downImgArray[i]] forState:UIControlStateNormal];
            [btn setTitle:self.downTitleArray[i] forState:UIControlStateNormal];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [btn.titleLabel setFont:[self fontsWithSize:12]];
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [btnArray addObject:btn];
            if (IS_IPAD) {
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.equalTo(self);
                    make.width.mas_equalTo(120);
                }];
            }else{
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.equalTo(self);
                    make.width.mas_equalTo(70);
                }];
            }
            btn.margin = UIEdgeInsetsMake(8, 0, 8, 0);
        }
        [self top_distributeSpacingHorizontallyWith:btnArray];
        self.downBtnArray = btnArray;
    }
    
    if (self.type == 2) {
        for (UIButton * btn in self.downBtnArray) {
            [btn removeFromSuperview];
        }
        self.backgroundColor = UIColor.orangeColor;
        for (int i = 0 ; i < 2; i ++) {
            TOPRoundedButton *btn = [[TOPRoundedButton alloc] init];
            [btn setBackgroundImage:[TOPAppTools  createImageWithColor:UIColor.whiteColor] forState:UIControlStateNormal];
            btn.tag = 100 + i;
            [btn addTarget:self action:@selector(top_photoEditAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [self.downBtnArray addObject:btn];
            if (i == 0) {
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.top.equalTo(self).offset(10);
                    make.width.height.mas_equalTo(40);
                }];
            }else{
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).offset(10);
                    make.trailing.equalTo(self).offset(-10);
                    make.width.height.mas_equalTo(40);
                }];
            }
        }
    }
    if (self.type == 3) {
        for (UIButton * btn in self.btnArray) {
            [btn removeFromSuperview];
        }
        [self.btnArray removeAllObjects];
    }
}

- (BOOL )top_isShowOcrNumberButStates
{
    BOOL  upArrayStates;
    if ([TOPSubscriptTools getSubscriptStates] ) {
        if ([TOPSubscriptTools getCurrentSubscriptIdentifyNum] > 0) {
            upArrayStates = NO;
        }else{
            upArrayStates = YES;
        }
    }else{
        if ([TOPSubscriptTools getCurrentFreeIdentifyNum]>0 || [TOPSubscriptTools getCurrentUserBalance] >0) {
            upArrayStates = YES;
        }else{
            upArrayStates = NO;
        }
    }
    return upArrayStates;
}
- (void)top_changeCutBtnState:(BOOL)isShow{
    _cutBtn.hidden = isShow;
}

- (void)top_upAction:(UIButton*)btn{
   
    if (self.photoEditUpClickHandler) {
        self.photoEditUpClickHandler(btn.tag - 100);
    }
}
- (void)top_downAction:(UIButton*)btn{
   
    if (self.photoEditDownClickHandler) {
        self.photoEditDownClickHandler(btn.tag - 1000);
    }
}

- (void)top_photoEditAction:(UIButton*)btn{
    if (self.photoEditOneHandler) {
        self.photoEditOneHandler(btn.tag - 100);
    }
}

- (void)top_resetBtnState:(UIButton *)btn{
    NSDictionary * languageDic = [TOPScanerShare top_saveOcrLanguage];
    if (languageDic.allKeys.count>0) {
        NSString * lang = languageDic.allValues[0];
        //显示的是大写字母
        NSString * langUpString = lang.uppercaseString;
        CGFloat langW = [TOPDocumentHelper top_getSizeWithStr:langUpString Height:44 Font:16].width;
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:langUpString forState:UIControlStateNormal];
        btn.frame = CGRectMake(TOPScreenWidth-15-50-langW-20, 11, langW+20, 22);
        [self top_specialButtonLayer:btn];
        [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-65);
            make.top.equalTo(self).offset(11);
            make.width.mas_equalTo(langW+20);
            make.height.mas_equalTo(22);
        }];
    }
}
- (void)top_specialButtonLayer:(UIButton *)btn{
    if ([TOPDocumentHelper top_isdark]) {
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3;
        btn.layer.borderWidth = 1.5;
        btn.layer.borderColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)].CGColor;
        [btn setTitleColor:[UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    }else{
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3;
        btn.layer.borderWidth = 1.5;
        btn.layer.borderColor = RGBA(51, 51, 51, 1.0).CGColor;
        [btn setTitleColor:RGBA(51, 51, 51, 1.0) forState:UIControlStateNormal];
    }
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    if (self.enterType == TOPPhotoShowViewTextOCR) {
        [self top_specialButtonLayer:_cutBtn];
    }
}
#pragma mark-- 没有余额时视图设置
- (void)top_setChildView{
    for (int i = 0; i< self.upArray.count; i ++) {
        CGFloat btnwidth = 50;
        CGFloat btnHeight = 44;
        CGFloat btnX = TOPScreenWidth-15-(self.upArray.count-i)*btnwidth;
        CGFloat btnY = 0;
        UIButton * btn = [UIButton new];
        if (i == 0) {
            TOPImageTitleButtonStyle  btnType;
            if (isRTL()) {
                btnType = EImageLeftTitleRightCenter;
            }else{
                btnType = EImageLeftTitleRightLeft;
            }
            btn = [[TOPImageTitleButton alloc] initWithStyle:(btnType)];
            btn.adjustsImageWhenHighlighted = NO;
            btn.frame = CGRectMake((15), btnY, 44, btnHeight);
            
            [btn setImage:[UIImage imageNamed:self.upArray[i]] forState:UIControlStateNormal];
            [self addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self).offset(15.0);
                make.top.bottom.equalTo(self);;
                make.width.mas_equalTo(44);
            }];
        }else{
            btn = [[TOPImageTitleButton alloc] initWithStyle:(ETitleLeftImageRightCenter)];
            btn.frame = CGRectMake(btnX, btnY, btnwidth, btnHeight);
            [self addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self).offset(-(15+(self.upArray.count-i-1)*btnwidth));
                make.top.bottom.equalTo(self);
                make.width.mas_equalTo(btnwidth);
            }];
            if (i == 1) {
                if (self.enterType == TOPPhotoShowViewTextOCR) {
                    [self top_resetBtnState:btn];
                }else{
                    [btn setImage:[UIImage imageNamed:self.upArray[i]] forState:UIControlStateNormal];
                }
                _cutBtn = btn;
            }else{
                [btn setImage:[UIImage imageNamed:self.upArray[i]] forState:UIControlStateNormal];
                if (i == 2) {
                    _nextBtn = btn;
                }
            }
        }
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(top_upAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArray addObject:btn];
    }
}
#pragma mark -- ocr识别页面时 初始化按钮子视图
- (void)top_setOcrNumberView{
    for (int i = 0; i< self.upArray.count; i ++) {
        UIButton * btn = [UIButton new];
        if (i == 0) {
            TOPImageTitleButtonStyle  btnType;
            if (isRTL()) {
                btnType = EImageLeftTitleRightCenter;
            }else{
                btnType = EImageLeftTitleRightLeft;
            }
            btn = [[TOPImageTitleButton alloc] initWithStyle:(btnType)];
            btn.adjustsImageWhenHighlighted = NO;
            [btn setImage:[UIImage imageNamed:self.upArray[i]] forState:UIControlStateNormal];
            [self addSubview:btn];
        }else{
            if (i==1) {
                btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRight)];
            }else{
                btn = [[TOPImageTitleButton alloc] initWithStyle:(ETitleLeftImageRightCenter)];
            }
            [self addSubview:btn];
            if (i == 2) {
                _cutBtn = btn;
            }else{
                [btn setImage:[UIImage imageNamed:self.upArray[i]] forState:UIControlStateNormal];
                if (i == 3) {
                    _nextBtn = btn;
                }
            }
        }
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(top_upAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArray addObject:btn];
        if (i == self.upArray.count-1) {
            [self top_setTextOCRFream];
        }
    }
}
#pragma mark -- ocr识别页面时 设置约束
- (void)top_setTextOCRFream{
    if (self.btnArray.count==4) {
        CGFloat btnwidth = 50;
        CGFloat btnHeight = 44;
        TOPImageTitleButton * btn1 = self.btnArray[0];
        TOPImageTitleButton * btn2 = self.btnArray[1];
        TOPImageTitleButton * btn3 = self.btnArray[2];
        TOPImageTitleButton * btn4 = self.btnArray[3];
        [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(15.0);
            make.top.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(btnHeight, btnHeight));
        }];
        [btn4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-15);
            make.top.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(btnwidth, btnHeight));
        }];
        [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(btn4.mas_leading);
            make.top.equalTo(self).offset(11);
            make.size.mas_equalTo(CGSizeMake([self top_getlangW:btn3]+20, 22));
        }];
        [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(btn3.mas_leading).offset(-10);
            make.top.equalTo(self).offset(11);
            make.size.mas_equalTo(CGSizeMake([self top_getBalanalW:btn2]+25, 22));
        }];
    }
}
#pragma mark -- 计算语言按钮的长度 并设置layer属性
- (CGFloat)top_getlangW:(UIButton *)btn{
    CGFloat langW = 0;
    NSDictionary * languageDic = [TOPScanerShare top_saveOcrLanguage];
    if (languageDic.allKeys.count>0) {
        NSString * lang = languageDic.allValues[0];
        //显示的是大写字母
        NSString * langUpString = lang.uppercaseString;
        langW = [TOPDocumentHelper top_getSizeWithStr:langUpString Height:44 Font:16].width;
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:langUpString forState:UIControlStateNormal];
        [self top_specialButtonLayer:btn];
    }
    return langW;
}
#pragma mark -- 计算识别余额按钮的长度 并设置属性
- (CGFloat)top_getBalanalW:(UIButton *)btn{
    CGFloat langW = 0;
    NSInteger currentBalance = [TOPSubscriptTools getCurrentUserBalance];
    NSString * currentIdentify = [NSString stringWithFormat:@"%ld",currentBalance];
    if (![TOPSubscriptTools getSubscriptStates]) {
        if (currentBalance <=0) {
            currentIdentify = [NSString stringWithFormat:@"%ld",[TOPSubscriptTools getCurrentFreeIdentifyNum]];
        }
    }
    langW = [TOPDocumentHelper top_getSizeWithStr:currentIdentify Height:44 Font:16].width;
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:currentIdentify forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    return langW;
}

@end
