#import "TOPEditSelectedHeaderView.h"

@interface TOPEditSelectedHeaderView ()
@property(nonatomic,strong)UILabel  *chooseLabel;
@property(nonatomic,strong)UIButton *cancelBtn;
@property(nonatomic,strong)NSMutableArray *btnArray;

@end

@implementation TOPEditSelectedHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
        [self top_configContentView];
    }
    return self;
}

- (void)top_allChoseAction {
    self.allSelectBtn.selected = !self.allSelectBtn.selected;
    if (self.top_selectAllHandler) {
        self.top_selectAllHandler(self.allSelectBtn.selected);
    }
}

- (void)top_cancleAction {
    if (self.top_cancleEditHandler) {
        self.top_cancleEditHandler();
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.chooseLabel.text = title;
}

- (void)top_configContentView {
    [self addSubview:self.allSelectBtn];
    [self addSubview:self.chooseLabel];
    [self addSubview:self.cancelBtn];
    
    [self.allSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-20);
        make.top.bottom.equalTo(self).offset(0);
        make.width.mas_equalTo(80);
    }];
    
    [self.chooseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(100);
        make.trailing.equalTo(self).offset(-100);
        make.top.bottom.equalTo(self).offset(0);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.top.bottom.equalTo(self).offset(0);
        make.width.mas_equalTo(80);
    }];
}

- (UIButton*)allSelectBtn{
    if (!_allSelectBtn) {
        _allSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allSelectBtn.frame = CGRectMake(TOPScreenWidth - (100), TOPStatusBarHeight + 5,  (80), (30));
        [_allSelectBtn setTitle:NSLocalizedString(@"topscan_allselect", @"") forState:UIControlStateNormal];
        [_allSelectBtn setTitle:NSLocalizedString(@"topscan_cancelallselect", @"") forState:UIControlStateSelected];
        _allSelectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _allSelectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_allSelectBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
        [_allSelectBtn setTitleColor:kTopicBlueColor forState:UIControlStateHighlighted];
        [_allSelectBtn addTarget:self action:@selector(top_allChoseAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _allSelectBtn;
}

- (UIButton*)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, TOPStatusBarHeight + 5, (80), (30));
        [_cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(top_cancleAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelBtn;
}


- (UILabel*)chooseLabel{
    if (!_chooseLabel) {
        _chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake((100) , TOPStatusBarHeight + 8, TOPScreenWidth - (200), (18))];
        _chooseLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
        _chooseLabel.font = [self fontsWithSize:17];
        _chooseLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _chooseLabel;;
}

@end
