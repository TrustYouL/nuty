#define EditTagsView_W 250
#define  FormatterView_Y 150
#define  ShowTimeView_H 250

#import "TOPSettingDocNameVC.h"
#import "TOPDocNameShowView.h"
#import "TOPNextSettingShowView.h"
@interface TOPSettingDocNameVC ()
@property (nonatomic,strong)TOPDocNameShowView * nameShow;
@property (nonatomic,strong)TOPNextSettingShowView * showFormatterView;
@property (nonatomic,strong)TOPNextSettingShowView * showTimeView;
@property (nonatomic,copy)NSString * formatString;
@property (nonatomic,strong)UIView * backView;
@property (nonatomic,strong)UIButton * nameBtn;
@property (nonatomic,strong)UIButton * timeBtn;
@property (nonatomic,strong)UILabel * numLab1;
@property (nonatomic,strong)UILabel * numLab2;

@end

@implementation TOPSettingDocNameVC

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"topscan_settingdocname", @"");
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self top_configBackItemWithSelector:@selector(top_clickBack)];
    [self top_setupUI];
    [self top_setDefaultData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
}
- (void)top_setupUI{
    [self.view addSubview:self.nameShow];
    [self.nameShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(30);
        make.size.mas_equalTo(CGSizeMake(EditTagsView_W, EditTagsView_W));
    }];
    
    UILabel * numLab1 = [UILabel new];
    numLab1.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    numLab1.textAlignment = NSTextAlignmentCenter;
    numLab1.font = [self fontsWithSize:15];
    numLab1.backgroundColor = [UIColor clearColor];
    numLab1.layer.cornerRadius = 20/2;
    numLab1.layer.borderColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)].CGColor;
    numLab1.layer.borderWidth = 0.5;
    numLab1.text = @"1";
    self.numLab1 = numLab1;
    
    UILabel * titleLab1 = [UILabel new];
    titleLab1.font = [UIFont systemFontOfSize:16];
    titleLab1.textAlignment = NSTextAlignmentNatural;
    titleLab1.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    titleLab1.text = NSLocalizedString(@"topscan_settingdocname", @"");
    
    UILabel * numLab2 = [UILabel new];
    numLab2.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    numLab2.textAlignment = NSTextAlignmentCenter;
    numLab2.font = [self fontsWithSize:15];
    numLab2.backgroundColor = [UIColor clearColor];
    numLab2.layer.cornerRadius = 20/2;
    numLab2.layer.borderColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)].CGColor;
    numLab2.layer.borderWidth = 0.5;
    numLab2.text = @"2";
    self.numLab2 = numLab2;
    
    UILabel * titleLab2 = [UILabel new];
    titleLab2.font = [UIFont systemFontOfSize:16];
    titleLab2.textAlignment = NSTextAlignmentNatural;
    titleLab2.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    titleLab2.text = NSLocalizedString(@"topscan_settingdoctime", @"");

    TOPImageTitleButton * btn1 = [[TOPImageTitleButton alloc]initWithFrame:CGRectZero];
    btn1.style = ETitleLeftImageRightCenter;
    btn1.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    btn1.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn1 setTitleColor:[UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(top_chooseDocName) forControlEvents:UIControlEventTouchUpInside];
    btn1.layer.masksToBounds = YES;
    btn1.layer.cornerRadius = 5;
    self.nameBtn = btn1;
    
    TOPImageTitleButton * btn2 = [[TOPImageTitleButton alloc]initWithFrame:CGRectZero];
    btn2.style = ETitleLeftImageRightCenter;
    btn2.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    btn2.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn2 setTitleColor:[UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(top_chooseDocTime) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.masksToBounds = YES;
    btn2.layer.cornerRadius = 5;
    self.timeBtn = btn2;
    
    [self.view addSubview:numLab1];
    [self.view addSubview:numLab2];
    [self.view addSubview:titleLab1];
    [self.view addSubview:titleLab2];
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    CGFloat titleW = 0;
    if (IS_IPAD) {
        titleW = 125;
    }else{
        titleW = 280;
    }
    [titleLab1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.nameShow.mas_bottom).offset(2);
        make.size.mas_equalTo(CGSizeMake(titleW, 20));
    }];
    
    [numLab1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLab1.mas_centerY);
        make.trailing.equalTo(titleLab1.mas_leading).offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab1.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    [titleLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(btn1.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(titleW, 20));
    }];
    
    [numLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLab2.mas_centerY);
        make.trailing.equalTo(titleLab2.mas_leading).offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab2.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.numLab1.layer.cornerRadius = 20/2;
    self.numLab1.layer.borderColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)].CGColor;
    self.numLab1.layer.borderWidth = 0.5;
    
    self.numLab2.layer.cornerRadius = 20/2;
    self.numLab2.layer.borderColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)].CGColor;
    self.numLab2.layer.borderWidth = 0.5;
}
- (void)top_setDefaultData{
    TOPSettingFormatModel * formatterModel  = [TOPSettingFormatModel new];
    formatterModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingFormatter_Path];
    NSLog(@"formatString==%@",formatterModel.formatString);
    NSString * nameStr = [TOPDocumentHelper top_getCurrentFormatterTime:formatterModel.formatString];
    NSString * timeStr = [TOPDocumentHelper top_getCurrentTimeAndSendFormatterString:[TOPScanerShare top_documentDateType]];
    [self.nameBtn setTitle:nameStr forState:UIControlStateNormal];
    [self.timeBtn setTitle:timeStr forState:UIControlStateNormal];
    self.nameShow.docName = nameStr;
}

- (void)top_chooseDocName{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [self top_markupCoverMask];
    [keyWindow addSubview:self.showFormatterView];
    [self.showFormatterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.equalTo(keyWindow.mas_height).offset(TOPNavBarAndStatusBarHeight+30+EditTagsView_W+25+50);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        [self.showFormatterView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.top.equalTo(keyWindow).offset(TOPNavBarAndStatusBarHeight+30+EditTagsView_W+25+50);
            make.bottom.equalTo(keyWindow).offset(10);
        }];
        [keyWindow layoutIfNeeded];
    }];
}

- (void)top_chooseDocTime{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [self top_markupCoverMask];
    [keyWindow addSubview:self.showTimeView];
    [self.showTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.mas_equalTo(ShowTimeView_H);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        [self.showTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.bottom.equalTo(keyWindow).offset(10);
            make.height.mas_equalTo(ShowTimeView_H);
        }];
        [keyWindow layoutIfNeeded];
    }];
}
- (void)top_clickBack{
    if (self.top_backAction) {
        self.top_backAction(self.formatString);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)top_settingView_ClickTap{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
        if (self->_showFormatterView) {
            [self.showFormatterView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(keyWindow);
                make.top.equalTo(keyWindow.mas_bottom);
                make.height.equalTo(keyWindow.mas_height).offset(TOPNavBarAndStatusBarHeight+FormatterView_Y-10);
            }];
        }

        if (self->_showTimeView) {
            [self.showTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(keyWindow);
                make.top.equalTo(keyWindow.mas_bottom);
                make.height.mas_equalTo(ShowTimeView_H);
            }];
        }
        [keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        [self.showFormatterView removeFromSuperview];
        [self.showTimeView removeFromSuperview];
        
        self.backView = nil;
        self.showFormatterView = nil;
        self.showTimeView = nil;
    }];
}
- (TOPDocNameShowView *)nameShow{
    if (!_nameShow) {
        _nameShow = [[TOPDocNameShowView alloc]initWithFrame:CGRectMake((TOPScreenWidth-EditTagsView_W)/2, 30, EditTagsView_W, EditTagsView_W)];
    }
    return _nameShow;
}
#pragma mark -- 文件名称弹窗
- (TOPNextSettingShowView *)showFormatterView{
    WS(weakSelf);
    if (!_showFormatterView) {
        _showFormatterView = [[TOPNextSettingShowView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-FormatterView_Y+10)];
        _showFormatterView.enterType = TOPFormatterViewEnterTypeSetting;
        _showFormatterView.top_clickToDismiss = ^{
            [weakSelf top_settingView_ClickTap];
        };
        
        _showFormatterView.top_clickCell = ^(NSString * _Nonnull formatString) {
            NSLog(@"formatString==%@",formatString);
            weakSelf.formatString = formatString;
            NSString * showName = [TOPDocumentHelper top_getCurrentFormatterTime:formatString];
            weakSelf.nameShow.docName = showName;
            [weakSelf.nameBtn setTitle:showName forState:UIControlStateNormal];
            [weakSelf top_settingView_ClickTap];
        };
    }
    return _showFormatterView;
}
- (TOPNextSettingShowView *)showTimeView{
    WS(weakSelf);
    if (!_showTimeView) {
        _showTimeView = [[TOPNextSettingShowView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-FormatterView_Y+10)];
        _showTimeView.enterType = TOPFormatterViewEnterTypeDocTime;
        _showTimeView.top_clickToDismiss = ^{
            [weakSelf top_settingView_ClickTap];
        };
        
        _showTimeView.top_clickCell = ^(NSString * _Nonnull formatString) {
            weakSelf.nameShow.doctime = formatString;
            [weakSelf.timeBtn setTitle:formatString forState:UIControlStateNormal];
            [weakSelf top_settingView_ClickTap];
        };
    }
    return _showTimeView;
}
- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_settingView_ClickTap)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

@end
