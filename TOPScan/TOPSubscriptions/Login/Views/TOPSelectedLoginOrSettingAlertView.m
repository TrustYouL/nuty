

#import "TOPSelectedLoginOrSettingAlertView.h"
// 标题字体大小
#define TitleFontSize  14

@interface TOPSelectedLoginOrSettingAlertView ()
@property (nonatomic, strong) UIView *mAlert;
@property (nonatomic, copy) void(^selectBlock)(void);
@end
@implementation TOPSelectedLoginOrSettingAlertView
/**
 ActionSheet 自定义
 @param selectBlock 选择回调
 */
- (instancetype)initWithTitleViewSelectBlock:(void(^)(void))selectBlock
{
    self = [super init];
    if (self) {
        
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        self.selectBlock = selectBlock;
        [self top_drawViewMessaryWithpageCost];
    }
    return self;
}
#pragma mark -- 配置主视图
- (void)top_drawViewMessaryWithpageCost
{
    _mAlert = [[UIView alloc] init];
    _mAlert.backgroundColor = [UIColor clearColor];
    [self addSubview:_mAlert];
    [_mAlert mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(17.5f);
        make.trailing.equalTo(self).offset(-17.5f);
        make.height.mas_offset(375);
    }];
    // 公司图标
    UIView *contentAlertView = [[UIView alloc] init];
    contentAlertView.layer.cornerRadius = 15;
    contentAlertView.backgroundColor = [UIColor whiteColor];
    contentAlertView.clipsToBounds = YES;
    [_mAlert addSubview:contentAlertView];
    [contentAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mAlert).offset(-70);
        make.top.equalTo(_mAlert);
        make.leading.equalTo(_mAlert);
        make.trailing.equalTo(_mAlert);
    }];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_login_userSelectf"]];
    [contentAlertView addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentAlertView).offset(10);
        make.centerX.equalTo(contentAlertView);
        make.width.mas_offset(96);
        make.height.mas_offset(96);
    }];
    // 标题
    UILabel *needCreditsTitleLabel = [[UILabel alloc] init];
    needCreditsTitleLabel.text = NSLocalizedString(@"topscan_loginicloudtips", @"");
    needCreditsTitleLabel.textColor = UIColorFromRGB(0x777777);
    needCreditsTitleLabel.numberOfLines = 0;
    needCreditsTitleLabel.font = PingFang_S_FONT_(15);
    needCreditsTitleLabel.textAlignment = NSTextAlignmentCenter;
    [contentAlertView addSubview:needCreditsTitleLabel];
    [needCreditsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentAlertView);
        make.trailing.equalTo(contentAlertView).offset(-20);
        make.leading.equalTo(contentAlertView).offset(20);
    }];
    
    // 去充值页面
    UIButton *loginNowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginNowButton.backgroundColor = TOPAPPGreenColor;
    [loginNowButton setTitle:NSLocalizedString(@"topscan_loginnow", @"") forState:UIControlStateNormal];
    loginNowButton.titleLabel.font = PingFang_S_FONT_(TitleFontSize);
    [loginNowButton addTarget:self action:@selector(top_submitOrderBtn:) forControlEvents:UIControlEventTouchUpInside];
    loginNowButton.layer.cornerRadius = 49/2;
    loginNowButton.clipsToBounds = YES;
    [contentAlertView addSubview:loginNowButton];
    [loginNowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentAlertView).offset(-15);
        make.trailing.equalTo(contentAlertView).offset(-36.5);
        make.leading.equalTo(contentAlertView).offset(36.5);
        make.height.mas_offset(49);
    }];
    //  关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"top_home_vip_tc_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(top_closeAlertView:) forControlEvents:UIControlEventTouchUpInside];
    [_mAlert addSubview:closeButton];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_mAlert);
        make.centerX.equalTo(_mAlert);
        make.height.mas_offset(29);
        make.width.mas_offset(29);
    }];
}

#pragma mark --关闭
-(void)top_closeAlertView:(UIButton *)btn
{
    [self top_dismissUnBoundView];
}
#pragma mark -- 去登录
-(void)top_submitOrderBtn:(UIButton *)btn
{
    self.selectBlock();
    [self top_dismissUnBoundView];
}
#pragma mark -- 展示弹窗
- (void)top_showAlertUnBoundView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    _mAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _mAlert.alpha = 0;
    
    WeakSelf(ws);
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        ws.mAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ws.mAlert.alpha = 1.0;
    } completion:nil];
}
#pragma mark -- 点击其他区域关闭弹窗
- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint location = [sender locationInView:nil];
        if (![_mAlert pointInside:[_mAlert convertPoint:location fromView:_mAlert.window] withEvent:nil]){
            [_mAlert.window removeGestureRecognizer:sender];
            [self top_dismissUnBoundView];
        }
    }
}
#pragma mark -- 隐藏弹窗
- (void)top_dismissUnBoundView {
    _mAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    WeakSelf(ws);
    [UIView animateWithDuration:0.3f animations:^{
        ws.mAlert.alpha = 0;
        ws.alpha = 0;
    } completion:^(BOOL finished) {
        [ws removeFromSuperview];
    }];
}

@end
