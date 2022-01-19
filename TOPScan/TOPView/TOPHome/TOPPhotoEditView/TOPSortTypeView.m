#import "TOPSortTypeView.h"

@implementation TOPSortTypeView
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    NSArray *titleArray = [NSArray new];
    NSArray *iconArray = [NSArray new];
    if (IS_IPAD) {
        titleArray = @[NSLocalizedString(@"topscan_girdviewlist", @""),NSLocalizedString(@"topscan_girdview2", @"")];
        iconArray = @[@"top_listView",@"top_girdview"];
    }else{
        titleArray = @[NSLocalizedString(@"topscan_girdview2", @""),NSLocalizedString(@"topscan_newlisttitle", @"")];
        iconArray = @[@"top_girdview3",@"top_nextlist"];
    }
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<iconArray.count; i++) {
        TOPImageTitleButton *tagBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
        tagBtn.padding = CGSizeMake(5, 5);
        tagBtn.backgroundColor = [UIColor clearColor];
        tagBtn.tag = 1000+i;
        tagBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        tagBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [tagBtn setImage:[UIImage imageNamed:iconArray[i]] forState:UIControlStateNormal];
        tagBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [tagBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        [tagBtn addTarget:self action:@selector(top_clickBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tagBtn];
        [tempArray addObject:tagBtn];
        
        [tagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(7);
            make.bottom.equalTo(self);
            make.width.mas_equalTo(60);
        }];
    }
    [self top_distributeSpacingHorizontallyWith:tempArray];//按钮的等间距设置
}

- (void)top_clickBtnSelect:(UIButton *)sender{
    if (self.top_topViewAction) {
        self.top_topViewAction(sender.tag-1000);
    }
}


@end
