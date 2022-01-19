#import "TOPDriveSelectListView.h"
#import "TopDirveSelectItemTabCell.h"
#import "DriveDownloadManger.h"
@interface TOPDriveSelectListView ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic)  UIView *alertView;
@property (strong, nonatomic)  UITableView *tableView;
@property (assign, nonatomic)  NSInteger currentIndex;

@end
@implementation TOPDriveSelectListView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    self.alertView.alpha = 0.0;
    
    self.alertView.layer.cornerRadius = 2;
    self.alertView.clipsToBounds = YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight);
        self.backgroundColor = [UIColor clearColor];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor= [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.alertView.alpha = 0.0;
        self.alertView.clipsToBounds = YES;
        self.alertView.layer.cornerRadius = 2;

        self.currentIndex = 0;
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, TOPScreenWidth-30, 50) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TopDirveSelectItemTabCell class] forCellReuseIdentifier:@"ReStoreItemCe1ll"];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] forState:UIControlStateNormal];
        [cancelButton setTitleColor: UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        
        [self addSubview:self.alertView];
        [self.alertView addSubview:cancelButton];
        [self.alertView addSubview:_tableView];
        
        [self.alertView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(self).offset(15);
            make.trailing.equalTo(self).offset(-15);
            make.height.mas_equalTo(260);
        }];
        [cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.alertView).offset(-5);
            make.trailing.equalTo(self.alertView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(70, 35));
        }];
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.alertView).offset(10);
            make.trailing.equalTo(self.alertView).offset(-10);
            make.top.equalTo(self.alertView).offset(10);
            make.bottom.equalTo(cancelButton.mas_top);
        }];
    }
    return self;
}
- (void)top_refreshUI:(NSMutableArray *)dataArray{
    CGFloat alertViewH = 0.0;
    if (dataArray.count>4) {
        alertViewH = 4*50+61;
    }else{
        alertViewH = dataArray.count*50+61;
    }
    [_alertView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(alertViewH);
    }];
    [self.tableView reloadData];
}
-(void)top_showXib
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.alertView.transform = CGAffineTransformScale(self.alertView.transform,1.1,1.1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor = RGBA(0, 0, 0, 0.4);
        self.alertView.transform = CGAffineTransformIdentity;
        self.alertView.alpha = 1.0;
        
    } completion:nil];
}
-(void)top_showXib:(UIView *)supView
{
    [supView addSubview:self];
    self.frame = supView.frame;
    self.alertView.transform = CGAffineTransformScale(self.alertView.transform,1.1,1.1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor =  [UIColorFromRGB(0x333333) colorWithAlphaComponent:0.5];
        self.alertView.transform = CGAffineTransformIdentity;
        self.alertView.alpha = 1.0;
    } completion:nil];
}

-(void)top_closeXib
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.0;
        self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
        self.alertView.transform = CGAffineTransformScale(self.alertView.transform,0.9,0.9);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

+(instancetype)top_creatXIB{
    return  [[TOPDriveSelectListView alloc] init];
}

- (void)buttonClick:(UIButton *)sender {
    [self top_closeXib];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.driveDataArrays.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopDirveSelectItemTabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReStoreItemCe1ll" forIndexPath:indexPath];
    cell.titleLab.text = self.driveDataArrays[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopDirveSelectItemTabCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    
    TopDirveSelectItemTabCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    lastCell.selectImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];
    if (self.selectDriveBlock) {
        self.selectDriveBlock(self.driveDataArrays[indexPath.row]);
    }
    [self top_closeXib];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (void)setDriveDataArrays:(NSMutableArray *)driveDataArrays
{
    _driveDataArrays = driveDataArrays;
    [self top_refreshUI:driveDataArrays];
}
@end
