#import "TOPScameraBatchBottomView.h"
@interface TOPScameraBatchBottomView()
@property (nonatomic,strong)NSMutableArray * btnArray;
@property (nonatomic,strong)UIButton * filterBtn;
@end
@implementation TOPScameraBatchBottomView

- (instancetype)initWithFrame:(CGRect)frame sendPic:(NSArray *)picArray {
    if (self = [super initWithFrame:frame]) {
        [self top_setUpBootomViewAndsendPicArray:picArray];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame sendPic:(NSArray *)picArray itemNames:(NSArray *)names {
    if (self = [super initWithFrame:frame]) {
        _normalStateColor = kCommonBlackTextColor;
        [self top_setUpBootomViewAndsendPicArray:picArray sendNameArray:names];
    }
    return self;
}

- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}

- (void)top_setUpBootomViewAndsendPicArray:(NSArray *)picArray{
    TOPImageTitleButton *lastBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
    UIImage *btnImg = [UIImage imageNamed:picArray[picArray.count-1]];
    [lastBtn setImage:btnImg forState:UIControlStateNormal];
    lastBtn.frame = CGRectMake((TOPScreenWidth-90)+15, 7, 60, 39);
    lastBtn.backgroundColor = [UIColor clearColor];
    lastBtn.tag = 1000 + picArray.count-1;
    [lastBtn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lastBtn];
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-15);
        make.height.mas_equalTo(39);
        make.width.mas_equalTo(60);
    }];
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth-90, self.height)];
    bgView.backgroundColor = [UIColor clearColor];//[UIColor whiteColor];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self);
        make.trailing.equalTo(lastBtn.mas_leading);
    }];

    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i < picArray.count-1; i ++) {
        TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(ETitleLeftImageRightCenter)];
        UIImage *btnImg = [UIImage imageNamed:picArray[i]];
        [btn setImage:btnImg forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        [self.btnArray addObject:btn];
        [tempArray addObject:btn];
        
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
    }
    [self.btnArray addObject:lastBtn];
    [bgView top_distributeSpacingHorizontallyWith:tempArray];
}

- (void)top_setUpBootomViewAndsendPicArray:(NSArray *)picArray sendNameArray:(NSArray *)nameArray{
    TOPImageTitleButton *lastBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
    UIImage *btnImg = [UIImage imageNamed:picArray[picArray.count-1]];
    [lastBtn setImage:btnImg forState:UIControlStateNormal];
    lastBtn.frame = CGRectMake((TOPScreenWidth-90)+15, 7, 60, 39);
    lastBtn.backgroundColor = [UIColor clearColor];
    lastBtn.tag = 1000 + picArray.count-1;
    [lastBtn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lastBtn];
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-15);
        make.height.mas_equalTo(39);
        make.width.mas_equalTo(60);
    }];
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth-90, self.height)];
    bgView.backgroundColor = [UIColor clearColor];//[UIColor whiteColor];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self);
        make.trailing.equalTo(lastBtn.mas_leading);
    }];
    
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i < picArray.count - 1; i ++) {
        TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
        UIImage *btnImg = [UIImage imageNamed:picArray[i]];
        [btn setImage:btnImg forState:UIControlStateNormal];
        [btn setTitle:nameArray[i] forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [btn.titleLabel setFont:[self fontsWithSize:10]];
        [btn setTitleColor:_normalStateColor forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = 1000 + i;

        [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        [self.btnArray addObject:btn];
        [tempArray addObject:btn];
        
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
        btn.margin = UIEdgeInsetsMake(5, 0,0, 0);
        btn.padding = CGSizeMake(0, -3);
    }
    [self.btnArray addObject:lastBtn];
    [bgView top_distributeSpacingHorizontallyWith:tempArray];//按钮的等间距设置
}

- (void)top_changeBtnState:(BOOL)enable{
    for (int i = 0; i<self.btnArray.count; i++) {
        TOPImageTitleButton *btn = self.btnArray[i];
        if (enable) {
            UIImage *btnImg = [UIImage imageNamed:self.normalArray[i]];
            [btn setImage:btnImg forState:UIControlStateNormal];
            btn.enabled = enable;
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:_normalStateColor] forState:UIControlStateNormal];
        }else{
            UIImage *btnImg = [UIImage imageNamed:self.reEditArray[i]];
            [btn setImage:btnImg forState:UIControlStateNormal];
            btn.enabled = enable;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
}

- (void)top_changeFinishBtnState:(BOOL)enable{
    for (int i = 0; i<self.btnArray.count; i++) {
        TOPImageTitleButton *btn = self.btnArray[i];
        UIImage *btnImg = [UIImage imageNamed:self.reEditArray[i]];
        [btn setImage:btnImg forState:UIControlStateNormal];
        if (i == self.btnArray.count-1) {
            btn.enabled = enable;
        }else{
            btn.enabled = NO;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
}

- (void)top_changeFilterBtnSelectState:(BOOL)select atIndex:(NSInteger)index {
    if (self.btnArray.count > index) {
        TOPImageTitleButton *btn = self.btnArray[index];
        if (select) {
            UIImage *btnImg = self.selectFilterItem.length > 0 ? [UIImage imageNamed:self.selectFilterItem] : [UIImage imageNamed:@"top_scamerbatch_filterSelect"];
            [btn setImage:btnImg forState:UIControlStateNormal];
            [btn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
        }else{
            if (btn.enabled) {
                UIImage *btnImg = [UIImage imageNamed:self.normalArray[index]];
                [btn setImage:btnImg forState:UIControlStateNormal];
            }else{
                UIImage *btnImg = [UIImage imageNamed:self.reEditArray[index]];
                [btn setImage:btnImg forState:UIControlStateNormal];
            }
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:_normalStateColor] forState:UIControlStateNormal];
        }
    }
}
- (void)top_downAction:(UIButton *)btn{
    if (self.top_longPressBootomItemHandler) {
        self.top_longPressBootomItemHandler(btn.tag - 1000);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
