#import "TOPTopHideView.h"
@interface TOPTopHideView()
@property (nonatomic ,strong)NSMutableArray * btnArray;
@end
@implementation TOPTopHideView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAPPGreenColor];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    NSArray * iconArray = @[@"top_getIcould",@"top_sendPic",@"top_getPDF",@"top_sendDoc",@"top_functionMore"];
    NSArray * titleArray = @[NSLocalizedString(@"topscan_icouldbackup", @""),NSLocalizedString(@"topscan_importimage", @""),NSLocalizedString(@"topscan_mergepdf", @""),NSLocalizedString(@"topscan_importfile", @""),NSLocalizedString(@"topscan_more", @"")];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<iconArray.count; i++) {
        TOPImageTitleButton *tagBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
        tagBtn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAPPGreenColor];
        tagBtn.tag = 1000+i;
        tagBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        tagBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [tagBtn setImage:[UIImage imageNamed:iconArray[i]] forState:UIControlStateNormal];
        tagBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [tagBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tagBtn addTarget:self action:@selector(top_clickBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tagBtn];
        [tempArray addObject:tagBtn];
        
        [tagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.size.mas_equalTo(CGSizeMake(60, 75));
        }];
    }
    [self top_distributeSpacingHorizontallyWith:tempArray];//按钮的等间距设置
    self.btnArray = [tempArray mutableCopy];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAPPGreenColor];
    for (TOPImageTitleButton * btn in self.btnArray) {
        btn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAPPGreenColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
- (void)top_clickBtnSelect:(UIButton *)sender{
    if (self.top_topViewAction) {
        self.top_topViewAction(sender.tag-1000);
    }
}
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}

@end
