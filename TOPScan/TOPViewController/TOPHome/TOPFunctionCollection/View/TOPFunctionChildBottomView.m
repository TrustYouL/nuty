#import "TOPFunctionChildBottomView.h"

@implementation TOPFunctionChildBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _myBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 10, TOPScreenWidth-40, 50)];
        _myBtn.layer.cornerRadius = 8;
        _myBtn.layer.masksToBounds = YES;
        _myBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_myBtn setTitle:NSLocalizedString(@"topscan_colletionpdfextractbottomtitle", @"") forState:UIControlStateNormal];
        [_myBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        [_myBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_myBtn];
        [_myBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(25);
            make.trailing.equalTo(self).offset(-25);
            make.top.equalTo(self).offset(10);
            make.height.mas_equalTo(50);
        }];
    }
    return self;
}

- (void)top_clickBtn:(UIButton *)sender{
    if (self.top_clickBtnBlock) {
        self.top_clickBtnBlock();
    }
}

@end
