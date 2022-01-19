#import "TopEditFolderAndDocNameVC.h"

@interface TopEditFolderAndDocNameVC ()<UITextFieldDelegate>
@property (nonatomic ,strong)UITextField * nameField;
@end

@implementation TopEditFolderAndDocNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.editType == TopFileNameEditTypeChangeDocName||self.editType == TopFileNameEditTypeChangeFolderName) {
        self.title = @"重命名文档";
    }else{
        self.title = NSLocalizedString(@"topscan_newfolderprompt", @"");
    }
    [self top_setupUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:TOPAPPGreenColor}];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_adaptationSystemUpgrade];
}
#pragma mark -- 适配系统更新
- (void)top_adaptationSystemUpgrade {
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:TOPAPPGreenColor,
                              NSFontAttributeName:[UIFont systemFontOfSize:18]};
    if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        appearance.titleTextAttributes = textAtt;
        appearance.shadowColor = [UIColor clearColor];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    } else {
        [self.navigationController.navigationBar setTitleTextAttributes:textAtt];
    }
}
- (void)top_setupUI{
    TOPImageTitleButton * leftBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    leftBtn.tag = 1000+1;
    leftBtn.frame = CGRectMake(0, 0, 44, 60);
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    TOPImageTitleButton * rightBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    rightBtn.tag = 1000+2;
    rightBtn.frame = CGRectMake(0, 0, 44, 60);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitle:NSLocalizedString(@"topscan_batchsave", @"") forState:UIControlStateNormal];
    [rightBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    UIImageView * picImg = [UIImageView new];
    picImg.image = [UIImage imageNamed:self.picName];

    UITextField * nameField = [UITextField new];
    [nameField becomeFirstResponder];
    nameField.delegate=self;
    nameField.textAlignment = NSTextAlignmentCenter;
    nameField.font=[UIFont systemFontOfSize:15];
    nameField.returnKeyType=UIReturnKeyDone;
    nameField.keyboardType=UIKeyboardTypeDefault;
    nameField.backgroundColor=[UIColor clearColor];
    nameField.tintColor = TOPAPPGreenColor;
    nameField.inputAccessoryView = [UIView new];
    nameField.text = self.defaultString;
    nameField.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(210, 210, 210, 1.0)];
    nameField.layer.cornerRadius = 45/2;
    nameField.layer.masksToBounds = YES;
    
    self.nameField = nameField;
    [self.view addSubview:picImg];
    [self.view addSubview:nameField];
    
    CGFloat topH = (100*TOPScreenHeight)/667.0;
    [picImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(topH);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(85, 80));
    }];
    [nameField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(picImg.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(240, 45));
    }];
}
- (void)top_clickBtn:(UIButton *)sender{
    if (sender.tag == 1002) {
        if (self.top_clickToSendString) {
            self.top_clickToSendString(self.nameField.text);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.top_clickToSendString) {
        self.top_clickToSendString(self.nameField.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

@end
