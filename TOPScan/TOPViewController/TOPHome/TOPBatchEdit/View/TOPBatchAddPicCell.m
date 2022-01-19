#import "TOPBatchAddPicCell.h"

@implementation TOPBatchAddPicCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _backView.userInteractionEnabled = YES;
        _backView.layer.cornerRadius = 3;
        _backView.layer.shadowColor = [UIColor blackColor].CGColor;
        _backView.layer.shadowOffset = CGSizeMake(0, 0);
        _backView.layer.shadowOpacity = 0.5;
        _backView.layer.masksToBounds = NO;
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_BatchAddPic"];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap)];
        [_backView addGestureRecognizer:tap];
        [self.contentView addSubview:_backView];
        [self.contentView addSubview:_iconImg];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(35);
        make.trailing.equalTo(self.contentView).offset(-35);
        make.top.equalTo(self.contentView).offset(130);
        make.bottom.equalTo(self.contentView).offset(-130);
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backView.mas_centerX);
        make.centerY.equalTo(_backView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 105));
    }];
}

- (void)setIsFinish:(BOOL)isFinish{
    _isFinish = isFinish;
    if (_isFinish) {
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }else{
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGB(225, 225, 225)];
    }
}
- (void)top_clickTap{
    if (self.top_clickAddBtn) {
        self.top_clickAddBtn();
    }
}
@end
