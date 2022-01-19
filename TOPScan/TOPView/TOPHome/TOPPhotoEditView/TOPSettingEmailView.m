#define Cell_H 60

#import "TOPSettingEmailView.h"
#import "TOPSettingEmailCell.h"
#import "TOPSettingEmailModel.h"
@interface TOPSettingEmailView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)NSString * emailField;
@property (nonatomic ,strong)NSString * toField;
@property (nonatomic ,strong)NSString * subjectField;
@property (nonatomic ,strong)NSString * bodyField;
@property (nonatomic ,strong)NSMutableArray * emailArray;
@property (nonatomic ,strong)TOPSettingEmailModel * emailModel;
@property (nonatomic ,assign)BOOL isKeyBoardHide;//视图下移时移除键盘
@end

@implementation TOPSettingEmailView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.emailModel = [TOPSettingEmailModel new];
        self.emailModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingEmail_Path];
        self.emailField = self.emailModel.myselfEmail;
        self.toField = self.emailModel.toEmail;
        self.subjectField = self.emailModel.subject;
        self.bodyField = self.emailModel.body;
        self.isKeyBoardShow = NO;
        self.isKeyBoardHide = NO;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        UIButton * saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-90, 0, 80, 60)];
        saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [saveBtn setTitle:NSLocalizedString(@"topscan_batchsave", @"") forState:UIControlStateNormal];
        [saveBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(top_clickOkBtn) forControlEvents:UIControlEventTouchUpInside];
        
        //cancel按钮
        UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        [cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [cancelBtn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:cancelBtn];
        [self addSubview:saveBtn];
        [self addSubview:self.tableView];
        
        [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-30);
            make.top.equalTo(self);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(60);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(15);
            make.trailing.equalTo(self).offset(-15);
            make.top.equalTo(self).offset(60);
            make.bottom.equalTo(self).offset(-20);
        }];
         
    }
    return self;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(15, 60, self.bounds.size.width-30, self.bounds.size.height-80) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.layer.cornerRadius = 10;
        _tableView.layer.masksToBounds = YES;
        [_tableView registerClass:[TOPSettingEmailCell class] forCellReuseIdentifier:NSStringFromClass([TOPSettingEmailCell class])];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPSettingEmailCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSettingEmailCell class]) forIndexPath:indexPath];
    cell.model = self.emailModel;
    cell.row = indexPath.row;
    cell.isKeyBoardShow = self.isKeyBoardShow;
    cell.isKeyBoardHide = self.isKeyBoardHide;
    WS(weakSelf);
    cell.top_beginEdit = ^(NSInteger row) {
        //改变view的坐标
        if (weakSelf.top_keyboardToChangeFream) {
            weakSelf.top_keyboardToChangeFream();
        }
    };
    
    cell.top_sendTextFieldText = ^(NSString * _Nonnull text, NSInteger row) {
        if (row == 0) {
            weakSelf.emailField = text;
        }else if (row == 1){
            weakSelf.toField = text;

        }else if (row == 2){
            weakSelf.subjectField = text;

        }else{
            weakSelf.bodyField = text;
        }
    };
    
    cell.top_returnEdit = ^{
        if (weakSelf.top_returnToOriginalFream) {
            weakSelf.top_returnToOriginalFream();
        }
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, Cell_H)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        return 70;
    }
    return Cell_H;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)top_clickOkBtn{
    TOPSettingEmailModel * model = [TOPSettingEmailModel new];
    if ([TOPDocumentHelper top_validateEmail:self.emailField]||self.emailField.length == 0) {
        model.myselfEmail = self.emailField;
    }else{
        model.myselfEmail = self.emailModel.myselfEmail;
    }
    
    if ([TOPDocumentHelper top_validateEmail:self.toField]||self.toField.length == 0) {
        model.toEmail = self.toField;
    }else{
        model.toEmail = self.emailModel.toEmail;
    }
    
    model.subject = self.subjectField;
    model.body = self.bodyField;
    self.emailModel = model;
    
    BOOL suc = [NSKeyedArchiver archiveRootObject:self.emailModel toFile:TOPSettingEmail_Path];
    if (suc) {
        NSLog(@"suc归档成功");
    }else{
        NSLog(@"归档失败");
    }
    
    self.isKeyBoardHide = YES;
    [self.tableView reloadData];
    if (self.top_clickToDismiss) {
        self.top_clickToDismiss();
    }
    
    if ((![TOPDocumentHelper top_validateEmail:_emailField]&&_emailField.length !=0)||(![TOPDocumentHelper top_validateEmail:_toField]&&_toField.length !=0)) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_questioninvalidemail", @"")];
        [SVProgressHUD dismissWithDelay:1.5];
    }
    
}

- (void)top_clickCancelBtn{
    self.isKeyBoardHide = YES;
    [self.tableView reloadData];
    if (self.top_clickToDismiss) {
        self.top_clickToDismiss();
    }
}

- (void)setIsKeyBoardShow:(BOOL)isKeyBoardShow{
    _isKeyBoardShow = isKeyBoardShow;
    [self.tableView reloadData];
}

@end
