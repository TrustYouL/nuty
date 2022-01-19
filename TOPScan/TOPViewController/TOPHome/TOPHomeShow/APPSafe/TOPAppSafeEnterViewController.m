#import "TOPAppSafeEnterViewController.h"
#import "TOPNumberCollectionViewCell.h"
#import "TOPClearPsdCollectionViewCell.h"
#import "TOPCornerToast.h"

@interface TOPAppSafeEnterViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *numberArrays;
@property (strong, nonatomic) NSMutableArray *enterPsdArrays;
@property (assign, nonatomic) BOOL isShowPsd;
@property (weak, nonatomic) IBOutlet UIView *oneSupView;
@property (weak, nonatomic) IBOutlet UILabel *oneDotView;
@property (weak, nonatomic) IBOutlet UILabel *onePwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *twoSupView;
@property (weak, nonatomic) IBOutlet UILabel *twoDotView;
@property (weak, nonatomic) IBOutlet UILabel *twoPwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *threeSupView;
@property (weak, nonatomic) IBOutlet UILabel *threeDotView;
@property (weak, nonatomic) IBOutlet UILabel *threePwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *fourSupView;
@property (weak, nonatomic) IBOutlet UILabel *fourDotView;
@property (weak, nonatomic) IBOutlet UILabel *fourPwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *supCollectionBackView;

@end

@implementation TOPAppSafeEnterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"topscan_saferepassword", @"");
    self.subTitleLabel.text = NSLocalizedString(@"topscan_saferepassword", @"");
    self.titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    self.subTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    self.oneSupView.layer.cornerRadius = 2;
    self.oneSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.oneDotView.layer.cornerRadius = 5;
    self.oneSupView.layer.borderWidth = 1;
    
    self.twoSupView.layer.cornerRadius = 2;
    self.twoSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.twoDotView.layer.cornerRadius = 5;
    self.twoSupView.layer.borderWidth = 1;
    
    self.threeSupView.layer.cornerRadius = 2;
    self.threeSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.threeDotView.layer.cornerRadius = 5;
    self.threeSupView.layer.borderWidth = 1;
    
    self.fourSupView.layer.cornerRadius = 2;
    self.fourSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.fourDotView.layer.cornerRadius = 5;
    self.fourSupView.layer.borderWidth = 1;
    
    self.numberArrays = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"0",@"11"]];
    [self.supCollectionBackView addSubview:self.collectionView ];
}
- (IBAction)lockpasswordClick:(UIButton *)sender {
    if (self.isShowPsd == YES) {
        self.isShowPsd = NO;
        [sender setImage:[UIImage imageNamed:@"top_appsafe_hide_lock"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"top_appsafe_hide_hd"] forState:UIControlStateNormal];
        self.isShowPsd = YES;
    }
    if (self.enterPsdArrays.count) {
        [self top_updateTopPasswordUIWith:self.enterPsdArrays];
    }
}

- (IBAction)cancelClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)top_validationTapMothod
{
    __block NSString *enterPsd = @"";
    [self.enterPsdArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        enterPsd = [enterPsd stringByAppendingString:obj];
    }];
    
    if ([enterPsd isEqualToString:self.firstPwdStr]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOP_TRAppSafeStates];
        [[NSUserDefaults standardUserDefaults] setObject:enterPsd forKey:TOP_TRAppSafeCurrentPWDKey];
        [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypePwd forKey:TOP_TRAppSafeUnLockType];
    }else{
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"")];
        [self top_clearAllPassWordMothod];
    }
}

- (void)top_clearAllPassWordMothod
{
    [self.enterPsdArrays removeAllObjects];
    self.oneDotView.hidden = YES;
    self.onePwdContentLabel.text = @"";
    self.twoDotView.hidden = YES;
    self.twoPwdContentLabel.text = @"";
    self.threeDotView.hidden = YES;
    self.threePwdContentLabel.text = @"";
    self.fourDotView.hidden = YES;
    self.fourPwdContentLabel.text = @"";
}

- (NSMutableArray *)enterPsdArrays
{
    if (_enterPsdArrays == nil) {
        _enterPsdArrays = [NSMutableArray array];
    }
    return _enterPsdArrays;
}
- (NSMutableArray *)numberArrays
{
    if (_numberArrays ==nil) {
        _numberArrays = [NSMutableArray array];
    }
    return _numberArrays;
}
#pragma mark -- collectionView and delegate
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delaysContentTouches = false;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"TOPNumberCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([TOPNumberCollectionViewCell class])];
        [_collectionView registerClass:[TOPClearPsdCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPClearPsdCollectionViewCell class])];
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.numberArrays.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item == 9 || indexPath.item == 11) {
        TOPClearPsdCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPClearPsdCollectionViewCell class]) forIndexPath:indexPath];
        if (indexPath.item == 9) {
            cell.imageIconName = @"";
            
        }else{
            cell.imageIconName = @"top_appsafe_clear";
        }
        return cell;
    }
    TOPNumberCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPNumberCollectionViewCell class]) forIndexPath:indexPath];
    cell.numberTitleLabel.text = self.numberArrays[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(73, 73);
}

- (void)collectionView:(UICollectionView *)colView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 9 ) {
        
        return;
    }
    if (indexPath.item == 11) {
        TOPClearPsdCollectionViewCell *cell = (TOPClearPsdCollectionViewCell*)[colView cellForItemAtIndexPath:indexPath];
        cell.iconView.image = [UIImage imageNamed:@"top_appsafe_clear"];
        return;
    }
    TOPNumberCollectionViewCell *cell = (TOPNumberCollectionViewCell*)[colView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    
}

-(void) collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 9 ) {
        return;
    }
    if (indexPath.item == 11) {
        TOPClearPsdCollectionViewCell *cell = (TOPClearPsdCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.iconView.image = [UIImage imageNamed:@"top_appsafe_clear_Select"];
        return;
    }
    TOPNumberCollectionViewCell *cell = (TOPNumberCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xE3e3e3)]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 9) {
        return;
    }
    
    if (indexPath.item == 11) {
        if (self.enterPsdArrays.count) {
            [self.enterPsdArrays removeLastObject];
            [self top_updateTopPasswordUIWith:self.enterPsdArrays];
            return;
        }
        return;
    }
    
    if (self.enterPsdArrays.count  >=4) {
        return;
    }
    [self.enterPsdArrays addObject:self.numberArrays[indexPath.item]];
    [self top_updateTopPasswordUIWith:self.enterPsdArrays];
    if (self.enterPsdArrays.count  >=4) {
        [self top_validationTapMothod];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TOPScanerShare shared].isFirstShow = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return  UIEdgeInsetsMake(20, 50, 15, 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (TOPScreenWidth-100-73*3)/2;
}
- (void)top_updateTopPasswordUIWith:(NSMutableArray *)currentSaveArrays
{
    self.oneDotView.hidden = YES;
    self.onePwdContentLabel.hidden = YES;
    self.twoDotView.hidden = YES;
    self.twoPwdContentLabel.hidden = YES;
    self.threeDotView.hidden = YES;
    self.threePwdContentLabel.hidden = YES;
    self.fourDotView.hidden = YES;
    self.fourPwdContentLabel.hidden = YES;
    
    if (currentSaveArrays.count >0) {
        self.oneDotView.hidden = NO;
        self.onePwdContentLabel.hidden = YES;
        self.onePwdContentLabel.text = [currentSaveArrays firstObject];
        if (self.isShowPsd == YES) {
            self.oneDotView.hidden = YES;
            self.onePwdContentLabel.hidden = NO;
        }
    }
    if (currentSaveArrays.count  > 1)
    {
        self.twoDotView.hidden = NO;
        self.twoPwdContentLabel.text = currentSaveArrays[1];
        self.twoPwdContentLabel.hidden = YES;
        if (self.isShowPsd == YES) {
            self.twoDotView.hidden = YES;
            self.twoPwdContentLabel.hidden = NO;
        }
    }
    if (currentSaveArrays.count  >2)
    {
        self.threeDotView.hidden = NO;
        self.threePwdContentLabel.text =  currentSaveArrays[2];
        self.threePwdContentLabel.hidden = YES;
        if (self.isShowPsd == YES) {
            self.threeDotView.hidden = YES;
            self.threePwdContentLabel.hidden = NO;
        }
    }
    if (currentSaveArrays.count  > 3)
    {
        self.fourDotView.hidden = NO;
        self.fourPwdContentLabel.text = currentSaveArrays[3];
        self.fourPwdContentLabel.hidden = YES;
        if (self.isShowPsd == YES) {
            self.fourDotView.hidden = YES;
            self.fourPwdContentLabel.hidden = NO;
        }
    }
}

@end
