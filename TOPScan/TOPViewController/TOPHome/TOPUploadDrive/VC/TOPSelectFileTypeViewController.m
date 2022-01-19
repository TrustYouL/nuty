 #import "TOPSelectFileTypeViewController.h"
#import "TOPSelectFileTypeTableViewCell.h"
#import "TOPUploadFileDriveCollectionVC.h"

@interface TOPSelectFileTypeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic ,strong)NSMutableArray * iconArray;
@property (nonatomic ,assign)NSInteger  currentIndex;
@end

@implementation TOPSelectFileTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    self.dataArray = [NSMutableArray arrayWithArray:@[@"PDF",@"JPG",@"PDF&JPG"]];
    self.iconArray = [NSMutableArray arrayWithArray:@[@"top_drive_select_filetype_pdf",@"top_drive_select_filetype_jpg",@"top_drive_select_filetype_double"]];

    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
        
    }];

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:NSLocalizedString(@"topscan_questioncontinue", @"") forState:UIControlStateNormal];
    [confirmButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    confirmButton.titleLabel.font = PingFang_R_FONT_(16);
    [confirmButton setBackgroundColor:TOPAPPGreenColor];
    [self.view addSubview:confirmButton];
    [confirmButton addTarget:self action:@selector(top_confirmClick:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius= 7;
    confirmButton.clipsToBounds = YES;
    
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-10-TOPBottomSafeHeight);
        make.leading.equalTo(self.view).offset(25);
        make.trailing.equalTo(self.view).offset(-25);
        make.height.mas_offset(49);
    }];
    
    self.currentIndex = 0;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)top_confirmClick:(UIButton *)sender
{
    TOPUploadFileDriveCollectionVC *fileDrive = [[TOPUploadFileDriveCollectionVC alloc] init];
    fileDrive.uploadDatas = [NSMutableArray arrayWithArray:self.uploadDatas];
    fileDrive.isSingleUpload = self.isSingleUpload;
    fileDrive.fileType = self.currentIndex+1;
    fileDrive.uploadDriveStyle =  self.uploadDriveStyle;
    fileDrive.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:fileDrive animated:YES];
}

- (void)top_dropBoxOpenSusess:(NSNotificationCenter *)notification
{
    [self.tableView reloadData];
}
- (void)top_backHomeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (NSMutableArray *)iconArray{
    if (!_iconArray) {
        _iconArray = [NSMutableArray new];
    }
    return _iconArray;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPSelectFileTypeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPSelectFileTypeTableViewCell class])];
    }
    return _tableView;
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
#pragma mark - TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPSelectFileTypeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSelectFileTypeTableViewCell class]) forIndexPath:indexPath];
    cell.itemTitleLabel.text = self.dataArray[indexPath.row];
    cell.coverImageView.image = [UIImage imageNamed: self.iconArray[indexPath.row]];
    if (self.currentIndex == indexPath.row) {
        cell.selectedIconImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    }else{
        cell.selectedIconImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    TOPSelectFileTypeTableViewCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    lastCell.selectedIconImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];

    
    TOPSelectFileTypeTableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.selectedIconImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];

    self.currentIndex = indexPath.row;
}

@end
