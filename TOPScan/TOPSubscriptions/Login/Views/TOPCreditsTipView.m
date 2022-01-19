

#import "TOPCreditsTipView.h"

// 标题字体大小
#define TitleFontSize  14

@interface TOPCreditsTipView ()
@property (nonatomic, strong) UIView *mAlert;
@property (nonatomic, copy) void(^selectBlock)(void);
@end
@implementation TOPCreditsTipView
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
        make.bottom.equalTo(self).offset(-100-TOPBottomSafeHeight);
        make.top.equalTo(self).offset(80+TOPNavBarAndStatusBarHeight);
        make.leading.equalTo(self).offset(17.5f);
        make.trailing.equalTo(self).offset(-17.5f);
    }];
    // 公司图标
    UIView *contentAlertView = [[UIView alloc] init];
    contentAlertView.layer.cornerRadius = 15;
    contentAlertView.backgroundColor = [UIColor whiteColor];
    contentAlertView.clipsToBounds = YES;
    [_mAlert addSubview:contentAlertView];
    [contentAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mAlert).offset(-50);
        make.top.equalTo(_mAlert);
        make.leading.equalTo(_mAlert);
        make.trailing.equalTo(_mAlert);
    }];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_CreditsTipView_top"]];
    [contentAlertView addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentAlertView).offset(40);
        make.centerX.equalTo(contentAlertView);
        make.width.mas_offset(153);
        make.height.mas_offset(100);
    }];
    // 标题
    UILabel *needCreditsTitleLabel = [[UILabel alloc] init];
    //通过修改文本属性
    needCreditsTitleLabel.text = NSLocalizedString(@"topscan_ocrnummorethan", @"");
    
    NSMutableAttributedString *attriString =
    [[NSMutableAttributedString alloc] initWithString:needCreditsTitleLabel.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];//设置距离
    [attriString addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyle
                        range:NSMakeRange(0, [needCreditsTitleLabel.text length])];
    needCreditsTitleLabel.attributedText = attriString;
    needCreditsTitleLabel.textColor = UIColorFromRGB(0x777777);
    needCreditsTitleLabel.numberOfLines = 0;
    needCreditsTitleLabel.font = PingFang_R_FONT_(12);
    needCreditsTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    [contentAlertView addSubview:needCreditsTitleLabel];
    [needCreditsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentAlertView).offset(15);
        make.trailing.equalTo(contentAlertView).offset(-20);
        make.leading.equalTo(contentAlertView).offset(20);
    }];
    // 去充值页面
    UIButton *submitOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    submitOrder.backgroundColor = TOPAPPGreenColor;
    [submitOrder setTitle:NSLocalizedString(@"topscan_paynow", @"") forState:UIControlStateNormal];
    submitOrder.titleLabel.font = PingFang_S_FONT_(TitleFontSize);
    [submitOrder addTarget:self action:@selector(top_submitOrderBtn:) forControlEvents:UIControlEventTouchUpInside];
    submitOrder.layer.cornerRadius = 49/2;
    submitOrder.clipsToBounds = YES;
    [contentAlertView addSubview:submitOrder];
    [submitOrder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentAlertView).offset(-40);
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
#pragma mark -- 关闭
-(void)top_closeAlertView:(UIButton *)btn
{
    [self top_dismissUnBoundView];
}
#pragma mark -- 提交订单
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
