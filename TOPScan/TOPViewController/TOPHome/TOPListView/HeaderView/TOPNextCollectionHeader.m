#import "TOPNextCollectionHeader.h"

@implementation TOPNextCollectionHeader
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];

        _titleLab = [UILabel new];
        _titleLab.text = NSLocalizedString(@"topscan_newlisttype", @"");
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        
        _showBtn = [UIButton new];
        _showBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _showBtn.selected = [TOPScanerShare top_saveFolderMergeState];
        [_showBtn setTitle:NSLocalizedString(@"topscan_newlistnormaltitle", @"") forState:UIControlStateNormal];
        [_showBtn setTitle:NSLocalizedString(@"topscan_newlistselecttitle", @"") forState:UIControlStateSelected];
        [_showBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [_showBtn addTarget:self action:@selector(clikShowBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleLab];
        [self addSubview:_showBtn];
        [self top_setMask];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}
- (void)top_setMask{
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    [self top_setShowBtnMas];
}
- (void)top_setShowBtnMas{
    NSString * titleString;
    if (_showBtn.selected) {
        titleString = NSLocalizedString(@"topscan_newlistselecttitle", @"");
    }else{
        titleString = NSLocalizedString(@"topscan_newlistnormaltitle", @"");
    }
    CGFloat btnW = [TOPDocumentHelper top_getSizeWithStr:titleString Height:30 Font:14].width+10;
    [_showBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.trailing.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(btnW, 30));
    }];
}
- (void)clikShowBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.top_refreshFolder) {
        self.top_refreshFolder(sender.selected);
    }
    [self top_setShowBtnMas];
}
@end
